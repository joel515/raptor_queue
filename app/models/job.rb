class Job < ActiveRecord::Base
  belongs_to :user
  mount_uploader :inputfile, InputFileUploader
  default_scope -> { order(created_at: :desc) }
  validates :user_id,    presence: true
  validates :name,       presence: true, length: { maximum: 15 }
  validates :status,     presence: true
  validates :config,     presence: true
  validates :processors, presence: true,
                         numericality: { only_integer: true,
                                         greater_than_or_equal_to: 1,
                                         less_than_or_equal_to: 16 }
  validates :nodes,      presence: true,
                         numericality: { only_integer: true,
                                         greater_than_or_equal_to: 1,
                                         less_than_or_equal_to: 32 }

  JOB_STATUS = {
    u: "Unsubmitted",
    e: "Exiting",
    h: "Held",
    q: "Queued",
    r: "Running",
    t: "Moving",
    w: "Waiting",
    s: "Suspended",
    c: "Completed",
    f: "Failed",
    b: "Submitted",
    m: "Terminated",
    k: "Unknown"
  }

  validates_inclusion_of :status, in: JOB_STATUS.values

  SOLVERS = {
    elmer:   "Elmer",
    ansys:   "Ansys",
    starccm: "STAR-CCM+"
  }

  validates_inclusion_of :config, in: SOLVERS.keys.map(&:to_s)

  MAX_PPN = 16
  MAX_NODE = 32

  # Job status queries.
  def running?
    [JOB_STATUS[:r]].include? status
  end

  def completed?(state = status)
    [JOB_STATUS[:c]].include? state
  end

  def active?
    [JOB_STATUS[:h], JOB_STATUS[:q], JOB_STATUS[:s], JOB_STATUS[:e],
     JOB_STATUS[:t], JOB_STATUS[:w], JOB_STATUS[:b]].include? status
  end

  def failed?
    [JOB_STATUS[:f], JOB_STATUS[:k], JOB_STATUS[:m]].include? status
  end

  def ready?
    [JOB_STATUS[:u]].include? status
  end

  def ready
    self.pid = nil
    self.jobdir = nil
    set_status! :u
  end

  def submitted?
    [JOB_STATUS[:b]].include? status
  end

  def terminated?
    [JOB_STATUS[:m], JOB_STATUS[:e]].include? status
  end

  def destroyable?
    !active? & !running?
  end

  def cleanable?
    !active? & !running? & !ready?
  end

  def terminatable?
    active? | running?
  end

  def editable?
    !active? & !running?
  end

  # Submit the job.  Use qsub if using PBS scheduler.  Otherwise run the bash
  # script.  If the latter, capture the group id from the process spawned.
  def submit
    # configure_concern
    # submit_job
  end

  # Check the job's status.  Use qstat if submitted via PBS, otherwise check
  # the child PIDs from the submitted group PID.
  def check_status
    # return status if pid.nil?

    # pre_status = `#{check_status_command}`
    # unless pre_status.nil? || pre_status.empty?
    #   state = check_process_status(pre_status)
    #   completed?(state) ? check_completed_status : state
    # else
    #   failed? ? status : check_completed_status
    # end
    status
  end
end
