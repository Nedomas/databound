var CRUD = function(endpoint, scope, options) {
  this.endpoint = endpoint;
  this.scope = scope || {};
  this.options = options || {};
  this.extra_find_scopes = this.options.extra_find_scopes || [];
  this.records = {};
  this.seeds = {};
  this.properties = [];
};

CRUD.API_URL = '';

CRUD.prototype.where = function(params) {
  var _this = this;

  return this.request('where', params).then(function(records) {
    var computed_records = _.map(records, function(record) {
      return _this.withComputedProps(record);
    });
    _this.properties = _.keys(records[0]);
    _this.records = _.sortBy(computed_records, 'id');
    _this.pristine_records = _.cloneDeep(_this.records);

    return _this.promise(_this.records);
  });
};

// CRUD.prototype.listenKey = function(object, key) {
//   _this = this;
//
//   Object.defineProperty(object, key, {
//     get: function() {
//       console.log('get' + object['__' + key]);
//       return object['__' + key];
//     },
//     set: function(value) {
//       if (_.isArray(value)) {
//         _.each(value, function(member) {
//           if (_.isObject(member)) {
//             _.each(_.keys(member), function(member_key) {
//               _this.listenKey(member, member_key);
//             });
//           }
//         });
//       }
//
//       object['__' + key] = value;
//       console.log('SET ' + object['__' + key]);
//
//       console.log('change');
//     }
//   });
// };
//
// CRUD.prototype.listen = function(object) {
//   _.each(_.keys(object), function(key) {
//   });
// };

CRUD.prototype.syncDiff = function(new_records, old_records) {
  var _this = this;

  var dirty_records = _.select(new_records, function(new_record) {
    var record_with_same_id = _.detect(old_records, function(old_record) {
      return new_record.id == old_record.id;
    });

    return JSON.stringify(_.pick(record_with_same_id, _this.properties)) !=
      JSON.stringify(_.pick(new_record, _this.properties));
  });

  _.each(dirty_records, function(record) {
    _this.update(record);
  });
};

CRUD.prototype.withComputedProps = function(record) {
  return _.extend(record, this.computed(record));
};

CRUD.prototype.find = function(id) {
  var _this = this;

  return this.refresh().then(function() {
    return _this.promise(_this.take(id));
  });
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

CRUD.prototype.url = function(action) {
  return CRUD.API_URL + '/' + this.endpoint + '/' + action;
};

CRUD.prototype.data = function(params) {
  return {
    scope: JSON.stringify(this.scope),
    extra_find_scopes: JSON.stringify(this.extra_find_scopes),
    data: JSON.stringify(params)
  };
};

CRUD.prototype.request = function(action, params) {
  // must be GET
  return $j.getJSON(this.url(action), this.data(params));
};

CRUD.prototype.requestAndRefresh = function(action, params) {
  var _this = this;

  return this.request(action, params).then(function(resp) {
    return _this.refresh().then(function() {
      return _this.promise(resp);
    });
  });
};

CRUD.prototype.refresh = function() {
  var _this = this;

  return this.where().then(function(resp) {
    _this.records = _.clone(_this.seeds);
    _.extend(_this.records, resp);

    return _this.promise(_this.records);
  });
};

CRUD.prototype.take = function(id) {
  return _.detect(this.records, function(record) { return record.id == id });
};

CRUD.prototype.takeAll = function() {
  return this.records;
};

CRUD.prototype.injectSeedRecords = function(records) {
  this.seeds = records;
};

// overritable
CRUD.prototype.promise = function(result) {
  var deferred = $j.Deferred();
  deferred.resolve(result);
  return deferred.promise();
};
