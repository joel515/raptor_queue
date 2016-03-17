module StarccmJob
  extend ActiveSupport::Concern
  # validates :inputfile, presence: true

  # STAR-CCM+ versions - Put latest version last.  It will default to this.
  VERSIONS = {
    v90611R8:   "9.06.011-R8",
    v1002012R8: "10.02.012-R8",
    v1006010:   "10.06.010",
    v1006010R8: "10.06.010-R8"
  }

  # Power on demand environment variable should be set in user's .bashrc file.
  LICPATH = "1999@flex.cd-adapco.com"
  PODKEY = `echo $PODKEY`.strip

  # Capture the job stats and return the data as a hash.
  def job_stats
    jobpath = Pathname.new(jobdir)
    std_out = jobpath + "#{prefix}.o#{pid.split('.')[0]}"

    nodes, elements, cputime, walltime = nil
    # if std_out.exist?
    #   File.foreach(std_out) do |line|
    #     nodes    = line.split[4] if line.include? "MAXIMUM NODE NUMBER"
    #     elements = line.split[4] if line.include? "MAXIMUM ELEMENT NUMBER"
    #     cputime  = "#{line.split[5]} s" if line.include? "CP Time"
    #     walltime = "#{line.split[5]} s" if line.include? "Elapsed Time"
    #   end
    # end
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
      self.version = StarccmJob::VERSIONS.keys.last.to_s
    end

    # Write the Bash script used to submit the job to the cluster.  The job
    # first generates the geometry and mesh using GMSH, converts the mesh to
    # Elmer format using ElmerGrid, solves using ElmerSolver, then creates
    # 3D visualization plots of the results using Paraview (batch).
    def generate_submit_script(args)
      debugger
      jobpath = Pathname.new(jobdir)
      simname = File.basename(args[:input_deck],File.extname(args[:input_deck]))
      submit_script = jobpath + "#{prefix}.sh"
      shell_cmd = `which bash`.strip
      File.open(submit_script, 'w') do |f|
        f.puts "#!#{shell_cmd}"

        f.puts "#PBS -S #{shell_cmd}"
        f.puts "#PBS -N #{prefix}"
        f.puts "#PBS -l nodes=#{nodes}:ppn=#{processors}"
        f.puts "#PBS -j oe"
        f.puts "#PBS -m ae"
        f.puts "#PBS -M #{user.email}"

        f.puts "module add starccm+/#{StarccmJob::VERSIONS[version.to_sym]}"
        f.puts "numprocs=`wc -l $PBS_NODEFILE | cut -f1 -d \" \"`"

        f.puts "cd ${PBS_O_WORKDIR}"
        f.puts "starccm+ -batch -np $numprocs -machinefile $PBS_NODEFILE " \
          "-power -podkey #{PODKEY} -licpath #{LICPATH} -pio -time -rsh ssh " \
          "#{simname}"
      end

      submit_script.exist? ? submit_script : nil
    end

    def output_ok?(std_out)
      errors = false
      File.foreach(std_out) do |line|
        errors = line.include? "error: Server Error"
      end

      !errors
    end
end
