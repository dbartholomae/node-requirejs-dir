DirRequirer = require "../lib/DirRequirer"
new DirRequirer("test/files").requireAll (content, filename) ->
  console.log "Reading " + (if typeof content is 'function' then content() else content.key) +
              " from file " + filename

debug = (msg) -> console.log "Debug: " + msg
new DirRequirer("test/files", {debug: debug}).requireAll (content, filename) ->
  console.log "Reading " + (if typeof content is 'function' then content() else content.key) +
              " from file " + filename

promises = new DirRequirer().requireAll "test/files"
promises.forEach (promise) ->
  promise.done ({filename, content}) ->
    console.log "Reading " + (if typeof content is 'function' then content() else content.key) +
                " from file " + filename
