chai = require 'chai'
expect = chai.expect
Databound = require('../src/databound')

# Helpers
fakePromise = (result) ->
  then: (callback) -> callback(result)

Databound.fake_responses = {}
fakeResponse = (resp, action = 'where') ->
  Databound.fake_responses[action] = resp

  Databound::request = (action, params) ->
    fakePromise Databound.fake_responses[action]

# Configs
Databound.API_URL = 'http://databound-testing.com'

Databound::promise = (result) ->
  fakePromise(result)

describe 'CRUD', ->
  User = new Databound '/users'

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
      fakeResponse
        success: true
        id: 1
        scoped_records: JSON.stringify([{ id: 1, name: 'John' }])
      , 'create'

      User.create(name: 'John').then (user) ->
        expect(user).to.eql({ id: 1, name: 'John' })

  describe '#update', ->
    it 'should update a record and return it', ->
      fakeResponse
        success: true
        id: 2
        scoped_records: JSON.stringify([{ id: 2, name: 'Peter' }])
      , 'update'

      User.update(id: 2, name: 'Peter').then (user) ->
        expect(user).to.eql({ id: 2, name: 'Peter' })

  describe '#destroy', ->
    it 'should destroy a record and return if it was successful', ->
      fakeResponse
        success: true
        scoped_records: JSON.stringify([])
      , 'destroy'

      User.destroy(id: 2).then (success) ->
        expect(success).to.eql(true)

  describe 'backend error', ->
    it 'should throw an error', ->
      fakeResponse
        success: true
        scoped_records: JSON.stringify([{ id: 2, name: 'Peter' }])
      , 'destroy'

      User.destroy(id: 2).then (success) ->
        expect(success).to.eql(true)
