YASR.plugins.gmaps = (yasr) ->
  {
    yasr : yasr
    name : "Google Maps"
    hideFromSelection : false
    priority : 2
    canHandleResults : (yasr) ->
      yasr.results && yasr.results.getVariables && yasr.results.getVariables() && 'lat' in yasr.results.getVariables() && 'lon' in yasr.results.getVariables()
    draw : !->
      yasr.resultsContainer.html('<div id="gmap"></div>')
      mapOptions =
        mapTypeId: google.maps.MapTypeId.SATELLITE
      map = new google.maps.Map(yasr.resultsContainer.find('div')[0], mapOptions);
      bounds = new google.maps.LatLngBounds!
      infoWindow = new google.maps.InfoWindow!
      for res in yasr.results.getBindings!
        loc = new google.maps.LatLng(res.lat.value,res.lon.value);
        bounds.extend(loc)
        let d = { res, marker : new google.maps.Marker(
          position: loc,
          map:map
          title: if (res.name?) then res.name.value else res.lat.value+','+res.lon.value
        ) }
          google.maps.event.addListener(d.marker, 'click', !->
            content = "<table>"
            for k,v of d.res
              content+="<tr><th>"+k+"</th><td>"+v.value+"</td></tr>"
            content += "</table>"
            infoWindow.setContent(content)
            infoWindow.open(map,d.marker)
          )
      map.fitBounds(bounds)
      map.panToBounds(bounds)
  }
