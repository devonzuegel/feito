{ div, h1, h2, h3, h4, h5, h6, p, a, form, button, input, icon, ul, li } = React.DOM

@Task = React.createClass
  displayName: 'Task'

  getInitialState: ->
    title:     @props.task.title
    archived:  @props.task.archived
    completed: @props.task.completed
    due:       @props.task.due
    schedule:  @props.task.schedule

  render: ->
    klass = if @state.completed then 'completed' else 'incompleted'
    div className: "#{klass}-task",   id: "task-#{@id()}",
      input id: "checkbox-#{@id()}",  type: 'checkbox',   checked: @state.completed,  onChange: @clicked
      li    id: "title-#{@id()}",     @state.title
      li    id: "archived-#{@id()}",  JSON.stringify(@state.archived)
      li    id: "completed-#{@id()}", JSON.stringify(@state.completed)
      li    id: "due-#{@id()}",       "Due: #{time_ago(@state.due)}"
      li    id: "schedule-#{@id()}",  "Scheduled: #{formatted_date(@state.schedule)}"

  componentDidMount: ->
    url = "api/v1/tasks/#{@id()}"
    $.putJSON url, @data(), (results) =>
      console.log JSON.stringify(results, null, 3)

  id: -> @props.task.id

  # componentDidUpdate: ->

  data: ->
    data = {
      api_key: @props.api_key
    }

  clicked: ->
    @setState completed: !@state.completed