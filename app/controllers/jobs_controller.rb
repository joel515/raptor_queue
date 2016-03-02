class JobsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def index
    if Job.any?
      @jobs = Job.order(:created_at).page params[:page]
    else
      redirect_to request.referrer || root_url
    end
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      flash[:success] = "Job created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @job.destroy
    flash[:success] = "Job deleted"
    redirect_to request.referrer || root_url
  end

  def submit
  end

  def kill
  end

  def stdout
  end

  def copy
  end

  def clean
  end

  private

    def job_params
      params.require(:job).permit(:name)
    end

    def correct_user
      @job = current_user.jobs.find_by(id: params[:id])
      redirect_to root_url if @job.nil?
    end
end
