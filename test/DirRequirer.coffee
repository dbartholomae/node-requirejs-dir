sinon = require('sinon')
chai = require('chai')
chai.use(require 'chai-as-promised')
chai.use(require 'sinon-chai')
expect = chai.expect

When = require 'when'

pathLib = require 'path'

path = "test/files/"
emptyPath = "test/emptyDir/"

DirRequirer = require '../lib/DirRequirer'

fileTests =
  'function.js': (content) -> expect(content).to.deep.equal "This is a String"
  'json.js': (content) -> expect(content).to.deep.equal {"key": "value"}

describe "A DirRequirer", ->

  it "can be required via requirejs", (done) ->
    expect(
            require('requirejs') [pathLib.join(__dirname, '..', 'lib/DirRequirer.js')], (loaded) ->
              expect(loaded).to.exist
              done()
    ).to.not.throw

  it "throws when no path is set", ->
    dirRequirer = new DirRequirer()
    expect(-> dirRequirer.requireAll()).to.throw "pathname should be a string, was undefined"

  it "throws when no files match and a callback is set", ->
    dirRequirer = new DirRequirer(emptyPath)
    expect(-> dirRequirer.requireAll(->)).to.throw "No file found to read"

  it "fails when no files match and no callback is set", ->
    dirRequirer = new DirRequirer(emptyPath)
    expect(dirRequirer.requireAll()).to.be.rejectedWith "No file found to read"

  describe "with a path set at construction", ->
    dirRequirer = null

    beforeEach ->
      dirRequirer = new DirRequirer path

    it "accepts and uses a debug function", ->
      debug = sinon.stub()
      new DirRequirer(path, {debug: debug}).requireAll ->
      expect(debug).to.have.been.called

    it "requires a directory via callback", (done) ->
      files = {}
      dirRequirer.requireAll (content, filename) ->
        files[filename] = true
        console.log filename
        fileTests[filename](content)
        if Object.keys(files).length == 2
          done()

    it "requires a directory via Promise", (done) ->
      When.all(dirRequirer.requireAll()).done (arr) ->
        for {content, filename} in arr
          fileTests[filename](content)
        done()

  describe "with a path given in the requireAll call", ->
    dirRequirer = null
    beforeEach ->
      dirRequirer = new DirRequirer()

    it "accepts and uses a debug function", ->
      debug = sinon.stub()
      new DirRequirer({debug: debug}).requireAll path, ->
      expect(debug).to.have.been.called

    it "requires a directory via callback", (done) ->
      files = {}
      dirRequirer.requireAll path,  (content, filename) ->
        files[filename] = true
        fileTests[filename](content)
        if Object.keys(files).length == 2
          done()

    it "requires a directory via Promise", (done) ->
      When.all(dirRequirer.requireAll(path)).done (arr) ->
        for {content, filename} in arr
          fileTests[filename](content)
        done()

