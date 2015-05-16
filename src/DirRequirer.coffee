((modules, factory) ->
# Use define if amd compatible define function is defined
  if typeof define is 'function' && define.amd
    define modules, factory
# Use node require if not
  else
    module.exports = factory (require m for m in modules)...
)( ['requirejs', 'fs-readdir-recursive', 'path', 'when'], (requirejs, readDir, path, When) ->

  # A class that recursively requires all files in a directory with requirejs
  # and calls a callback for each of its contents
  #
  # @example Minimal usage
  #    new DirRequirer("server/lib/routes").requireAll (route) ->
  #      router.use route
  # @example With a debug logger
  #    new DirRequirer("server/lib/routes", {debug: debug}).requireAll (route, filename) ->
  #      debug "Successfully required file " + filename
  #      router.use route
  class DirRequirer
    # Create a new DirRequirer
    # @param [String] pathname The pathname of the directory to scan, relative to the cwd
    # @param [Object] (options) An optional set of options
    # @option options [Function] debug A function for debugging. It is called with useful messages.
    constructor: (@pathname, @options) ->
      if typeof @pathname is 'object'
        @options = @pathname
      @options ?= {}
      @options.debug ?= ->
      @options.extensions = ['js']

      @debug = @options.debug
    # Require all files from the set directory and call the callback for each of them.
    # The callback is called as callback(module, filename) with module being the result from
    # requirejs and filename being the filename.
    # If no callback is given, it returns an Array of promises for objects of the form
    # {
    #   filename: ""
    #   content: {}
    # }
    # instead.
    # If there is no file in the directory that matches the extensions set in the constructor,
    # the callback will never be called and instead an error is thrown or a failing promise is returned.
    #
    # @param [String] (pathname) The pathname of the directory to scan, relative to the cwd
    # @param [Function] (callback) The callback to be called
    # @throw {Error} No files found to read
    # @throw {TypeError} pathname should be a string, was {pathname}
    requireAll: (pathname, callback) ->
      if typeof pathname is 'function'
        callback = pathname
        pathname = undefined
      pathname ?= @pathname

      throw new TypeError "pathname should be a string, was " + pathname unless typeof pathname is 'string'

      dir = path.join path.resolve path.dirname(), pathname
      @debug "Reading routes from " + dir
      promises = []
      anyFileRead = false
      for filename in readDir dir
        @debug "Assessing file " + filename + " with extname " + path.extname(filename)[1..] +
                        " and basename " + path.basename(filename)
        if path.extname(filename)[1..] in @options.extensions
          do (filename) =>
            @debug "Trying to load file " + filename
            anyFileRead = true
            if callback?
              requirejs [path.join dir, filename], (content) ->
                callback content, filename
            else
              promises.push When.promise (resolve) ->
                requirejs [path.join dir, filename], (content) ->
                  resolve
                    filename: filename
                    content: content

      unless anyFileRead
        if callback
          throw new Error "No file found to read"
        else
          return When.reject new Error "No file found to read"

      return promises unless callback
)