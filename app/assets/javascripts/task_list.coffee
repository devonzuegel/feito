{ div, h1, h2, h3, h4, h5, h6, p, a, form, button, input, icon, ul, li } = React.DOM

@TaskList = React.createClass
  displayName: 'TaskList'

  getInitialState: ->
    tasks:    @props.tasks

  render: ->
    div className: 'task_list',
      div, "Your API key: #{@props.api_key}"
      for task in @state.tasks
        React.createElement Task,
          task: task
          api_key: @props.api_key

  componentDidMount: ->

  componentDidUpdate: ->
    console.log 'TaskList updated!'