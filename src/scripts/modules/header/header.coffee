define (require) ->
  $ = require('jquery')
  BaseView = require('cs!helpers/backbone/views/base')
  template = require('hbs!./header-template')
  require('less!./header')

  return class HeaderView extends BaseView
    template: template
    templateHelpers:
      page: () -> @page

    initialize: (options) ->
      super()
      @page = options?.page