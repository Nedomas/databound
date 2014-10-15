chai = require 'chai'
expect = chai.expect
Godfather = require('../src/godfather')

# Helpers
fakePromise = (result) ->
  then: (callback) -> callback(result)

Godfather.fake_responses = {}
fakeResponse = (resp, action = 'where') ->
  Godfather.fake_responses[action] = resp

  Godfather::request = (action, params) ->
    fakePromise Godfather.fake_responses[action]

# Configs
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

  describe '#create', ->
    it 'should create a record and return it', ->
      fakeResponse({ success: true, id: 1 }, 'create')
      fakeResponse([{ id: 1, name: 'John' }], 'where')

      User.create(name: 'John').then (user) ->
        expect(user).to.eql({ id: 1, name: 'John' })

  describe '#update', ->
    it 'should update a record and return it', ->
      fakeResponse({ success: true, id: 2 }, 'update')
      fakeResponse([{ id: 2, name: 'Peter' }], 'where')

      User.update(id: 2, name: 'Peter').then (user) ->
        expect(user).to.eql({ id: 2, name: 'Peter' })

  describe '#destroy', ->
    it 'should destroy a record and return if it was successful', ->
      fakeResponse([{ id: 2, name: 'Peter' }], 'where')
      fakeResponse({ success: true }, 'destroy')

      User.destroy(id: 2).then (success) ->
        expect(success).to.eql(true)

  describe 'backend error', ->
    it 'should throw an error', ->
      fakeResponse([{ id: 2, name: 'Peter' }], 'where')
      fakeResponse({ success: true }, 'destroy')

      User.destroy(id: 2).then (success) ->
        expect(success).to.eql(true)
