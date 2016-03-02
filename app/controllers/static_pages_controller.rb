class StaticPagesController < ApplicationController
  def home
    if logged_in?
      @job = current_user.jobs.build
      @feed_items = current_user.feed.order(:id).page params[:page]
    end
  end

  def help
  end

  def contact
  end

  def about
  end
end
