{ div, h1, h2, h3, h4, h5, h6, p, a, form, button, input, icon, ul, li } = React.DOM

@Task = React.createClass
  displayName: 'Task'

  getInitialState: ->
    id:        @props.task.id
    title:     @props.task.title
    archived:  @props.task.archived
    completed: @props.task.completed
    due:       @props.task.due
    schedule:  @props.task.schedule

  render: ->
    div className: 'task', id: "task-#{@state.id}",
      input
        id: "checkbox-#{@state.id}"
        type: 'checkbox'
        checked: @state.completed
        className: 'checkbox'
        onChange: @clicked
      li id: "title-#{@state.id}",     @state.title
      li id: "archived-#{@state.id}",  JSON.stringify(@state.archived)
      li id: "completed-#{@state.id}", JSON.stringify(@state.completed)
      li id: "due-#{@state.id}",       "Due: #{time_ago(@state.due)}"
      li id: "schedule-#{@state.id}",  "Scheduled: #{formatted_date(@state.schedule)}"

  componentDidMount: ->

  componentDidUpdate: ->

  clicked: ->
    @setState completed: !@state.completed
    console.log @state