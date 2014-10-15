# Godfather.js

![Godfather](https://cloud.githubusercontent.com/assets/1877286/4621676/2998b296-532f-11e4-91ed-f9b246d15568.jpg)

ActiveRecord exposed to the Javascript side and guarded by guns. 

**API documentation** [nedomas.github.io/godfather.js](http://nedomas.github.io/godfather.js/src/godfather.html).

## Usage

```js
  User = new Godfather('/users')

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
npm install godfather
```

or via ``bower``

```
bower install godfather
```

#### II. Ruby on Rails part

**1.** Add ``gem 'godfather'`` to ``Gemfile``.

**2.** Create a controller with method ``model`` which returns the model to be accessed.
Also include ``Godfather::Controller``

```ruby
class UsersController < ApplicationController
  include Godfather

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

godfather_of :users
```

For more info go to [Godfather gem repo](https://github.com/Nedomas/godfather)

## DSL

**Godfather.js** supports any attribute DSL via method override.

```js
  User = new Godfather('/users', { city: 'hottest_city' });
  
  User.create(name: 'Vikki').then(function(new_user) {
    // Vikki is from Miami
    alert(new_user.name + ' is from ' + new_user.city);
  });
```

```ruby
class UsersController < ApplicationController
  include Godfather

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

Library supports minimalistic version of computed properties. It attaches the properties on every record after the response from server.

```js
  User = new Godfather('/users', { city: 'hottest_city' });
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
  User = new Godfather('/users', 
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

The initial seed of Godfather was shamefully sponsored by [SameSystem](http://www.samesystem.com) and
developed during my time there.
