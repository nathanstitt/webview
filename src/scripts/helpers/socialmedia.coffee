define (require) ->
  _ = require('underscore')

  return new class SocialMedia

    socialMediaInfo: (description,title,locationOrigin) ->
      url = window.location.href
      image = locationOrigin + '/images/logo.png'
      share =
        url: url
        source: 'OpenStax CNX'
        via: 'cnxorg'
        summary: description
        title: title
        image: image
        # Encode all of the shared values for a URI
      _.each share, (value, key, list) ->
        list[key] = encodeURI(value)
