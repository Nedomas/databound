describe 'unrescued error', ->
  it 'does not return a hash', ->
    stubResponse null, ->
      expect(-> User.find(name: 'John')).to.throw(Error,
        'Error in the backend')

  it '#find', ->
    stubResponse {
      success: false
      scoped_records: []
    }, ->

      expect(-> User.find(name: 'John')).to.throw(Error,
        'Error in the backend')

  it '#findBy', ->
    stubResponse {
      success: false
      scoped_records: []
    }, ->

      expect(-> User.findBy(name: 'John')).to.throw(Error,
        'Error in the backend')

  it '#where', ->
    stubResponse {
      success: false
      scoped_records: [{ id: 2, name: 'Peter' }]
    }, ->

      expect(-> User.where(name: 'John')).to.throw(Error,
        'Error in the backend')

  it '#create', ->
    stubResponse {
      success: false
      scoped_records: [{ id: 2, name: 'Peter' }]
    }, ->

      expect(-> User.create(name: 'John')).to.throw(Error,
        'Error in the backend')

  it '#update', ->
    stubResponse {
      success: false
      scoped_records: [{ id: 2, name: 'Peter' }]
    }, ->

      expect(-> User.update(id: 2, name: 'John')).to.throw(Error,
        'Error in the backend')

  it '#destroy', ->
    stubResponse {
      success: false
      scoped_records: [{ id: 2, name: 'Peter' }]
    }, ->

      expect(-> User.destroy(2)).to.throw(Error, 'Error in the backend')

  it 'backend with rejected promise', ->
    stubResponse {
      status: 401,
      responseJSON: {
        message: 'Something went wrong'
      }
    }, (->

      expect(-> User.destroy(1)).to.throw(Error,
        'Error in the backend with status 401')
    ), 'reject'
