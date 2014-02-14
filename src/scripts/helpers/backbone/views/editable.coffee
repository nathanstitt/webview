define (require) ->
  $ = require('jquery')
  _ = require('underscore')
  BaseView = require('cs!helpers/backbone/views/base')

  observerConfig =
    subtree: true
    childList: true
    characterData: true

  return class EditableView extends BaseView
    initialize: () ->
      super()
      @observers = {}

      @listenTo(@model, 'change:editable', @_toggleEditable)

    onAfterRender: () ->
      # Make editable after rendering if editable flag is already set
      @_makeEditable() if @model.get('editable')

    onBeforeEditable: () -> # noop
    onBeforeUneditable: () -> # noop
    onEditable: () -> # noop
    onUneditable: () -> # noop

    _toggleEditable: () ->
      if @model.get('editable')
        @_makeEditable()
      else
        @_makeUneditable()

    _makeEditable: () ->
      @onBeforeEditable()

      if @editable
        _.each @editable, (options = {}, selector) =>
          $editable = @$el.find(selector)

          if typeof options.value is 'function'
            value = options.value.apply(@)
          else
            value = options.value

          setChanged = () =>
            page = @model.get('currentPage')
            @model.set('changed', true)
            page.set('changed', true) if /^currentPage\./.test(value)

          options.onBeforeEditable?($editable)

          switch options.type
            when 'contenteditable'
              $editable.attr('contenteditable', true)

              $editable.each (index) =>
                if @observers[selector] then @observers[selector].disconnect()

                @observers[selector] = new MutationObserver (mutations) =>
                  mutations.forEach (mutation) =>
                    setChanged()
                    @model.set(value, $($editable.get(index)).html())

                @observers[selector].observe($editable.get(index), options.config or observerConfig)

            when 'aloha' then console.log 'FIX: enable aloha'

            when 'select2'
              require ['select2'], (select2) =>
                $editable.select2(options?.select2 or {})

                $editable.off 'change.editable'
                $editable.on 'change.editable', (e) =>
                  setChanged()
                  @model.set(value, $editable.select2('val'))

          options.onEditable?($editable)

      @onEditable()

    _makeUneditable: () ->
      @onBeforeUneditable()

      if @editable
        _.each @editable, (options, selector) =>
          $editable = @$el.find(selector)

          options.onBeforeUneditable?($editable)

          switch options.type
            when 'contenteditable'
              $editable.attr('contenteditable', false)
              @observers[selector].disconnect()
              delete @observers[selector]

            when 'aloha' then console.log 'FIX: disable aloha'

            when 'select2'
              $editable.off 'change.editable'

          options.onUneditable?($editable)

      @onUneditable()
