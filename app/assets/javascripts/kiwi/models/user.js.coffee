class FK.Models.User extends Backbone.Model
  idAttribute: "_id"
  url: () =>
    if @isNew()
      return '/users'
    else
      return '/users/' + @get('_id')['$oid']
  defaults:
    email: ''
    provider: ''
    logged_in: false
    username: 'noname'
