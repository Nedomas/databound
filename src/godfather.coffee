_ = require 'lodash'

# You can specify scope for the connection.
#
# ```coffeescript
#   User = new Godfather '/users', city: 'New York'
#
#   User.where(name: 'John').then (users) ->
#     alert 'You are a New Yorker called John'
#
#   User.create(name: 'Peter').then (new_user) ->
#     # I am from New York
#     alert "I am from #{new_user.city}"
# ```
Godfather = (endpoint, scope, options) ->
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
Godfather.API_URL = ""

# Should do a POST request and return a ``promise``
Godfather::request = (action, params) ->
  $j.post @url(action), @data(params), 'json'

# Should return a ``promise`` which resolves with ``result``
Godfather::promise = (result) ->
  deferred = $j.Deferred()
  deferred.resolve result
  deferred.promise()

Godfather::where = (params) ->
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
Godfather::find = (id) ->
  _this = @

  @where(id: id).then ->
    _this.promise _this.take(id)

# Return a single record by ``params``
#
# ```coffeescript
# User.findBy(name: 'John', city: 'New York').then (user) ->
#   alert "I'm John from New York"
# ```
Godfather::findBy = (params) ->
  _this = @

  @where(params).then (resp) ->
    _this.promise _.first(_.values(resp))

Godfather::create = (params) ->
  @requestAndRefresh 'create', params

# Specify ``id`` when updating or destroying the record.
#
# ```coffeescript
#   User = new Godfather '/users'
#
#   User.update(id: 15, name: 'Saint John').then (updated_user) ->
#     alert updated_user
#
#   User.destroy(id: 15).then (resp) ->
#     alert resp.success
# ```
Godfather::update = (params) ->
  @requestAndRefresh 'update', params

Godfather::destroy = (params) ->
  @requestAndRefresh 'destroy', params

# Just take already dowloaded records
Godfather::take = (id) ->
  _.detect @records, (record) ->
    parseInt(record.id) == parseInt(id)

Godfather::takeAll = ->
  @records

# F.e. Have default records
Godfather::injectSeedRecords = (records) ->
  @seeds = records

# Used with Angular.js ``$watch`` to sync model changes to backend
Godfather::syncDiff = (new_records, old_records) ->
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

Godfather::requestAndRefresh = (action, params) ->
  _this = @

  @request(action, params).then (resp) ->
    _this.where().then ->
      _this.promise resp

Godfather::withComputedProps = (record) ->
  if @computed
    _.extend record, @computed(record)
  else
    record

Godfather::url = (action) ->
  "#{Godfather.API_URL}/#{@endpoint}/#{action}"

Godfather::data = (params) ->
  scope: JSON.stringify(@scope)
  extra_find_scopes: JSON.stringify(@extra_find_scopes)
  data: JSON.stringify(params)

module.exports = Godfather
