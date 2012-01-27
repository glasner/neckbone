{Router} = require './router'

class exports.Session
  constructor: ->
    @router = new Router
    @router.start()
