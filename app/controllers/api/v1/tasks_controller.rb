# app/controllers/api/v1/tasks_controller.rb
class Api::V1::TasksController < Api::ApiController
  before_action :set_task, only: %i(show steps update)

  def index
    respond_with :api, :v1, @user.tasks, status: :ok
  end

  def show
    respond_with :api, :v1, @task, status: :ok
  end

  def steps
    respond_with :api, :v1, @task.steps, status: :ok
  end

  def update
    @task.update_attributes(task_params)
    render json: @task, status: :ok
  end

  private

  def task_params
    params.permit(:id, :archived, :completed, :due, :schedule, :title)
  end

  def set_task
    @task = Task.find(task_params[:id])
    return if @task.belongs_to?(@user)

    response_json = { status: User::INVALID_API_KEY }
    render json: response_json, status: :unauthorized
  end
end
