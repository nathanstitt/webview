define (require) ->
  cc = require('OpenStaxReactComponents')
  cc.init('http://localhost:3001')

  # cc.on('user.change', ->
  #   cc.open(mainDiv)
  # )
  return (node, data) ->
    cc.open(node.parentNode, collectionUUID: 'd52e93f4-8653-4273-86da-3850001c0786', moduleUUID: '0c917d7d-0d1d-4a21-afbe-7d66bce2782c')
