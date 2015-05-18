# node-requirejs-dir@1.1.0
The **node-requirejs-dir** is a Node module to recursively require files from a directory with RequireJS.

```coffeescript
new DirRequirer("server/lib/routes").requireAll (route) ->
  router.use route
```

```coffeescript
new DirRequirer("configDir").defineAll ['path'], (dir, path) ->
  config = {}
  for filename, content of dir
    config[path.basename filename] = content
  return config
```

## API

The module can be required via node's require, or as an AMD module via requirejs. You can either set the path
at construction via `new DirRequirer(path)` or in the `requireAll` or `defineAll` call.
The constructor takes a function as second parameter that is called with useful debug information:
```coffeescript
new DirRequirer("server/lib/routes", debug).requireAll (route, filename) ->
  debug "Successfully required file " + filename
  router.use route
```

There is a [codo][codo] created documentation in the doc folder with more details.

### requireAll

You can either set the path at construction via `new DirRequirer(path)` or when reading the file
via `new DirRequirer().requireAll(path)`. You can either wait for a callback as in the example above
or receive a promise (powered by [when][when]):
```coffeescript
promises = new DirRequirer().requireAll "server/lib/routes"
promises.forEach (promise) ->
  promise.done ({filename, content}) ->
    console.log "Using route " + filename
    router.use content
```

### defineAll

`defineAll` loads all modules in a directory as dependencies as well as potentially more dependencies.

## Todos

This probably should be done as a requirejs plugin instead.

[when]: https://github.com/cujojs/when
[codo]: https://github.com/coffeedoc/codo