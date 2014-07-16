"use strict"
angular.module("visu", [
  "ui.router"
  "ngStorage"
]).config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state "home",
    url: "/?sparqlEndpoint&query&outputType&chartConfig&motionChartState"
    templateUrl: "partials/main.html"
    controller: "MainCtrl"
  $urlRouterProvider.otherwise "/"
