require 'coffee-script'
# stitch  = require("stitch")
express = require 'express'
jsdom = require 'jsdom'

{App} = require './app'
{TrackedRequest} = require './tracked_request'

  
new App (app) ->
  server = express.createServer()
  server.configure ->
    server.use server.router
    server.use express.static("/public")
    server.use app.browserify
    
    server.get '/test.json', (req,res) -> 
      console.log '>>> json requested'
      res.json [
        { name: 'one' }
        { name: 'two' }
      ]
    
    for route in _.keys(app.routes)
      server.get "/#{route}", (req,res) ->
        layout = '<html><head></head><body><div id="model">hey hey</div></body></html>' 
        
        window = jsdom.jsdom(layout).createWindow()
        window.requests = -1
        window.XMLHttpRequest = TrackedRequest(window)
        
        _.extend window.location, 
          href: "http://monkeywords.com/#{route}"
          pathname: "/#{route}"
        
        # trick backbone into thinking pushState works
        window.history = 
          pushState : true
        
        # TODO figure out why jquery can't be pulled from google
        # jquery = 'http://ajax.googleapis.com/ajax/libs/jquery/1.5.1/jquery.js'
        jsdom.jQueryify window, (window, $) ->
          global.window = window
          global.document = window.document
          console.log window.location
          global.navigator = { userAgent: 'server' }
          console.log window.history
          global.$ = $
          console.log 'about to call action'
          require '../example/app/src/main'
          console.log window.requests
          res.send document.innerHTML
        
        

        # jsdom.env layout, [jquery], (errors, window) -> 
        #   global.window = window
        #   global.document = window.document
        #   global.$ = window.jQuery
        #   app.router.navigate route, true
        #   res.send document.innerHTML
          # window.close() # needed to stop memory leak?
          
  console.log "Starting server on port: #{app.config.port}"
  server.listen app.config.port