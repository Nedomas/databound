var Databound, jQuery, _;

_ = require('lodash');

jQuery = require('jquery');

Databound = function(endpoint, scope, options) {
  this.endpoint = endpoint;
  this.scope = scope || {};
  this.options = options || {};
  this.extra_find_scopes = this.options.extra_find_scopes || [];
  this.records = [];
  this.seeds = [];
  this.properties = [];
};

Databound.API_URL = "";

Databound.prototype.request = function(action, params) {
  return jQuery.post(this.url(action), this.data(params), 'json');
};

Databound.prototype.promise = function(result) {
  var deferred;
  deferred = jQuery.Deferred();
  deferred.resolve(result);
  return deferred.promise();
};

Databound.prototype.where = function(params) {
  var _this;
  _this = this;
  return this.request('where', params).then(function(records) {
    var computed_records;
    records = records.concat(_this.seeds);
    computed_records = _.map(records, function(record) {
      return _this.withComputedProps(record);
    });
    _this.properties = _.keys(records[0]);
    _this.records = _.sortBy(computed_records, 'id');
    return _this.promise(_this.records);
  });
};

Databound.prototype.find = function(id) {
  var _this;
  _this = this;
  return this.where({
    id: id
  }).then(function() {
    return _this.promise(_this.take(id));
  });
};

Databound.prototype.findBy = function(params) {
  var _this;
  _this = this;
  return this.where(params).then(function(resp) {
    return _this.promise(_.first(_.values(resp)));
  });
};

Databound.prototype.create = function(params) {
  return this.requestAndRefresh('create', params);
};

Databound.prototype.update = function(params) {
  return this.requestAndRefresh('update', params);
};

Databound.prototype.destroy = function(params) {
  return this.requestAndRefresh('destroy', params);
};

Databound.prototype.take = function(id) {
  var _this;
  _this = this;
  return _.detect(this.records, function(record) {
    return JSON.stringify(id) === JSON.stringify(record.id);
  });
};

Databound.prototype.takeAll = function() {
  return this.records;
};

Databound.prototype.injectSeedRecords = function(records) {
  return this.seeds = records;
};

Databound.prototype.syncDiff = function(new_records, old_records) {
  var dirty_records, _this;
  _this = this;
  dirty_records = _.select(new_records, function(new_record) {
    var record_with_same_id;
    record_with_same_id = _.detect(old_records, function(old_record) {
      return new_record.id === old_record.id;
    });
    return JSON.stringify(_.pick(record_with_same_id, _this.properties)) !== JSON.stringify(_.pick(new_record, _this.properties));
  });
  return _.each(dirty_records, function(record) {
    return _this.update(record);
  });
};

Databound.prototype.requestAndRefresh = function(action, params) {
  var _this;
  _this = this;
  return this.request(action, params).then(function(resp) {
    if (!(resp != null ? resp.success : void 0)) {
      throw new Error('Error in the backend');
    }
    if (_.isString(resp.scoped_records)) {
      resp.scoped_records = JSON.parse(resp.scoped_records);
    }
    _this.records = _.sortBy(resp.scoped_records, 'id');
    if (resp.id) {
      return _this.promise(_this.take(resp.id));
    } else {
      return _this.promise(resp.success);
    }
  });
};

Databound.prototype.withComputedProps = function(record) {
  if (this.computed) {
    return _.extend(record, this.computed(record));
  } else {
    return record;
  }
};

Databound.prototype.url = function(action) {
  if (_.isEmpty(Databound.API_URL)) {
    return "" + this.endpoint + "/" + action;
  } else {
    return "" + Databound.API_URL + "/" + this.endpoint + "/" + action;
  }
};

Databound.prototype.data = function(params) {
  return {
    scope: JSON.stringify(this.scope),
    extra_find_scopes: JSON.stringify(this.extra_find_scopes),
    data: JSON.stringify(params)
  };
};

module.exports = Databound;
