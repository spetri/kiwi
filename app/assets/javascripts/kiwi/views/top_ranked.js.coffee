class FK.Views.TopRanked extends Backbone.Marionette.ItemView
  template: FK.Template('top_ranked')
  className: 'well'
  onBeforeRender: ->
    #TODO: fix the slime
    @model = @collection
