describe 'CRUD', ->
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

  describe '#create', ->
    it 'should create a record and return it', ->
      stubResponse {
        success: true
        id: 1
        scoped_records: [{ id: 1, name: 'John' }]
      }, ->

        User.create(name: 'John').then (user) ->
          expect(user).to.eql(id: 1, name: 'John')

  describe '#update', ->
    it 'should update a record and return it', ->
      stubResponse {
        success: true
        id: 2
        scoped_records: [{ id: 2, name: 'Peter' }]
      }, ->

        User.update(id: 2, name: 'Peter').then (user) ->
          expect(user).to.eql(id: 2, name: 'Peter')

  describe '#destroy', ->
    it 'should destroy a record and return if it was successful', ->
      stubResponse {
        success: true
        scoped_records: []
      }, ->

        User.destroy(id: 2).then (success) ->
          expect(success).to.eql(true)

  describe 'error', ->
    describe 'request was killed by unrescued error', ->
      it 'does not return a hash', ->
        stubResponse null, ->

          expect(-> User.find(name: 'John')).to.throw(Error, 'Error in the backend')

      it '#find', ->
        stubResponse {
          success: false
          scoped_records: []
        }, ->

          expect(-> User.find(name: 'John')).to.throw(Error, 'Error in the backend')

      it '#findBy', ->
        stubResponse {
          success: false
          scoped_records: []
        }, ->

          expect(-> User.findBy(name: 'John')).to.throw(Error, 'Error in the backend')

      it '#where', ->
        stubResponse {
          success: false
          scoped_records: [{ id: 2, name: 'Peter' }]
        }, ->

          expect(-> User.where(name: 'John')).to.throw(Error, 'Error in the backend')

      it '#create', ->
        stubResponse {
          success: false
          scoped_records: [{ id: 2, name: 'Peter' }]
        }, ->

          expect(-> User.create(name: 'John')).to.throw(Error, 'Error in the backend')

      it '#update', ->
        stubResponse {
          success: false
          scoped_records: [{ id: 2, name: 'Peter' }]
        }, ->

          expect(-> User.update(id: 2, name: 'John')).to.throw(Error, 'Error in the backend')

      it '#destroy', ->
        stubResponse {
          success: false
          scoped_records: [{ id: 2, name: 'Peter' }]
        }, ->

          expect(-> User.destroy(2)).to.throw(Error, 'Error in the backend')
