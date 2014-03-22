class FK.UserMediator extends Marionette.Controller
  initialize: (options) =>
    @user = options.user
    @vent = options.vent

    @listenTo @vent, 'filter:subkasts', @saveSubkasts
    @listenTo @vent, 'filter:country', @saveCountry

    @getUserLocation() if not FK.CurrentUser.get('country') and FK.CurrentUser.get('logged_in')

  getUserLocation: () =>
    navigator.geolocation.getCurrentPosition(( position ) =>
      latLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude)
      geocoder = new google.maps.Geocoder()
      geocoder.geocode({ 'latLng': latLng }, (locations) =>
        countryObject = _.find(locations, (location) => _.contains(location.types, 'country') )
        @user.save('country', countryObject.address_components[0].short_name)
        @vent.trigger('filter:country', @user.get('country'))
      )
    )

  saveSubkasts: (subkasts) =>
    @user.save({subkasts: subkasts})

  saveCountry: (country) =>
    @user.save({country: country})
