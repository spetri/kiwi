class FK.Views.Sidebar extends Backbone.Marionette.Layout
  className: "sidebar-nav"
  template: FK.Template('sidebar')
  regions:
    top_ranked: ".top-ranked"
    most_discussed: ".most-discussed"

  onRender: ->
    @top_ranked.show(new FK.Views.TopRanked(collection: FK.Data.events.topRanked()))
    @most_discussed.show(new FK.Views.MostDiscussed(model: FK.Data.events.mostDiscussed()))
