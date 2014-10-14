Godfather = (endpoint, scope, options) ->
  @endpoint = endpoint
  @scope = scope or {}
  @options = options or {}
  @extra_find_scopes = @options.extra_find_scopes or []
  @records = []
  @seeds = []
  @properties = []
  return

Godfather.API_URL = ""
# overritable; must be POST
Godfather::request = (action, params) ->
  $j.post @url(action), @data(params), 'json'

# overritable
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

Godfather::create = (params) ->
  @requestAndRefresh 'create', params

Godfather::update = (params) ->
  @requestAndRefresh 'update', params

Godfather::destroy = (params) ->
  @requestAndRefresh 'destroy', params

Godfather::requestAndRefresh = (action, params) ->
  _this = @

  @request(action, params).then (resp) ->
    _this.where().then ->
      _this.promise resp

Godfather::find = (id) ->
  _this = @

  @where(id: id).then ->
    _this.promise _this.take(id)

Godfather::findBy = (params) ->
  _this = @

  @where(params).then (resp) ->
    _this.promise _.first(_.values(resp))

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

Godfather::refresh = ->
  _this = @

  @where().then (resp) ->
    _this.records = _.clone(_this.seeds)
    _.extend _this.records, resp
    _this.promise _this.records

Godfather::take = (id) ->
  _.detect @records, (record) ->
    parseInt(record.id) == parseInt(id)

Godfather::takeAll = ->
  @records

Godfather::injectSeedRecords = (records) ->
  @seeds = records

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
