class FalseClass
  def to_i
    0
  end
end

class TrueClass
  def to_i
    1
  end
end

module ApplicationHelper

  require 'pathname'

  # Returns the full title on a per-page basis.
  def full_title(page_title = '')
    base_title = "RaptorQueue"
    page_title.empty? ? base_title : page_title + " | " + base_title
  end
end
