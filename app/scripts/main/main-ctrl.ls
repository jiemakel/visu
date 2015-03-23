"use strict"
angular.module("app").controller("MainCtrl", ($window,$location,$http,$scope,$localStorage,$state,$stateParams,$q) ->
  if ($stateParams.sparqlEndpoint?) then $localStorage.sparqlEndpoint=$stateParams.sparqlEndpoint
  if ($localStorage.sparqlEndpoint?) then $scope.sparqlEndpoint=$localStorage.sparqlEndpoint
  $scope.shareLink = !->
    $location.search('sparqlEndpoint',$scope.sparqlEndpoint)
    $location.search('query',yasqe.getValue!)
    $location.search('outputType',yasr.options.output)
    for pname,plugin of yasr.plugins when plugin.getPersistentSettings?
      $location.search(pname,JSON.stringify(plugin.getPersistentSettings!))
    url = $location.absUrl!
    $scope.shareLinkLoading = true
    response <-! $http.post('https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyDtS96pmj2IeRdw81zobVDpCfs0rFphHvc',
      longUrl : url
    ).then(_,!->
      $scope.shareLinkLoading=false;$window.alert('URL updated, copy it from the browser address bar'))
    $scope.shareLinkLoading = false
    $window.prompt('Copy to clipboard with Ctrl/Cmd-C',response.data.id)
  yasqe = YASQE(document.getElementById("yasqe"),
    createShareLink: false
    sparql:
      showQueryButton: true
      endpoint : $scope.sparqlEndpoint
      query : ''
  )
  if $stateParams.query? then yasqe.setValue($stateParams.query)
  $scope.sparqlEndpointInputValid = true
  canceller = void
  $scope.$watch('sparqlEndpoint',(newValue,oldValue) !->
    if (newValue?)
      if (canceller?) then canceller.resolve!
      canceller := $q.defer!
      $http({
        method: "GET",
        url : newValue,
        params: { query:"ASK {}" },
        headers: { 'Accept' : 'application/sparql-results+json' }
        timeout: canceller.promise
      }).success((data) !->
        $scope.sparqlEndpointInputValid = data.boolean?
      ).error(!->
        $scope.sparqlEndpointInputValid = false
      )
    if (newValue!=oldValue)
      $localStorage.sparqlEndpoint = newValue
      yasqe.getOption('sparql').endpoint = newValue
  )
  yasr = YASR(document.getElementById("yasr"), {
    persistency: {
      outputSelector: if $stateParams.outputType then false else "visu"
      results:false
    }
    # this way, the URLs in the results are prettified using the defined prefixes in the query
    getUsedPrefixes: yasqe.getPrefixesFromQuery
  })
  # stupid yasr persistence
  if $stateParams.outputType?
    yasr.options.output = $stateParams.outputType
    yasr.header.find("button.selected").removeClass("selected")
    yasr.header.find("button.select_#{$stateParams.outputType}").addClass("selected")
  # legacy support
  if $location.search!['chartConfig']?
    $location.search('gchart',JSON.stringify({chartConfig:JSON.parse($location.search!.chartConfig),motionChartState: if $location.search!.motionChartState then $location.search!.motionChartState else void}))
    $location.search('chartConfig',void)
    $location.search('motionChartState',void)
  for pname,plugin of yasr.plugins when plugin.setPersistentSettings?
    if ($location.search![pname]) then plugin.setPersistentSettings(JSON.parse($location.search![pname]))
  yasr.yasqe = yasqe
  yasr.options.persistency.outputSelector = "visu"
  yasqe.options.sparql.handlers.success = (data, textStatus, xhr) ->
    yasr.setResponse({response: data, contentType: xhr.getResponseHeader("Content-Type")})
  yasqe.options.sparql.handlers.error = (xhr, textStatus, errorThrown) ->
    exceptionMsg = textStatus + " (response status code " + xhr.status + ")"
    if (errorThrown && errorThrown.length) then exceptionMsg += ": " + errorThrown
    yasr.setResponse({exception: exceptionMsg})
  if ($stateParams.sparqlEndpoint? && $stateParams.query?)
    yasqe.query!
)
