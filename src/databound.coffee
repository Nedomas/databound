_ = require 'lodash'
jQuery = require 'jquery'

# You can specify scope for the connection.
#
# ```coffeescript
#   User = new Databound '/users', city: 'New York'
#
#   User.where(name: 'John').then (users) ->
#     alert 'You are a New Yorker called John'
#
#   User.create(name: 'Peter').then (new_user) ->
#     # I am from New York
#     alert "I am from #{new_user.city}"
# ```
Databound = (endpoint, scope, options) ->
  @endpoint = endpoint
  @scope = scope or {}
  @options = options or {}
  @extra_find_scopes = @options.extra_find_scopes or []
  @records = []
  @seeds = []
  @properties = []
  return

# ## Configs

# Functions ``request`` and ``promise`` are overritable
Databound.API_URL = ""

# Does a POST request and returns a ``promise``
Databound::request = (action, params) ->
  jQuery.post @url(action), @data(params), 'json'

# Returns a ``promise`` which resolves with ``result``
Databound::promise = (result) ->
  deferred = jQuery.Deferred()
  deferred.resolve result
  deferred.promise()

Databound::where = (params) ->
  _this = @

  @request('where', params).then (records) ->
    records = records.concat(_this.seeds)
    _this.records = _.sortBy(records, 'id')
    _this.promise _this.records

# Return a single record by ``id``
#
# ```coffeescript
# User.find(15).then (user) ->
#   alert "Yo, #{user.name}"
# ```
Databound::find = (id) ->
  _this = @

  @where(id: id).then ->
    _this.promise _this.take(id)

# Return a single record by ``params``
#
# ```coffeescript
# User.findBy(name: 'John', city: 'New York').then (user) ->
#   alert "I'm John from New York"
# ```
Databound::findBy = (params) ->
  _this = @

  @where(params).then (resp) ->
    _this.promise _.first(_.values(resp))

Databound::create = (params) ->
  @requestAndRefresh 'create', params

# Specify ``id`` when updating or destroying the record.
#
# ```coffeescript
#   User = new Databound '/users'
#
#   User.update(id: 15, name: 'Saint John').then (updated_user) ->
#     alert updated_user
#
#   User.destroy(id: 15).then (resp) ->
#     alert resp.success
# ```
Databound::update = (params) ->
  @requestAndRefresh 'update', params

Databound::destroy = (params) ->
  @requestAndRefresh 'destroy', params

# Just take already dowloaded records
Databound::take = (id) ->
  _this = @

  _.detect @records, (record) ->
    id.toString() == record.id.toString()

Databound::takeAll = ->
  @records

# F.e. Have default records
Databound::injectSeedRecords = (records) ->
  @seeds = records

Databound::requestAndRefresh = (action, params) ->
  _this = @

  # backend responds with:
  # {
  #   success: true,
  #   id: record.id,
  #   scoped_records: []
  # }
  @request(action, params).then (resp) ->
    throw new Error 'Error in the backend' unless resp?.success

    records = JSON.parse(resp.scoped_records)
    records_with_seeds = records.concat(_this.seeds)
    _this.records = _.sortBy(records_with_seeds, 'id')

    if resp.id
      _this.promise _this.take(resp.id)
    else
      _this.promise resp.success

Databound::url = (action) ->
  if _.isEmpty(Databound.API_URL)
    "#{@endpoint}/#{action}"
  else
    "#{Databound.API_URL}/#{@endpoint}/#{action}"

Databound::data = (params) ->
  scope: JSON.stringify(@scope)
  extra_find_scopes: JSON.stringify(@extra_find_scopes)
  data: JSON.stringify(params)

module.exports = Databound
