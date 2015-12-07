define (require) ->
  _ = require('underscore')
  TocDraggableView = require('cs!./draggable')
  TocPageView = require('cs!./page')
  SectionNameModal = require('cs!./modals/section-name/section-name')
  linksHelper = require('cs!helpers/links.coffee')
  router = require('cs!router')
  template = require('hbs!./section-template')
  require('less!./section')

  return class TocSectionView extends TocDraggableView
    template: template
    templateHelpers:
      editable: -> @editable
      visible: ->
        @model.get('visible')
    itemViewContainer: '> ul'

    events:
      'click > div > .section-wrapper': 'toggleSection'
      'keydown > div > .section-wrapper': 'toggleSectionWithKeyboard'
      'click > div > .remove': 'removeNode'
      'click > div > .edit': 'editNode'

    initialize: () ->
      return unless @model
      @content = @model.get('book') or @model
      @editable = @content.get('editable')
      @regions =
        container: @itemViewContainer
      @sectionNameModal = new SectionNameModal({model: @model})
      super()
      @listenTo(@model, 'add change:unit change:title change:expanded sync:contents', @render)
      @listenTo(@content, 'change:currentPage', @updateActiveContainer)
      @listenTo(@model, 'change:activeContainer', @handleActiveContainer)

    handleActiveContainer: ->
      isActive = @model.get('activeContainer')
      hasClass = @$el.hasClass('active-container')
      return if isActive? and hasClass
      if isActive
        @$el.addClass('active-container')
      else
        @$el.removeClass('active-container')

    onRender: () ->
      @handleActiveContainer()
      return if @model.get('visible') == false
      super()
      return unless @regions
      @regions.container.empty()
      nodes = @model.get('contents')?.models
      _.each nodes, (node) =>
        if node.get('visible')
          if node.isSection()
            @regions.container.appendAs 'li', new TocSectionView
              model: node
          else
            @regions.container.appendAs 'li', new TocPageView
              model: node
              collection: @model

    updateActiveContainer: ->
      isCurrentActive = @model.get('activeContainer')
      page = @content.get('currentPage')
      containers = page.containers()
      shouldBeActive = containers.indexOf(@model) >= 0
      return if isCurrentActive? == shouldBeActive
      if shouldBeActive
        @model.set('activeContainer', true)
      else
        @model.unset('activeContainer')

    toggleSection: () ->
      @model.set('expanded', not @model.get('expanded'))

    toggleSectionWithKeyboard: (e) ->
      if e.keyCode is 13 or e.keyCode is 32
        e.preventDefault()
        @toggleSection()
        @$el.find('> div > .section-wrapper').focus()

    removeNode: () ->
      @content.removeNode(@model)

    editNode: () ->
      @regions.self.appendOnce
        view: @sectionNameModal
        as: 'div id="section-name-modal" class="modal fade"'
      @sectionNameModal.promptForValue(
        @model.attributes.title
        (newValue) =>
          @model.set('title', newValue)
          @model.set('changed', true)
          @model.get('book').set('childChanged', true)
          @model.get('book').set('changed', true))
      @sectionNameModal.$el.modal('show')
