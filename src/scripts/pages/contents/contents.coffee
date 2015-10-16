define (require) ->
  $ = require('jquery')
  BaseView = require('cs!helpers/backbone/views/base')
  HeaderView = require('cs!modules/header/header')
  FooterView = require('cs!modules/footer/footer')
  FindContentView = require('cs!modules/find-content/find-content')
  BrowseContentView = require('cs!modules/browse-content/browse-content')
  MediaView = require('cs!modules/media/media')
  ConceptCoachModalView = require('cs!pages/contents/concept-coach-modal/concept-coach')
  template = require('hbs!./contents-template')
  require('less!./contents')

  POLLING_REFRESH = 10 * 1000 # milliseconds

  return class ContentsPage extends BaseView
    template: template
    pageTitle: 'Content Library'
    canonical: () -> null if not @uuid
    summary: 'OpenStax Content Library'
    description: 'Search for free, online textbooks.'

    initialize: (options = {}) ->
      super()
      @uuid = options.uuid
      @version = options.version
      @page = options.page
      @title = options.title
      @coach = options.qs == '?coach'
      @conceptCoachModal = new ConceptCoachModalView()
      @conceptCoachButton = $('<button id="summon-concept-coach" class="btn">').text('Coach Me!')

    regions:
      contents: '#contents'

    events:
      'click #summon-concept-coach': 'showConceptCoach'

    showConceptCoach: ->
      @regions.self.appendOnce
        view: @conceptCoachModal
        as: 'div id="section-name-modal" class="modal fade"'
      setTimeout(=>
        @conceptCoachModal.$el.modal('show')
      , 0)

    onRender: () ->
      @parent.regions.footer.show(new FooterView({page: 'contents'}))
      @regions.contents.show(new FindContentView())
      console.debug("Coach: #{@coach}")
      if @coach then @showConceptCoach()

      #clearTimeout(@_pollingContentTimer)

      if @uuid
        @parent.regions.header.show(new HeaderView({page: 'contents'}))
        view = new MediaView({uuid: @uuid, version: @version, page: @page, title: @title})
        @regions.contents.append(view)

        ###
        only do this if the content is coachable
        ###
        @regions.contents.$el.find('.media-footer').before(@conceptCoachButton)
        console.debug("Coach button:", @conceptCoachButton)
      else
        @parent.regions.header.show(new HeaderView({page: 'contents', url: 'content'}))
        @regions.contents.append(new BrowseContentView())

    displayChangedRemotely: () ->
      # Regions do not support a `.$el` unless `.show(view)` has been called so select the alert
      # with jQuery and unhide it.
      @$el.find('.changed-remotely-alert').removeClass('hidden')

      # Add a class to this div to hide the floating toolbar because
      # the refresh alert is now shown and they would otherwise overlap
      # TODO: This should probably be handled by editable
      @regions.contents.$el.addClass('changed-remotely')
