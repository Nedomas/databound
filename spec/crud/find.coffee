describe '#find', ->
  it 'should single record when it exists', ->
    records = [
      { id: 1, name: 'Nikki' }
      { id: 2, name: 'John' }
    ]

    stubResponse success: true, records: records, ->
      User.find(1).then (user) ->
        expect(user).to.eql(id: 1, name: 'Nikki')

  it 'should undefined when it doesnt exist', ->
    stubResponse success: true, records: [], ->
      User.find(1).then (user) ->
        expect(user).to.eql(undefined)
