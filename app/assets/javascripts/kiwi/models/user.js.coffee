class FK.Models.User extends Backbone.Model
  idAttribute: "_id"
  url: '/users'
  defaults:
    email: ''
    provider: ''
    logged_in: false
    username: 'noname'
