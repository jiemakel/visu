"use strict"
angular.module("visu").controller("MainCtrl", ($http,$scope,$localStorage,$state,$stateParams) ->
	if ($stateParams.sparqlEndpoint?) then $localStorage.sparqlEndpoint=$stateParams.sparqlEndpoint
	if ($localStorage.sparqlEndpoint?) then $scope.sparqlEndpoint=$localStorage.sparqlEndpoint
	$scope.shareLink = () -> 
		$state.go(".",
			sparqlEndpoint : $scope.sparqlEndpoint
			query : yasqe.getValue()
			outputType : yasr.options.output
			chartConfig : yasr.options.gchart.chartConfig
			motionChartState : yasr.options.gchart.motionChartState
		)
	yasqe = YASQE(document.getElementById("yasqe"), {
		createShareLink: false
		sparql: {
			showQueryButton: true
			endpoint : $scope.sparqlEndpoint
			query : ''
		}
	})
	if $stateParams.query? then yasqe.setValue($stateParams.query)
	$scope.sparqlEndpointInputValid = true
	$scope.$watch('sparqlEndpoint',(newValue,oldValue) -> 
		if (newValue?)
			$http({
				method: "GET",
				url : newValue,
				params: { query:"ASK {}" },
				headers: { 'Accept' : 'application/sparql-results+json' }
			}).success((data) ->
				$scope.sparqlEndpointInputValid = data.boolean?
			).error(() ->
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
		output: $stateParams.outputType ? undefined
		gchart: {
			chartConfig : $stateParams.chartConfig
			motionChartState : $stateParams.motionChartState 
		}
	})
	yasr.options.persistency.outputSelector = "visu"
	yasqe.options.sparql.handlers.success = (data, textStatus, xhr) ->
		yasr.setResponse({response: data, contentType: xhr.getResponseHeader("Content-Type")})
	yasqe.options.sparql.handlers.error = (xhr, textStatus, errorThrown) ->
		exceptionMsg = textStatus + " (response status code " + xhr.status + ")"
		if (errorThrown && errorThrown.length) then exceptionMsg += ": " + errorThrown
		yasr.setResponse({exception: exceptionMsg})
	if ($stateParams.sparqlEndpoint? && $stateParams.query?)
		yasqe.query()
)