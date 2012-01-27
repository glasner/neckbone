# Template = require 'html/model'

class exports.View extends Backbone.View
  el: '#model'
  # el: []
  
  initialize: ({@collection}) ->
    @collection.bind 'reset', @render
  
  render: =>
    # @el = $('#model')[0]
    # @el = document.getElementById 'model'
    @el.innerHTML = 'monkey monkey'