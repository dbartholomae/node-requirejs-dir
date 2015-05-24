sinon = require('sinon')
chai = require('chai')
chai.use(require 'chai-as-promised')
chai.use(require 'sinon-chai')
expect = chai.expect

When = require 'when'
requirejs = require('requirejs')

requirejs.config
  baseUrl: ""
  nodeRequire: require

path = require 'path'

filesPath = "files/"
emptyDirPath = "emptyDir/"
defineAllPath = "defineAll/"

DirRequirer = require '../lib/DirRequirer'

expectedResults = {}
expectedResults[path.join 'files','function'] = "This is a String"
expectedResults[path.join 'files', 'json'] = {"key": "value"}
expectedResults[path.join 'files', 'nested', 'json'] = {"key": "anotherValue"}

describe "A DirRequirer", ->

  it "can be required via requirejs", (done) ->
    expect(
      requirejs ['lib/DirRequirer.js'], (loaded) ->
        expect(loaded).to.exist
        done()
    ).to.not.throw

  it "throws when no path is set", ->
    dirRequirer = new DirRequirer()
    expect(-> dirRequirer.requireAll()).to.throw "pathname should be a string, was undefined"
    expect(-> dirRequirer.defineAll(->)).to.throw "pathname should be a string, was undefined"

  describe "that is used to require modules", ->
    it "throws when no files match and a callback is set", ->
      dirRequirer = new DirRequirer emptyDirPath
      expect(-> dirRequirer.requireAll(->)).to.throw "No file found to read"

    it "fails when no files match and no callback is set", ->
      dirRequirer = new DirRequirer emptyDirPath
      expect(dirRequirer.requireAll()).to.be.rejectedWith "No file found to read"

    describe.skip "with a path set at construction", ->
      dirRequirer = null

      beforeEach ->
        dirRequirer = new DirRequirer filesPath

      it "accepts and uses a debug function", ->
        debug = sinon.stub()
        new DirRequirer(filesPath, {debug: debug}).requireAll ->
        expect(debug).to.have.been.called

      it "requires a directory via callback", (done) ->
        files = {}
        dirRequirer.requireAll (content, filename) ->
          files[filename] = true
          expect(content).to.deep.equal expectedResults[filename]
          if Object.keys(files).length is Object.keys(expectedResults).length
            done()

      it "requires a directory via Promise", (done) ->
        When.all(dirRequirer.requireAll()).done (arr) ->
          expect(arr.length).to.equal Object.keys(expectedResults).length
          for {content, filename} in arr
            expect(content).to.deep.equal expectedResults[filename]
          done()

    describe "with a path given in the requireAll call", ->
      dirRequirer = null
      beforeEach ->
        dirRequirer = new DirRequirer({debug: console.log})

      it "accepts and uses a debug function", ->
        debug = sinon.stub()
        new DirRequirer({debug: debug}).requireAll filesPath, ->
        expect(debug).to.have.been.called

      it "requires a directory via callback", (done) ->
        files = {}
        dirRequirer.requireAll filesPath,  (content, filename) ->
          files[filename] = true
          expect(content).to.deep.equal expectedResults[filename]
          if Object.keys(files).length is Object.keys(expectedResults).length
            done()

      it.skip "requires a directory via Promise", (done) ->
        When.all(dirRequirer.requireAll(filesPath)).done (arr) ->
          expect(arr.length).to.equal Object.keys(expectedResults).length
          for {content, filename} in arr
            expect(content).to.deep.equal expectedResults[filename]
          done()

  describe.skip "that is used to define a module", ->
    describe "with a path set at construction", ->
      it "requires a directory", (done) ->
        requirejs [defineAllPath + 'fn'], (modules) ->
          expect(Object.keys(modules[0]).length).to.equal Object.keys(expectedResults).length
          for filename, content of modules[0]
            expect(content).to.deep.equal expectedResults[filename]
          done()

      it "requires a directory with an additional dependency", (done) ->
        requirejs [defineAllPath + 'fnDeps'], (modules) ->
          expect(Object.keys(modules[0]).length).to.equal Object.keys(expectedResults).length
          for filename, content of modules[0]
            expect(content).to.deep.equal expectedResults[filename]
          expect(modules[1]).to.equal "Data"
          done()

    describe.skip "with a path given in the defineAll call", ->
      it "requires a directory", (done) ->
        requirejs [defineAllPath + 'fnPath'], (modules) ->
          expect(Object.keys(modules[0]).length).to.equal Object.keys(expectedResults).length
          for filename, content of modules[0]
            expect(content).to.deep.equal expectedResults[filename]
          done()

      it "requires a directory with an additional dependency", (done) ->
        requirejs [defineAllPath + 'fnPathDeps'], (modules) ->
          expect(Object.keys(modules[0]).length).to.equal Object.keys(expectedResults).length
          for filename, content of modules[0]
            expect(content).to.deep.equal expectedResults[filename]
          expect(modules[1]).to.equal "Data"
          done()
