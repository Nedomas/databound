describe '#update', ->
  it 'should update a record and return it', ->
    stubResponse {
      success: true
      id: 2
      scoped_records: [{ id: 2, name: 'Peter' }]
    }, ->

      User.update(id: 2, name: 'Peter').then (user) ->
        expect(user).to.eql(id: 2, name: 'Peter')
