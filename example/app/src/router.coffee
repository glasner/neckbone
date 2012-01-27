{ModelList} = require './model/list'
{View} = require './model/view'

class exports.Router extends Backbone.Router
  routes:
    'one' : 'oneAction'
    
  oneAction: ->
    console.log 'in the action'
    
    try
      collection = new ModelList
      view = new View {collection}
      collection.fetch()
    catch err
      console.log err
    
  start: ->
    Backbone.history.start pushState: true
    # @navigate 'one', true
    