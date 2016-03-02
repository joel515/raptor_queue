class Job < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order(created_at: :desc) }
  validates :user_id,    presence: true
  validates :name,       presence: true, length: { maximum: 15 }
  validates :status,     presence: true
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
end
