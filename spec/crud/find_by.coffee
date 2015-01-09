describe '#findBy', ->
  it 'should single record when it exists', ->
    records =[
      { id: 1, name: 'Nikki' }
    ]

    stubResponse success: true, records: records, ->
      User.findBy(name: 'Nikki').then (user) ->
        expect(user).to.eql(id: 1, name: 'Nikki')

  it 'should undefined when it doesnt exist', ->
    stubResponse success: true, records: [], ->
      User.findBy(name: 'John').then (user) ->
        expect(user).to.eql(undefined)
