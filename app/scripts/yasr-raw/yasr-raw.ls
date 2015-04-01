angular.module("app").filter 'to_trusted' ($sce) ->
  (text) -> $sce.trustAsHtml(text)
angular.module("app").run ($compile,$rootScope) !->
  YASR.plugins.raw = (yasr) ->
    {
      yasr : yasr
      name : "RAW"
      hideFromSelection : false
      priority : 1
      scope : void
      settings : void
      setPersistentSettings : (settings) !->
        @settings = settings
      getPersistentSettings : ->
        if (!@scope) then return
        cindex = -1
        for chart,index in @scope.charts
          if @scope.chart==chart then cindex=index
        @settings = {
          chartIndex:cindex
          dimensions:{}
          options:[]
        }
        for pname,pf of @scope.model.dimensions!._
          @settings.dimensions[pname]=pf!
        if cindex!=-1 then for ofu in @scope.charts[cindex].options!
          @settings.options.push(if typeof ofu() != "function" then ofu() else void)
        @settings
      canHandleResults : (yasr) ->
        yasr.results && yasr.results.getVariables && yasr.results.getVariables()
      draw : !->
        scope = $rootScope.$new!
        scope.lastError = 0
        scope.text=yasr.plugins.table.getDownloadInfo!.getContent!.replace(/^ /gm,"").replace(/ ,$/gm,"").replace(/ , /g,",").replace(/"/g,"")
        yasr.resultsContainer.html($compile('<div ng-controller="RawCtrl"><div ng-include=\'"partials/raw.html"\'></div></div>')(scope))
        scope.$digest!
        @scope=scope.$$childHead
        @scope.parse(scope.text)
        if (@settings?)
          if @settings.chartIndex!=-1
            @scope.chart=@scope.charts[@settings.chartIndex]
            @scope.model.clear!
            @scope.model = @scope.chart.model!
          /*for pname,pf of @scope.model.dimensions!._ when @settings.dimensions[pname]
            for pkey in @settings.dimensions[pname]
              dim = void
              for pdim in @scope.metadata when pdim.key==pkey then dim=pdim
              if (dim?) then pf.value.push(dim) */
          @scope.$digest!
          @settings = void
        window.ts=@scope
    }
