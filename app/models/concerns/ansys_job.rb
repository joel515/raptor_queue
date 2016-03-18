module AnsysJob
  extend ActiveSupport::Concern

  # Ansys versions - Put latest version first.  It will default to this.
  VERSIONS = {
    v162: "16.2",
    v161: "16.1",
    v150: "15.0"
  }

  ANSYS_EXE = "/gpfs/apps/ansys/v---/ansys/bin/ansys---"

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

    # Generate the submit script and submit the job using qsub.
    def submit_job
      unless inputfile_identifier.nil?
        set_version if version.nil?
        submit_script = generate_submit_script(input_deck: inputfile_identifier)

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
        self.submitted_at = Time.new.ctime
        set_status! :b
      else
        self.pid = nil
        self.submitted_at = '---'
        set_status! :f
      end
    end

    def set_version
      self.version = AnsysJob::VERSIONS.keys.first.to_s
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

      exe = ANSYS_EXE.gsub(/---/, version.gsub(/[v]/, ""))

      File.open(submit_script, 'w') do |f|
        f.puts "#!#{shell_cmd}"

        f.puts "#PBS -S #{shell_cmd}"
        f.puts "#PBS -N #{prefix}"
        f.puts "#PBS -l nodes=#{nodes}:ppn=#{processors}"
        f.puts "#PBS -j oe"
        f.puts "#PBS -m ae"
        f.puts "#PBS -M #{user.email}"

        f.puts "module load openmpi/gcc/64/1.10.1"
        f.puts "machines=`uniq -c ${PBS_NODEFILE} | " \
          "awk '{print $2 \":\" $1}' | paste -s -d ':'`"
        f.puts "cd ${PBS_O_WORKDIR}"
        f.puts "#{exe} -b -dis -machines $machines -i #{input_deck}"
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
