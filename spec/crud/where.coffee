describe '#where', ->
  it 'should return zero initial records', ->
    stubResponse success: true, records: [], ->
      User.where().then (users) ->
        expect(users).to.eql([])

  it 'should return all records when they exist', ->
    records = [
      { id: 1, name: 'Nikki' }
      { id: 2, name: 'John' }
    ]

    stubResponse success: true, records: records, ->
      User.where().then (users) ->
        expect(users).to.eql(records)
