describe '#create', ->
  it 'should create a record and return it', ->
    stubResponse {
      success: true
      id: 1
      scoped_records: [{ id: 1, name: 'John' }]
    }, ->

      User.create(name: 'John').then (user) ->
        expect(user).to.eql(id: 1, name: 'John')
