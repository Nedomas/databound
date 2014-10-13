# Godfather.js

Exposes ActiveRecord records to the Javascript side.

## Installation

The javascript part is installed via bower.

Use ``godfather`` gem and create a crud controller for a model.

```ruby
class UsersController < ApplicationController
  include Godfather::Controller

  def model
    User
  end
end
```

Mount the controller on a route (f.e. ``/users``)

## Usage

```js
  User = new Godfather('/users')

  User.find(15).then(function(user) {
    alert('Yo, ' + user.name);
  });
```

You can specify scope for the connection.

```js
  User = new Godfather('/users', city: 'New York');

  User.where({ name: 'John' }).then(function(users) {
    alert('You are a New Yorker called John');
  });

  User.create({ name: 'Peter' }).then(function(new_user) {
    // I am from New York
    alert('I am from ' + new_user.city);
  });
```

Specify id when updating or destroying the record.

```js
  User = new Godfather('/users');

  User.update({ id: 15, name: 'Saint John' }).then(function(updated_user) {
  });

  User.destroy({ id: 15 }).then(function(resp) {
    // resp.success
  });
```
