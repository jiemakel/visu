"use strict"
angular.module("app", [
  'http-auth-interceptor'
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
.run ($rootScope,$http,authService) ->
  $rootScope.setAuth = ->
    $rootScope.authOpen = false
    $http.defaults.headers.common['Authorization'] = 'Basic '+btoa($rootScope.username+':'+$rootScope.password)
    authService.loginConfirmed()
  $rootScope.dismissAuth = ->
    $rootScope.authOpen = false
    authService.loginCancelled({status:401},"Authentication required")
  $rootScope.$on 'event:auth-loginRequired', ->
    $rootScope.authOpen = true
