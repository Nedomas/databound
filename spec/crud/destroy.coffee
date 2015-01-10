describe '#destroy', ->
  it 'should destroy a record and return if it was successful', ->
    stubResponse {
      success: true
      scoped_records: []
    }, ->

      User.destroy(id: 2).then (success) ->
        expect(success).to.eql(true)
