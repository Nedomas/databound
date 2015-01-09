describe 'not found', ->
  describe '#find', ->
    it 'undefined id', ->
      expect(-> User.find()).to.throw(Error,
        "Databound: Couldn't find a record without an id")

    it 'non-existing id', ->
      stubResponse success: true, records: [], ->
        expect(-> User.find(1)).to.throw(Error,
          "Databound: Couldn't find record with id: 1")

  describe '#destroy', ->
    it 'undefined id', ->
      expect(-> User.destroy()).to.throw(Error,
        "Databound: Couldn't destroy a record without an id")
