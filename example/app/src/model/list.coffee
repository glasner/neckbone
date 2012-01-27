{Model} = require '../model'
class exports.ModelList extends Backbone.Collection
  model: Model
  url: '/test.json'
  