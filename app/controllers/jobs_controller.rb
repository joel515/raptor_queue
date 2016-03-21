class JobsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: [:destroy]
  before_action :set_job,        only: [:submit, :kill, :show, :clean, :edit,
                                        :files]

  def index
    if Job.any?
      @jobs = Job.order(:created_at).page params[:page]
    else
      redirect_to request.referrer || root_url
    end
  end

  def new
    @job = Job.new
  end

  def show
  end

  def edit
  end

  def create
    @job = current_user.jobs.build(job_params)
    if @job.save
      submit_job
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end

  def destroy
    @job.destroy
    flash[:success] = "Job deleted."
    redirect_to request.referrer || root_url
  end

  def submit
    submit_job
  end

  def kill
    if @job.terminatable?
      @job.kill
      flash[:success] = "Terminating '#{@job.name}'."
    else
      flash[:danger] = "'#{@job.name}' is not running."
    end

    redirect_to request.referrer
  end

  def stdout
  end

  def copy
  end

  def clean
    if @job.cleanable?
      @job.clean_staging_directories
      @job.ready
      flash[:success] = "Job directory successfully deleted."
    else
      flash[:danger] = "Job cannot be cleaned at this time."
    end

    # if request.referrer.include? results_beam_path
    #   redirect_to @job
    # else
      redirect_to request.referrer || index_url
    # end
  end

  def download
    send_file(params[:file], filename: File.basename(params[:file]),
                             disposition: 'attachment',
                             type: 'application/octet-stream')
  end

  def files
    @directory = params[:file]
    respond_to do |format|
      format.js
    end
  end

  def update_versions
    @config = params[:config]
    respond_to do |format|
      format.js
    end
  end

  private

    def job_params
      params.require(:job).permit(:name, :nodes, :processors, :config,
                                  :inputfile, :version)
    end

    def set_job
      @job = Job.find(params[:id])
    end

    def correct_user
      @job = current_user.jobs.find_by(id: params[:id])
      redirect_to root_url if @job.nil?
    end

    def submit_job
      @job.submit if @job.ready?
      if @job.submitted?
        flash[:success] = "Simulation for #{@job.name} successfully submitted!"
      else
        flash[:danger] = "Submission for #{@job.name} failed."
      end

      redirect_to root_url
    end
end
