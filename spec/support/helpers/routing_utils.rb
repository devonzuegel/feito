# /zen-writer/spec/support/helpers/routing_utils.rb
module RoutingUtils
  TASKS_ENDPOINT = '/api/v1/tasks'

  def tasks_endpoint(id = nil)
    "#{TASKS_ENDPOINT}/#{id}"
  end

  def steps_endpoint(task_id)
    "#{TASKS_ENDPOINT}/#{task_id}/steps"
  end
end