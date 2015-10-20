define (require) ->
  {Exercise} = require('OpenStaxReactComponents')

  return (node, data) ->
    step = _.clone(data.items[0])
    step.content = _.pick(step, 'questions')

    getProps = ->
      props =
        id: step.content.questions[0].id
        taskId: '1'
        onStepCompleted: ->
          console.info('onStepCompleted')
        onNextStep: ->
          console.info('onNextStep')
        step: step
        getCurrentPanel: (stepId) ->
          panel = 'free-response'
          if step.answer_id
            panel = 'review'
          if step.free_response
            panel = 'multiple-choice'
          panel
        setAnswerId: (stepId, answerId) ->
          step.answer_id = answerId
          exercise?.setProps?(getProps())
        setFreeResponseAnswer: (stepId, freeResponse) ->
          step.free_response = freeResponse
          exercise?.setProps?(getProps())

    exercise = Exercise(node.parentNode, getProps())
