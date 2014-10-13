# Crud.js

Exposes ActiveRecord records to the Javascript side.

## Installation

The javascript part is installed via bower.

Use ``crud_rails`` gem and create a crud controller for a model.

```ruby
class UsersController < ApplicationController
  include CrudRails::Controller

  def model
    User
  end
end
```

Mount the controller on a route (f.e. ``/users``)

## Usage

```js
  User = new CRUD('/users');

  User.find(15).then(function(user) {
    alert('Yo, ' + user.name);
  });
```

You can specify scope for the connection.

```js
  User = new CRUD('/users', city: 'New York');

  User.where(name: 'John').then(function(users) {
    alert('You are a New Yorker called John');
  });
```
