YASR.plugins.gmaps = (yasr) ->
  id = yasr.container.closest('[id]').attr('id')
  {
    yasr : yasr
    name : "Google Maps"
    hideFromSelection : false
    priority : 1
    canHandleResults : (yasr) ->
      yasr.results && yasr.results.getVariables && yasr.results.getVariables() && 'lat' in yasr.results.getVariables() && 'lon' in yasr.results.getVariables()
    draw : !->
      yasr.resultsContainer.html('<div id="gmap"></div>')
      mapOptions =
        mapTypeId: google.maps.MapTypeId.SATELLITE
      map = new google.maps.Map(yasr.resultsContainer.find('div')[0], mapOptions);
      bounds = new google.maps.LatLngBounds!
      for res in yasr.results.getBindings!
        loc = new google.maps.LatLng(res.lat.value,res.lon.value);
        bounds.extend(loc)
        new google.maps.Marker(
          position: loc,
          map:map
          title: if (res.name?) then res.name.value else res.lat.value+','+res.lon.value
        )
      map.fitBounds(bounds)
      map.panToBounds(bounds)
  }
