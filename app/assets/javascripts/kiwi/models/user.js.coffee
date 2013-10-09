class FK.Models.User extends Backbone.Model
  idAttribute: "_id"
  defaults:
    email: ''
    provider: ''
    logged_in: false
