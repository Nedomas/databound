var Databound, DataboundError,
  __slice = [].slice;

Databound = (function() {
  function Databound(endpoint, scope, options) {
    this.endpoint = endpoint;
    this.scope = scope != null ? scope : {};
    this.options = options != null ? options : {};
    this.extra_where_scopes = this.options.extra_where_scopes || [];
    this.records = [];
    this.seeds = [];
    this.properties = [];
  }

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
    return this.wrappedRequest('where', params).then(function(resp) {
      var records;
      records = JSON.parse(resp.records).concat(_this.seeds);
      _this.records = _.sortBy(records, 'id');
      return _this.promise(_this.records);
    });
  };

  Databound.prototype.all = function() {
    return this.where();
  };

  Databound.prototype.find = function(id) {
    var _this;
    this.checkUndefinedId('find', id);
    _this = this;
    return this.where({
      id: id
    }).then(function() {
      var record;
      record = _this.take(id);
      if (!record) {
        throw new DataboundError("Couldn't find record with id: " + id);
      }
      return _this.promise(record);
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

  Databound.prototype.destroy = function(id) {
    this.checkUndefinedId('destroy', id);
    return this.requestAndRefresh('destroy', {
      id: id
    });
  };

  Databound.prototype.take = function(id) {
    return _.detect(this.records, function(record) {
      return id.toString() === record.id.toString();
    });
  };

  Databound.prototype.takeAll = function() {
    return this.records;
  };

  Databound.prototype.injectSeedRecords = function(records) {
    return this.seeds = records;
  };

  Databound.prototype.requestAndRefresh = function(action, params) {
    var _this;
    _this = this;
    return this.wrappedRequest(action, params).then(function(resp) {
      var records, records_with_seeds;
      records = JSON.parse(resp.scoped_records);
      records_with_seeds = records.concat(_this.seeds);
      _this.records = _.sortBy(records_with_seeds, 'id');
      if (resp.id) {
        return _this.promise(_this.take(resp.id));
      } else {
        return _this.promise(resp.success);
      }
    });
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
      extra_where_scopes: JSON.stringify(this.extra_where_scopes),
      data: JSON.stringify(params)
    };
  };

  Databound.prototype.wrappedRequest = function() {
    var args;
    args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
    return this.request.apply(this, args).then(_.bind(this.handleSuccess, this)).fail(this.handleFailure);
  };

  Databound.prototype.handleSuccess = function(resp) {
    if (!(resp != null ? resp.success : void 0)) {
      throw new Error('Error in the backend');
    }
    return this.promise(resp);
  };

  Databound.prototype.handleFailure = function(e) {
    if (e.status === DataboundError.STATUS) {
      throw new DataboundError(e.responseJSON.message);
    } else {
      throw new Error("Error in the backend with status " + e.status);
    }
  };

  Databound.prototype.checkUndefinedId = function(action, id) {
    if (!_.isUndefined(id)) {
      return;
    }
    throw new DataboundError("Couldn't " + action + " a record without an id");
  };

  return Databound;

})();

DataboundError = (function() {
  function DataboundError(text) {
    this.message = "Databound: " + text;
  }

  DataboundError.STATUS = 405;

  return DataboundError;

})();

DataboundError.prototype = new Error();
