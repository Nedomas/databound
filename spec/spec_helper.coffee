global._ = require('lodash')
global.mockDOM = (fn) ->
  jsdom = require('jsdom')

  jsdom.env(
    html: "<html><body></body></html>"
    scripts: ['../bower_components/jquery/dist/jquery.min.js']
    done: (err, window) ->
      if err
        console.log(err)

      global.window = window
      global.chai = require 'chai'
      global.expect = chai.expect

      Databound = require('../src/databound')
      Databound.API_URL = 'http://databound-testing.com'
      global.User = new Databound('users')

      fn()
      window.close()
  )


global.stubResponse = (resp, fn, type = 'resolve') ->
  mockDOM ->
    sinon = require('sinon')
    _.each ['records', 'scoped_records'], stringify(resp)

    jQuery = require 'jquery'

    stub = sinon.stub jQuery, 'post', ->
      deferred = jQuery.Deferred()
      deferred[type](resp)
      deferred.promise()

    try fn()
    catch e
      throw e unless e?.message
    finally stub.restore()

stringify = _.curry((resp, name) ->
  return unless _.isArray(resp?[name])

  resp[name] = JSON.stringify(resp[name])
)
