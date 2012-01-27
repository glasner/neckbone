{XMLHttpRequest} = require 'XMLHttpRequest'

exports.TrackedRequest = (window) ->
  window = window
  console.log 'heloo here'
  return class exports.MyTrackedRequest extends XMLHttpRequest
    constructor: (opt) ->
      console.log 'tracked request'
      console.log window.requests
      window.requests = window.requests + 1
      super
    



    
