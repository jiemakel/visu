angular.module("app").run ($compile,$rootScope) !->
  YASR.plugins.grouped = (yasr) ->
    {
      yasr : yasr
      name : "Grouped"
      hideFromSelection : false
      priority : 1
      scope : void
      settings : void
      setPersistentSettings : (settings) !->
        @settings = settings
        if (@scope) then @scope.selectedGrouping=@settings.selectedGrouping
      getPersistentSettings : ->
        if (!@scope) then return
        @settings.selectedGrouping=@scope.selectedGrouping
      canHandleResults : (yasr) -> yasr.results?.getVariables?!
      draw : !->
        @scope = $rootScope.$new!
        scope = @scope
        scope.scroll = !->
          if (scope.visible<scope.groups.length)
            scope.visible+=30
            scope.visibleGroups = scope.groups.slice(0,scope.visible)
        scope.collapseAll = !->
          for group in scope.groups then group.open=false
        scope.expandAll = !->
          for group in scope.groups then group.open=true
        updateGroups = !->
          groups = {}
          gresMap = {}
          scope.vars = yasr.results.getVariables!.slice(0)
          scope.vars.splice(scope.vars.indexOf(scope.selectedGrouping),1)
          for binding in yasr.results.getBindings!
            groups[binding[scope.selectedGrouping].value]=true
            gresMap.[][binding[scope.selectedGrouping].value].push(binding)
          scope.groups = [ { open:false, name:group, bindings:gresMap[group]} for group of groups ]
          scope.groups.sort((a,b) -> a.name<b.name)
          scope.visible = 30
          scope.visibleGroups = scope.groups.slice(0,scope.visible)
        @scope.availableGroupings = yasr.results.getVariables!
        @scope.selectedGrouping = @scope.availableGroupings[0]
        if (@settings?.selectedGrouping?) then @scope.selectedGrouping = @settings.selectedGrouping
        @scope.$watch 'selectedGrouping', (nv) ->
           updateGroups(nv)
        yasr.resultsContainer.html($compile('<div ng-include="\'partials/grouped.html\'"></div>')(@scope))
        @scope.$digest!
    }
