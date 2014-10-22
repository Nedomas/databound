_ = require 'lodash'

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

# Should do a POST request and return a ``promise``
Databound::request = (action, params) ->
  $j.post @url(action), @data(params), 'json'

# Should return a ``promise`` which resolves with ``result``
Databound::promise = (result) ->
  deferred = $j.Deferred()
  deferred.resolve result
  deferred.promise()

Databound::where = (params) ->
  _this = @

  @request('where', params).then (records) ->
    records = records.concat(_this.seeds)
    computed_records = _.map(records, (record) ->
      _this.withComputedProps record
    )
    _this.properties = _.keys(records[0])
    _this.records = _.sortBy(computed_records, 'id')
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
  _.detect @records, (record) ->
    parseInt(record.id) == parseInt(id)

Databound::takeAll = ->
  @records

# F.e. Have default records
Databound::injectSeedRecords = (records) ->
  @seeds = records

# Used with Angular.js ``$watch`` to sync model changes to backend
Databound::syncDiff = (new_records, old_records) ->
  _this = this

  dirty_records = _.select(new_records, (new_record) ->
    record_with_same_id = _.detect(old_records, (old_record) ->
      new_record.id is old_record.id
    )
    JSON.stringify(_.pick(record_with_same_id, _this.properties)) isnt
      JSON.stringify(_.pick(new_record, _this.properties))
  )
  _.each dirty_records, (record) ->
    _this.update record

Databound::requestAndRefresh = (action, params) ->
  _this = @

  # backend responds with { success: true, id: record.id }
  @request(action, params).then (resp) ->
    throw new Error 'Error in the backend' unless resp?.success

    _this.where().then ->
      if resp.id
        _this.promise _this.take(resp.id)
      else
        _this.promise resp.success

Databound::withComputedProps = (record) ->
  if @computed
    _.extend record, @computed(record)
  else
    record

Databound::url = (action) ->
  "#{Databound.API_URL}/#{@endpoint}/#{action}"

Databound::data = (params) ->
  scope: JSON.stringify(@scope)
  extra_find_scopes: JSON.stringify(@extra_find_scopes)
  data: JSON.stringify(params)

module.exports = Databound
