DirRequirer = require "../lib/DirRequirer"

new DirRequirer("../test/files").requireAll (content, filename) ->
  console.log "Reading " + content + " from file " + filename

debug = (msg) -> console.log "Debug: " + msg
new DirRequirer("../test/files", {debug: debug}).requireAll (content, filename) ->
  console.log "Reading " + content + " from file " + filename

promises = new DirRequirer().requireAll "../test/files"
promises.forEach (promise) ->
  promise.done ({filename, content}) ->
    console.log "Reading " + content + " from file " + filename

requirejs = require 'requirejs'
requirejs.config
  baseUrl: '../test'

requirejs ['defineAll/fnDeps'], (results) ->
  console.log results

