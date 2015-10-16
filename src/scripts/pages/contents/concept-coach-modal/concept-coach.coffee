define (require) ->
  $ = require('jquery')
  BaseView = require('cs!helpers/backbone/views/base')
  template = require('hbs!./concept-coach-template')
  router = require('cs!router')
  session  = require('cs!session')
  require('bootstrapTransition')
  require('bootstrapModal')

  return class ConceptCoachModal extends BaseView
    template: template
    templateHelpers: () ->
      return {
        userId: session.get('id')
        fullName: session.get('fullname')
      }

    events:
      'submit': 'onSubmit'
      'shown.bs.modal': 'onShow'

    onShow: (e) ->
      userId = session.get('id')
      unless userId
        router.navigate("#{location.pathname}?coach")
        window.location = '/login'
      @$el.find('button[type="submit"]').focus()

    onSubmit: (e) ->
      e.preventDefault()
      # Navigate after hide is complete
      @$el.one('hidden.bs.modal', ->
        url=location.pathname
        console.debug("Location:", location)
        console.debug("Navigating", router, 'to cc-login from', url)
        router.navigate("cc-login?from=#{url}", {trigger: true})
        )
      @$el.modal('hide')
