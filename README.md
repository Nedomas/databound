[![Code Climate](https://codeclimate.com/github/Nedomas/databound/badges/gpa.svg)](https://codeclimate.com/github/Nedomas/databound)
[![Build Status](https://travis-ci.org/Nedomas/databound.svg)](https://travis-ci.org/Nedomas/databound)
[![Bower version](https://badge.fury.io/bo/databound.svg)](http://badge.fury.io/bo/databound)
[![NPM version](https://badge.fury.io/js/databound.svg)](http://badge.fury.io/js/databound)
[![Dependency Status](https://gemnasium.com/Nedomas/databound.svg)](https://gemnasium.com/Nedomas/databound)

![Databound](https://cloud.githubusercontent.com/assets/1877286/4743542/df89dcec-5a28-11e4-9114-6f383fe269cb.png)

Exposes ActiveRecord records to the Javascript side.

**API documentation** [nedomas.github.io/databound](http://nedomas.github.io/databound/src/databound.html).

## Usage

```js
  User = new Databound('/users')

  User.find(15).then(function(user) {
    alert('Yo, ' + user.name);
  });

  User.where({ name: 'John' }).then(function(users) {
    alert('You are a New Yorker called John');
  });

  User.create({ name: 'Peter' }).then(function(new_user) {
    // I am from New York
    alert('I am from ' + new_user.city);
  });

  User.update({ id: 15, name: 'Saint John' }).then(function(updated_user) {
  });

  User.destroy({ id: 15 }).then(function(resp) {
    // resp.success
  });
```

## Installation

The library has two parts and has Lodash as a dependency.

#### I. Javascript part

Via ``npm``

```
npm install databound
```

or via ``bower``

```
bower install databound
```

#### II. Ruby on Rails part

**1.** Add ``gem 'databound'`` to ``Gemfile``.

**2.** Create a controller with method ``model`` which returns the model to be accessed.
Also include ``Databound``

```ruby
class UsersController < ApplicationController
  include Databound

  private

  def model
    User
  end
end
```

**3.** Add a route to ``routes.rb``

```ruby
# This creates POST routes on /users to UsersController
# For where, create, update, destroy

databound :users
```

For more info go to [Databound gem repo](https://github.com/Nedomas/databound-rails)

## DSL

**Databound** supports any attribute DSL via method override.

```js
  User = new Databound('/users', { city: 'hottest_city' });

  User.create(name: 'Vikki').then(function(new_user) {
    // Vikki is from Miami
    alert(new_user.name + ' is from ' + new_user.city);
  });
```

```ruby
class UsersController < ApplicationController
  include Databound

  private

  def model
    User
  end

  def override!(name, value, data)
    if name == :city and value == 'hottest_city'
      'Miami'
    else
      super
    end
  end
end
```

## Semi-computed properties

Library supports minimalistic version of computed properties.
It attaches the properties on every record after the response from server.

```js
  User = new Databound('/users', { city: 'hottest_city' });
  User.computed = function(user) {
    return {
      full_name: user.first_name + ' ' + user.last_name;
    };
  };

  User.findBy(name: 'Vikki').then(function(user) {
    // Vikki Minaj
    alert(user.full_name);
  });
```

## Extra find scopes

These scopes are used only for finding the records and are not used when creating the record.

```js
  User = new Databound('/users',
    { city: 'Miami' },
    { extra_find_scopes: [{ city: 'New york' }] }
  );

  User.create(name: 'Nikki').then(function() {
    var all_users = User.takeAll();
    // ['Miami', 'New york']
    alert(_.map(all_users, function(user) { return user.city }));
  });
```

## Sponsors

The initial seed of Databound was shamefully sponsored by [SameSystem](http://www.samesystem.com) and
developed during my time there.
