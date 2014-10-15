chai = require 'chai'
expect = chai.expect

# Helpers
fakePromise = (result) ->
  then: (callback) -> callback(result)

fakeResponse = (resp) ->
  Godfather::request = ->
    fakePromise resp

# Configs
Godfather = require('../src/godfather')
Godfather.API_URL = 'http://godfatherjs-testing.com'

Godfather::promise = (result) ->
  fakePromise(result)

describe 'CRUD', ->
  User = new Godfather '/users'

  describe '#where', ->
    it 'should return zero initial records', ->
      fakeResponse([])

      User.where().then (users) ->
        expect(users).to.eql([])

    it 'should return all records when they exist', ->
      resp =[
        { id: 1, name: 'Nikki' }
        { id: 2, name: 'John' }
      ]

      fakeResponse(resp)

      User.where().then (users) ->
        expect(users).to.eql(resp)

  describe '#find', ->
    it 'should single record when it exists', ->
      resp =[
        { id: 1, name: 'Nikki' }
        { id: 2, name: 'John' }
      ]

      fakeResponse(resp)

      User.find(1).then (user) ->
        expect(user).to.eql({ id: 1, name: 'Nikki' })

    it 'should undefined when it doesnt exist', ->
      fakeResponse([])

      User.find(1).then (user) ->
        expect(user).to.eql(undefined)

  describe '#findBy', ->
    it 'should single record when it exists', ->
      resp =[
        { id: 1, name: 'Nikki' }
      ]

      fakeResponse(resp)

      User.findBy(name: 'John').then (user) ->
        expect(user).to.eql({ id: 1, name: 'Nikki' })

    it 'should undefined when it doesnt exist', ->
      fakeResponse([])

      User.findBy(name: 'John').then (user) ->
        expect(user).to.eql(undefined)
