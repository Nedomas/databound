describe 'databound error', ->
  it 'unpermitted column', ->
    stubResponse {
      status: 405,
      responseJSON: {
        message: 'Request includes unpermitted columns: city'
      }
    }, (->

      expect(-> User.create(city: 'Hawaii')).to.throw(Error,
        'DATABOUND ERROR - Request includes unpermitted columns: city')
    ), 'reject'

  it 'unpermitted action', ->
    stubResponse {
      status: 405,
      responseJSON: {
        message: 'Request for destroy not permitted'
      }
    }, (->

      expect(-> User.destroy(1)).to.throw(Error,
        'DATABOUND ERROR - Request for destroy not permitted')
    ), 'reject'
