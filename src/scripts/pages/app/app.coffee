define (require) ->
  $ = require('jquery')
  linksHelper = require('cs!helpers/links')
  BaseView = require('cs!helpers/backbone/views/base')
  HeaderView = require('cs!modules/header/header')
  MinimalHeaderView = require('cs!modules/minimal/header/header')
  template = require('hbs!./app-template')
  require('less!./app')

  return class AppView extends BaseView
    el: 'body'
    template: template

    regions:
      header: '#header'
      main: '#scrollable-content'

    initialize: () ->
      super()
      @$el.html(@template)
      @listenTo Backbone, 'window:resize', @sizeScrollableContent

    sizeScrollableContent: ->
      $sc = $('#scrollable-content')
      top = $sc.offset().top
      wh = window.innerHeight
      $sc.height((wh - top) + 'px')

    render: (page, options) ->
      queryString = linksHelper.serializeQuery(location.search)
      @minimal = false
      if queryString.minimal
        @minimal = true
      headerView = if @minimal then new MinimalHeaderView() else new HeaderView()
      @regions.header.show(headerView)
      # Lazy-load the page
      require ["cs!pages/#{page}/#{page}"], (View) =>
        @regions.main.show(new View(options))
        @sizeScrollableContent()
        window.onresize = ->
          Backbone.trigger 'window:resize'
        window.onpopstate = (popEvent) ->
          Backbone.trigger 'window:popstate', popEvent

      return @
