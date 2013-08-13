class FK.Models.Country extends Backbone.Model
  idAttribute: "_id"

class FK.Collections.CountryList extends Backbone.Collection
  model: FK.Models.Country

