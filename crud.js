var CRUD = function(endpoint, scope, options) {
  this.endpoint = endpoint;
  this.scope = scope;
  this.options = options || {};
  this.extra_find_scopes = this.options.extra_find_scopes || [];
  this.records = {};
  this.seeds = {};
};

CRUD.prototype.create = function(params) {
  return this.requestAndRefresh('create', params);
};

CRUD.prototype.update = function(params) {
  return this.requestAndRefresh('update', params);
};

CRUD.prototype.destroy = function(params) {
  return this.requestAndRefresh('destroy', params);
};

CRUD.prototype.requestAndRefresh = function(action, params) {
  var _this = this;

  return this.request(action, params).then(function(resp) {
    return _this.refresh().then(function() {
      return promise(resp);
    });
  });
};

CRUD.prototype.find = function(params) {
  return this.request('find', params);
};

CRUD.prototype.refresh = function() {
  var _this = this;

  return this.find().then(function(resp) {
    _this.records = _.clone(_this.seeds);
    _.extend(_this.records, resp.records);

    return promise(_this.records);
  });
};

CRUD.prototype.take = function(id) {
  return this.records[id];
};

CRUD.prototype.takeAll = function() {
  return this.records;
};

CRUD.prototype.request = function(action, params) {
  // must be GET
  return $j.getJSON(this.url(action), this.data(params));
};

CRUD.prototype.url = function(action) {
  return ctxpre + '/' + this.endpoint + '/' + action;
};

CRUD.prototype.data = function(params) {
  return {
    scope: JSON.stringify(this.scope),
    extra_find_scopes: JSON.stringify(this.extra_find_scopes),
    data: JSON.stringify(params)
  };
};

CRUD.prototype.injectSeedRecords = function(records) {
  this.seeds = records;
};
