define (require) ->
  $ = require('jquery')
  router = require('cs!router')
  BaseView = require('cs!helpers/backbone/views/base')
  template = require('hbs!./donation-slider-template')
  require('less!./donation-slider')

  donation = ['0', '5', '10', '15', '20', '25', '50', '75', '100', '250', '500', '1,000', '2,500', '5,000', '10,000']
  message = [
    'Free makes me happy'
    'Abe Lincoln would be proud'
    'OpenStax CNX is a ten in my book (suggested donation)'
    'Thanks for saving me hundreds of dollars!'
    'My ATM wants you to have this'
    'Abe Lincoln would be proud (and amazed by ATMs)'
    'Hey OpenStax, give a printed copy to a school in need'
    'Here\'s something to help keep these books free!'
    'Giving back never felt so good'
    'On me: fill a school library with your books!'
    'Go buy yourself a fancy new translation!'
    'The next section of an OpenStax book is on me!'
    'The next chapter of an OpenStax book is on me!'
    'Bill Gates II, at your service'
    'WOWWWWWW!!!!'
  ]

  return class DonateSliderView extends BaseView
    template: template
    templateHelpers:
      value: () -> @value
      donation: () -> donation[@value]
      message: () -> message[@value]

    value: 2 # Default donation setting

    events:
      'change input[type="range"]': 'changeDonation'
      'submit form': 'onSubmit'
    
    initialize: (options = {}) ->
      super()
      @uuid = options.uuid
      @type = options.type or 'pdf'

    changeDonation: (e) ->
      @value = $(e.currentTarget).val()
      @render()

    onSubmit: (e) ->
      e.preventDefault()

      amount = donation[@$el.find('input[name="donation"]').val()]
      url = "/donate/form?amount=#{amount}"
      url += "&uuid=#{@uuid}&type=#{@type}" if @uuid and @type
      router.navigate(url, {trigger: true})
