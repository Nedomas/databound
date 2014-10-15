Godfather = require('../src/godfather')

# Helpers
fakePromise = (result) ->
  then: (callback) -> callback(result)

# Configs
Godfather.API_URL = 'http://godfatherjs-testing.com'
Godfather::promise = (result) ->
  fakePromise(result)

chai = require 'chai'
expect = chai.expect

describe 'CRUD', ->
  User = new Godfather '/users'

  describe '#where', ->
    it 'should return zero initial records', ->
      Godfather::request = (result) ->
        fakePromise []

      User.where().then (users) ->
        expect(users).to.eql([])

    it 'should return some records when they exist', ->
      server_resp =[
        { id: 1, name: 'Nikki' }
        { id: 2, name: 'John' }
      ]

      Godfather::request = (result) ->
        fakePromise server_resp

      User.where().then (users) ->
        expect(users).to.eql(server_resp)
