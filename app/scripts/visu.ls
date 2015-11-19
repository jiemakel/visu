"use strict"
angular.module("app", [
  "ui.router"
  "ngStorage"
  'ngRoute',
  'ngAnimate',
  'ngSanitize',
  'raw.services',
  'raw.directives',
  'raw.controllers',
  'mgcrea.ngStrap',
  'infinite-scroll',
  'ui',
  'colorpicker.module'
]).config ($stateProvider, $urlRouterProvider) ->
  $stateProvider.state "home",
    url: "/?sparqlEndpoint&query&outputType"
    templateUrl: "partials/main.html"
    controller: "MainCtrl"
  $urlRouterProvider.otherwise "/"
