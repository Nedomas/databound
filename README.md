# Godfather.js

![Godfather](https://cloud.githubusercontent.com/assets/1877286/4621676/2998b296-532f-11e4-91ed-f9b246d15568.jpg)

Exposes ActiveRecord records to the Javascript side.

## Usage

```js
  User = new Godfather('/users')

  User.find(15).then(function(user) {
    alert('Yo, ' + user.name);
  });
```

You can specify scope for the connection.

```js
  User = new Godfather('/users', { city: 'New York' });

  User.where({ name: 'John' }).then(function(users) {
    alert('You are a New Yorker called John');
  });

  User.create({ name: 'Peter' }).then(function(new_user) {
    // I am from New York
    alert('I am from ' + new_user.city);
  });
```

Specify ``id`` when updating or destroying the record.

```js
  User = new Godfather('/users');

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

## Sponsors

The initial seed of Godfather was shamefully sponsored by [SameSystem](http://www.samesystem.com) and
developed during my time there.
