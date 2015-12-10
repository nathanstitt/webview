define (require) ->
  _ = require('underscore')
  session = require('cs!session')
  settings = require('settings')
  linksHelper = require('cs!helpers/links')
  router = require('cs!router')
  EditableView = require('cs!helpers/backbone/views/editable')
  BookPopoverView = require('cs!./popovers/book/book')
  template = require('hbs!./header-template')
  require('less!./header')

  return class MediaHeaderView extends EditableView
    media: 'page'

    template: template
    templateHelpers: () ->
      currentPage = @getModel()

      if currentPage
        currentPage = currentPage.toJSON()
        currentPage.encodedTitle = encodeURI(currentPage.title)
      else
        currentPage = {
          title: 'Untitled'
          encodedTitle: 'Untitled'
          authors: []
        }

      downloads = @model.get('downloads')
      pageDownloads = currentPage?.get?('downloads')
      chapter = currentPage.chapter ? currentPage._parent?.get('chapter') ? ''

      return {
        currentPage: currentPage
        chapter: chapter
        pageTitle: currentPage.searchTitle ? currentPage.title
        hasDownloads: (_.isArray(downloads) and downloads?.length) or
          (_.isArray(pageDownloads) and pageDownloads?.length)
        derivable: @isDerivable()
        authenticated: session.get('id')
        editable: @isEditable()
      }

    isEditable: () ->
      if @model.asPage()?.get('loaded') and @model.isDraft()
        edit = @model.asPage()?.get('canPublish')
        if edit isnt undefined and edit.toString().indexOf(session.get('id')) >= 0 and not @model.asPage()?.isDraft()
          @model.set('canChangeLicense', true)
          return true

    isDerivable: () ->
      if @model.asPage()?.get('loaded') and @model.isDraft()
        canEdit = @model.asPage()?.get('canPublish')
        if canEdit isnt undefined and canEdit.toString().indexOf(session.get('id')) < 0
          if @model.get('license')?.code isnt settings.defaultLicense.code
            @model.set('canChangeLicense', false)
          else
            @model.set('canChangeLicense', true)
          return true

    editable:
      '.media-header > .title > h2':
        value: () -> 'title'
        type: 'textinput'

    regions:
      button: '.info .btn'

    events:
      'click .summary': 'toggleSummary'
      'click .derive .btn': 'derivePage'
      'click .edit .btn' : 'editPage'

    initialize: () ->
      super()

      @listenTo(@model, 'change:downloads change:buyLink change:title change:active', @render)
      @listenTo(@model, 'change:currentPage change:currentPage.active change:currentPage.loaded', @render)
      @listenTo(@model, 'change:abstract change:currentPage.abstract', @render)
      @listenTo(session, 'change', @render)
      @listenTo(@model, 'change:currentPage.editable change:currentPage.canPublish', @render)
      @listenTo(@model, 'change:currentPage', @updateTitle)
      @listenTo(router, 'navigate', @updatePageInfo)
      @listenTo(@model, 'change:currentPage.searchTitle', @render)

    onRender: () ->
      if not @model.asPage()?.get('active') then return

      # IE doesn't like it being inside the button. Move it out.
      popoverView = new BookPopoverView
        model: @model
        owner: @$el.find('.info .btn')
      @regions.button.append popoverView
      popoverView.$el.insertAfter(popoverView.$el.parent())

    toggleSummary: (e) ->
      e.preventDefault()
      $summary = @$el.find('.summary')
      $summary.find('h5').toggleClass('active')
      @$el.find('.abstract').toggle()

    editPage: () ->
      data = JSON.stringify({id: @model.asPage().get('id')})
      options =
        success: (model) =>
          @model.asPage()?.set('version', 'draft')
          @model.asPage()?.set('editable', true)
          href = linksHelper.getPath 'contents',
            model: @model
            page: @model.getPageNumber()
          router.navigate(href, {trigger: false, analytics: true})
      @model.editOrDeriveContent(options, data)

    derivePage: () ->
      options =
        success: (model) =>
          @model.setPage(@model.getPageNumber(model))
          # Update the url bar path
          href = linksHelper.getPath 'contents',
            model: @model
            page: @model.getPageNumber()
          router.navigate(href, {trigger: false, analytics: true})

      @model.deriveCurrentPage(options)

    updateTitle: () ->
      @pageTitle = @model.get('title')
      if @model.asPage()?
        @pageTitle = "#{@model.get('currentPage').get('title')} - #{@model.get('title')}"
