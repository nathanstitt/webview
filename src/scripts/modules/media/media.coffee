define (require) ->
  $ = require('jquery')
  linksHelper = require('cs!helpers/links')
  router = require('cs!router')
  analytics = require('cs!helpers/handlers/analytics')
  Content = require('cs!models/content')
  BaseView = require('cs!helpers/backbone/views/base')
  MainPageView = require('cs!modules/main-page/main-page')

  ContentsView = require('cs!modules/media/tabs/contents/contents')

  MediaEndorsedView = require('cs!./endorsed/endorsed')
  LatestView = require('cs!./latest/latest')
  MediaTitleView = require('cs!./title/title')
  MediaNavView = require('cs!./nav/nav')
  MediaHeaderView = require('cs!./header/header')
  WindowWithSidebarView = require('cs!modules/window-with-sidebar/window-with-sidebar')
  MediaBodyView = require('cs!./body/body')
  MediaFooterView = require('cs!./footer/footer')

  template = require('hbs!./media-template')
  require('less!./media')

  return class MediaView extends BaseView
    key = []
    canonical: () ->
      uuid = @model.getUuid()
      if uuid
        return "//#{location.host}/contents/#{uuid}/"
      else
        return null

    template: template
    regions:
      media: '.media'
      pinnable: '.pinnable'
      #editbar: '.editbar'

    summary:() -> @updateSummary()
    description: () -> @updateDescription()

    #events:
      #'keydown .media-title > .title input': 'checkKeySequence'
      #'keyup .media-title > .title input': 'resetKeySequence'

    initialize: (options) ->
      super()

      if not options or not options.uuid
        throw new Error('A media view must be instantiated with the uuid of the media to display')

      @uuid = options.uuid
      @model = new Content({id: @uuid, version: options.version, page: options.page})
      @minimal = options.minimal

      @listenTo(@model, 'change:googleAnalytics', @trackAnalytics)
      @listenTo(@model, 'change:title change:parent.id', @updatePageInfo)
      if not @minimal
        @listenTo(@model, 'change:legacy_id change:legacy_version change:currentPage
          change:currentPage.loaded', @updateLegacyLink)
      @listenTo(@model, 'change:error', @displayError)
      #@listenTo(@model, 'change:editable', @toggleEditor)
      @listenTo(@model, 'change:title change:currentPage change:currentPage.loaded', @updateUrl)
      @listenTo(@model, 'change:title change:currentPage change:currentPage.loaded', @updatePageInfo)
      @listenTo(@model, 'change:abstract', @updateSummary)

    onRender: () =>
      @regions.media.append(new MediaEndorsedView({model: @model}))
      @regions.media.append(new LatestView({model: @model}))
      mediaTitleView = new MediaTitleView({model: @model})
      navView = new MediaNavView({model: @model})
      windowWithSidebar = new WindowWithSidebarView()
      tocView = new ContentsView({model: @model})
      footerNav = new MediaNavView({model: @model, hideProgress: true, mediaParent: @})
      @regions.pinnable.append(mediaTitleView)
      @regions.pinnable.append(navView)
      @regions.media.append(windowWithSidebar)
      mainPage = new MainPageView()
      windowWithSidebar.regions.main.append(mainPage)
      mainPage.regions.main.append(new MediaHeaderView({model: @model}))
      windowWithSidebar.regions.sidebar.append(tocView)
      mediaBodyView = new MediaBodyView({model: @model})
      mainPage.regions.main.append(mediaBodyView)
      mainPage.regions.main.append(new MediaFooterView({model: @model}))
      mainPage.regions.main.append(footerNav)
      footerNav.$el.addClass('footer-nav')
      @mainContent = windowWithSidebar.regions.main

      $pinnable = @regions.pinnable.$el
      pinnableTop = $pinnable.offset().top
      $titleArea = -> mediaTitleView.$el.find('.media-title')
      $toc = tocView.$el
      isPinned = false
      setTocHeight = ->
        tocTop = $pinnable.height()
        if not isPinned
          tocTop += $pinnable.offset().top
        $toc.css('top', "#{tocTop}px")
        newHeight = window.innerHeight - tocTop
        $toc.height("#{newHeight}px")
      adjustMainMargin = (height) ->
        mainPage.regions.main.$el.css('margin-top', "#{height}px")
      pinNavBar = ->
        $pinnable.addClass('pinned')
        $titleArea().addClass('compact')
        $toc.addClass('pinned')
        isPinned = true
        adjustMainMargin($pinnable.height())
      unpinNavBar = ->
        $pinnable.removeClass('pinned')
        $titleArea().removeClass('compact')
        $toc.removeClass('pinned')
        isPinned = false
        adjustMainMargin(0)
        pinnableTop = $pinnable.offset().top
      mediaTitleView.on('render', ->
        if isPinned
          $titleArea().addClass('compact')
      )

      Backbone.on('window:optimizedResize', setTocHeight)
      handleHeaderViewPinning = ->
        top = $(window).scrollTop()
        if top > pinnableTop
          if not isPinned
            pinNavBar()
        else if isPinned
          unpinNavBar()
        setTocHeight()

      Backbone.on('window:optimizedScroll', handleHeaderViewPinning)
      navView.on('tocIsOpen', (whether) ->
        windowWithSidebar.open(whether)
        # On small screens, when the contents is opened,
        # auto-scroll to make header minimize
        if window.innerWidth < 640 and whether
          top = $(window).scrollTop()
          if top < pinnableTop
            $(window).scrollTop(pinnableTop + 10)
        setTocHeight()
        )
      wasPinnedAtChange = false
      @model.on('change:currentPage', ->
        wasPinnedAtChange = isPinned
      )
      mediaBodyView.on('render', ->
        scrollTo = if wasPinnedAtChange then pinnableTop + 1 else 0
        $(window).scrollTop(scrollTo)
      )

    updateSummary: () ->
      abstract = @model.get('abstract')
      if abstract
        return $("<div>#{abstract}</div>").text()
      else
        return 'An OpenStax CNX book'

    updateDescription: () ->
      if @model.get('currentPage')?.get('abstract')? and
      @model.get('currentPage').get('abstract').replace(/(<([^>]+)>)/ig, "") isnt ''
        # regular expression to strip tags
        return @model.get('currentPage').get('abstract').replace(/(<([^>]+)>)/ig, "")
      else
        return @updateSummary()

    updateUrl: () ->
      components = linksHelper.getCurrentPathComponents()
      components.version = "@#{components.version}" if components.version
      title = linksHelper.cleanUrl(@model.get('title'))
      qs = components.rawquery

      if title isnt components.title and not @model.isBook()
        router.navigate("contents/#{components.uuid}#{components.version}/#{title}#{qs}", {replace: true})

    trackAnalytics: () ->
      # Track loading using the media's own analytics ID, if specified
      analyticsID = @model.get('googleAnalytics')
      analytics.send(analyticsID) if analyticsID

    updatePageInfo: () ->
      @pageTitle = @model.get('title')
      super()

    updateLegacyLink: () ->
      headerView = @parent.parent.regions.header.views?[0]
      return unless headerView?
      id = @model.get('legacy_id')
      version = @model.get('legacy_version')

      if @model.isBook()
        currentPage = @model.asPage()
        if currentPage
          pageId = currentPage.get('legacy_id')
          pageVersion = currentPage.get('legacy_version')
          if pageId and pageVersion
            headerView.setLegacyLink("content/#{pageId}/#{pageVersion}/?collection=#{id}/#{version}")
        return

      headerView.setLegacyLink("content/#{id}/#{version}") if id and version

    displayError: () ->
      error = arguments[1] # @model.get('error')
      router.appView.render('error', {code: error}) if error

    toggleEditor: () -> if @editing then @closeEditor() else @loadEditor()

    # FIX: How much of loadEditor and closeEditor can be merged into the editbar?
    loadEditor: () ->
      return
      #@editing = true

      #require ['cs!./editbar/editbar'], (EditbarView) =>
      #  @regions.editbar.show(new EditbarView({model: @model}))
      #  height = @regions.editbar.$el.find('.navbar').outerHeight()
      #  $('body').css('padding-top', height) # Don't cover the page header
      #  window.scrollBy(0, height) # Prevent viewport from jumping

    closeEditor: () ->
      return
      #@editing = false
      #height = @regions.editbar.$el.find('.navbar').outerHeight()
      #@regions.editbar.empty()
      #$('body').css('padding-top', '0') # Remove added padding
      #window.scrollBy(0, -height) # Prevent viewport from jumping

    onBeforeClose: () ->
      return
      #if @model.get('editable')
      #  @model.set('editable', false, {silent: true})
      #  @closeEditor()

    checkKeySequence: (e) ->
      return
      #key[e.keyCode] = true
      #ctrl+alt+shift+l+i
      #if key[16] and key[17] and key[18] and key[73] and key[76]
      #  if @model.get('canChangeLicense') or @model.get('derivedFrom') is null
      #    $('#license-modal').modal('show')

    resetKeySequence: (e) ->
      return
      #key[e.keyCode] = false
