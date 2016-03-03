module AnsysJob
  extend ActiveSupport::Concern

  ANSYS_EXE = "/gpfs/apps/ansys/v162/ansys/bin/ansys162"

  # Capture the job stats and return the data as a hash.
  def job_stats
    jobpath = Pathname.new(jobdir)
    std_out = jobpath + "#{prefix}.o#{pid.split('.')[0]}"

    nodes, elements, cputime, walltime = nil
    if std_out.exist?
      File.foreach(std_out) do |line|
        nodes    = line.split[4] if line.include? "MAXIMUM NODE NUMBER"
        elements = line.split[4] if line.include? "MAXIMUM ELEMENT NUMBER"
        cputime  = "#{line.split[5]} s" if line.include? "CP Time"
        walltime = "#{line.split[5]} s" if line.include? "Elapsed Time"
      end
    end
    Hash["Number of Nodes" => nodes,
         "Number of Elements" => elements,
         "CPU Time" => cputime,
         "Wall Time" => walltime]
  end

  def result_path
    Pathname.new(jobdir)
  end

  private

    # Create the following directories as job staging in the user's home.
    # $HOME/Scratch/<beam name>
    # TODO: Add error checking if directories cannot be created.
    def create_staging_directories
      homedir = Pathname.new(Dir.home())
      return nil unless homedir.directory?

      scratchdir = homedir + "Scratch"
      Dir.mkdir(scratchdir) unless scratchdir.directory?
      stagedir = scratchdir + prefix
      Dir.mkdir(stagedir) unless stagedir.directory?
      stagedir.to_s
    end

    # Submit the job.  Use qsub if using PBS scheduler.  Otherwise run the bash
    # script.  If the latter, capture the group id from the process spawned.
    def submit_job
      self.jobdir = create_staging_directories
      input_deck = inputfile

      if !input_deck.nil?
        submit_script = generate_submit_script(input_deck: input_deck)

        if !submit_script.nil?
          Dir.chdir(jobdir) {
            cmd =  "qsub #{prefix}.sh"
            self.pid = `#{cmd}`
          }
        end
      end

      # If successful, set the status to "Submitted" and save to database.
      unless pid.nil? || pid.empty?
        self.pid = pid.strip
        set_status! :b
      else
        self.pid = nil
        set_status! :f
      end
    end

    # Write the Bash script used to submit the job to the cluster.  The job
    # first generates the geometry and mesh using GMSH, converts the mesh to
    # Elmer format using ElmerGrid, solves using ElmerSolver, then creates
    # 3D visualization plots of the results using Paraview (batch).
    def generate_submit_script(args)
      jobpath = Pathname.new(jobdir)
      input_deck = inputfile_identifier
      submit_script = jobpath + "#{prefix}.sh"
      shell_cmd = `which bash`.strip
      File.open(submit_script, 'w') do |f|
        f.puts "#!#{shell_cmd}"

        f.puts "#PBS -S #{shell_cmd}"
        f.puts "#PBS -N #{prefix}"
        f.puts "#PBS -l nodes=#{nodes}:ppn=#{processors}"
        f.puts "#PBS -j oe"
        f.puts "module load openmpi/gcc/64/1.10.1"
        f.puts "machines=`uniq -c ${PBS_NODEFILE} | " \
          "awk '{print $2 \":\" $1}' | paste -s -d ':'`"
        f.puts "cd ${PBS_O_WORKDIR}"
        f.puts "#{ANSYS_EXE} -b -dis -machines $machines -i #{input_deck}"
      end

      submit_script.exist? ? submit_script : nil
    end

    def output_ok?(std_out)
      errors = nil
      File.foreach(std_out) do |line|
        errors = line.split[5].to_i if line.include? \
          "NUMBER OF ERROR   MESSAGES ENCOUNTERED="
      end

      !errors.nil? && errors == 0
    end
end
