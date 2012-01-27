fs = require 'fs'
path = require 'path'
yaml = require 'js-yaml'
browserify = require 'browserify'

# setup globally so they can be accessed while browserify is packaging app
global.jQuery = require 'jquery'
global._ = require 'underscore'
global.Backbone = require 'backbone'

{Router} = require '/Users/glasner/code/neckbone/example/app/src/router'

## App
class exports.App
  # default options for @config
  @defaults:
    srcPath: 'app/src'
    htmlPath: 'app/html'
    libPath: 'lib'
    port: 9294
  
  # given callback will be passed App instance  
  constructor: (callback) ->
    fs.readFile 'app/config.yaml', 'utf8', (err,data) =>
      @config = _.defaults yaml.load(data), @constructor.defaults
      @routes = Router.prototype.routes
      @browserify = browserify
        entry: __dirname + '/../example/app/src/main.coffee'
        # watch: true
        mount: '/js/app.js'
      @prependDependencies callback
  
  
  
  
  # prepends src of dependencies to @browserify bundle    
  prependDependencies: (callback) ->
    # called from addFile when all readfile callbacks have fired
    finish = (dependencies) =>
      app = @
      # returns module as string for prepending to bundle 
      src = (name) -> require.resolve(name)
      fs.readFile src('underscore'), 'utf8', (err,underscore) ->
        fs.readFile src('backbone'), 'utf8', (err,backbone) ->
          dependencies.unshift underscore, backbone
          app.browserify.prepend dependencies
          callback app
    
    dependencies = []
    dependencyCount = 0  
    # used as callback when file is read
    addFile = (err,data) ->
      dependencies.push data
      dependencyCount -= 1 
      finish(dependencies) if dependencyCount is 0
    
    # read files async with addFile as callback
    @sortDependencies (files) ->
      dependencyCount = files.length
      for name in files
        fs.readFile name, addFile
  
  ## Dependencies
  # passes sorted array of filenames to given callback
  # 1. auto inserts underscore and backbone
  # 2. lib files listed in config.dependencies
  # 3. finally all remaining lib files
  sortDependencies: (callback) ->
    path = @config.libPath
    dependencies = @config.dependencies
    fs.readdir path, (err,files) ->
      lib = _.sortBy files, (file) -> 
        index = _.indexOf dependencies, file
        if index is -1 then 1000 else index
      lib = _.map lib, (file) -> "#{path}/#{file}"
      callback lib

  # returns path for filename for given type  
  pathFor: (type,file) ->
    switch type
      when 'npm' then path.resolve(require.resolve(file), '..') + "/#{file}.js"
      when 'lib' then "lib/#{file}"
      
      
  