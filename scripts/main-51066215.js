(function(){function t(t,n){for(var e=-1,o=n.length>>>0;++e<o;)if(t===n[e])return!0;return!1}YASR.plugins.gmaps=function(n){var e;return e=n.container.closest("[id]").attr("id"),{yasr:n,name:"Google Maps",hideFromSelection:!1,priority:1,canHandleResults:function(n){return n.results&&n.results.getVariables&&n.results.getVariables()&&t("lat",n.results.getVariables())&&t("lon",n.results.getVariables())},draw:function(){function t(t){google.maps.event.addListener(t.marker,"click",function(){var n,e,r,i;n="<table>";for(e in r=t.res)i=r[e],n+="<tr><th>"+e+"</th><td>"+i.value+"</td></tr>";n+="</table>",a.setContent(n),a.open(o,t.marker)})}var e,o,r,a,i,l,s,p,u;for(n.resultsContainer.html('<div id="gmap"></div>'),e={mapTypeId:google.maps.MapTypeId.SATELLITE},o=new google.maps.Map(n.resultsContainer.find("div")[0],e),r=new google.maps.LatLngBounds,a=new google.maps.InfoWindow,i=0,s=(l=n.results.getBindings()).length;s>i;++i)p=l[i],u=new google.maps.LatLng(p.lat.value,p.lon.value),r.extend(u),t.call(this,{res:p,marker:new google.maps.Marker({position:u,map:o,title:null!=p.name?p.name.value:p.lat.value+","+p.lon.value})});o.fitBounds(r),o.panToBounds(r)}}}}).call(this),function(){YASR.plugins.kml=function(t){var n;return n=t.container.closest("[id]").attr("id"),{yasr:t,name:"KML",hideFromSelection:!1,priority:1,canHandleResults:function(){return!0},draw:function(){var n,e,o;n=t.yasqe.getOption("sparql").endpoint,e=t.yasqe.getValue(),o="http://demo.seco.tkk.fi/sparql2kml/?endpoint="+encodeURIComponent(n)+"&query="+encodeURIComponent(e),t.resultsContainer.html('<button id="kml-copy" class="yasr_btn" style="float:right;position:relative; top:-30px;margin-bottom:-30px">Copy</button><div>URL for KML file: <a href="" id="kml-url"></a> (<a id="kml-e4d" href="" target="_blank">in Europeana 4D</a>)</div>'),$("#kml-url").text(o).attr("href",o),$("#kml-e4d").attr("href","http://www.informatik.uni-leipzig.de:8080/e4D/?source1=1&kml1="+encodeURIComponent(o)),$("#kml-copy").click(function(){window.prompt("Copy to clipboard with Ctrl/Cmd-C",o)}),$.ajax("https://www.googleapis.com/urlshortener/v1/url",{data:JSON.stringify({key:"AIzaSyDtS96pmj2IeRdw81zobVDpCfs0rFphHvc",longUrl:o}),contentType:"application/json",type:"POST"}).success(function(t){o=t.id,$("#kml-url").text(o).attr("href",o),$("#kml-e4d").attr("href","http://www.informatik.uni-leipzig.de:8080/e4D/?source1=1&kml1="+encodeURIComponent(o))})}}}}.call(this),function(){"use strict";angular.module("app",["ui.router","ngStorage"]).config(["$stateProvider","$urlRouterProvider",function(t,n){return t.state("home",{url:"/?sparqlEndpoint&query&outputType&chartConfig&motionChartState",templateUrl:"partials/main.html",controller:"MainCtrl"}),n.otherwise("/")}])}.call(this),function(){"use strict";angular.module("app").controller("MainCtrl",["$window","$location","$http","$scope","$localStorage","$state","$stateParams","$q",function(t,n,e,o,r,a,i,l){var s,p,u,d;return null!=i.sparqlEndpoint&&(r.sparqlEndpoint=i.sparqlEndpoint),null!=r.sparqlEndpoint&&(o.sparqlEndpoint=r.sparqlEndpoint),o.shareLink=function(){var r;r=n.absUrl().substring(0,n.absUrl().indexOf("#"))+a.href(".",{sparqlEndpoint:o.sparqlEndpoint,query:s.getValue(),outputType:u.options.output,chartConfig:u.options.gchart.chartConfig,motionChartState:u.options.gchart.motionChartState}),o.shareLinkLoading=!0,e.post("https://www.googleapis.com/urlshortener/v1/url",{key:"AIzaSyDtS96pmj2IeRdw81zobVDpCfs0rFphHvc",longUrl:r}).then(function(n){o.shareLinkLoading=!1,t.prompt("Copy to clipboard with Ctrl/Cmd-C",n.data.id)},function(){o.shareLinkLoading=!1,t.prompt("Copy to clipboard with Ctrl/Cmd-C",r)})},s=YASQE(document.getElementById("yasqe"),{createShareLink:!1,sparql:{showQueryButton:!0,endpoint:o.sparqlEndpoint,query:""}}),null!=i.query&&s.setValue(i.query),o.sparqlEndpointInputValid=!0,p=void 0,o.$watch("sparqlEndpoint",function(t,n){null!=t&&(null!=p&&p.resolve(),p=l.defer(),e({method:"GET",url:t,params:{query:"ASK {}"},headers:{Accept:"application/sparql-results+json"},timeout:p.promise}).success(function(t){o.sparqlEndpointInputValid=null!=t["boolean"]}).error(function(){o.sparqlEndpointInputValid=!1})),t!==n&&(r.sparqlEndpoint=t,s.getOption("sparql").endpoint=t)}),u=YASR(document.getElementById("yasr"),{persistency:{outputSelector:i.outputType?!1:"visu",results:!1},getUsedPrefixes:s.getPrefixesFromQuery,output:null!=(d=i.outputType)?d:void 0,gchart:{chartConfig:i.chartConfig,motionChartState:i.motionChartState}}),u.yasqe=s,u.options.persistency.outputSelector="visu",s.options.sparql.handlers.success=function(t,n,e){return u.setResponse({response:t,contentType:e.getResponseHeader("Content-Type")})},s.options.sparql.handlers.error=function(t,n,e){var o;return o=n+" (response status code "+t.status+")",e&&e.length&&(o+=": "+e),u.setResponse({exception:o})},null!=i.sparqlEndpoint&&null!=i.query?s.query():void 0}])}.call(this),function(t){try{t=angular.module("app")}catch(n){t=angular.module("app",[])}t.run(["$templateCache",function(t){t.put("partials/main.html",'\n<div class="ui page grid">\n  <div class="column">\n    <h1 class="ui header center aligned">(Visual) SPARQL query tool</h1>\n    <div id="shareicondiv"><i id="shareicon" ng-click="shareLink()" ng-class="shareLinkLoading ? \'loading\' : \'share\'" class="icon"></i></div>\n    <div class="ui form">\n      <div ng-class="{ \'error\': !sparqlEndpointInputValid }" class="field">\n        <label>SPARQL endpoint</label>\n        <input ng-model="sparqlEndpoint" type="text"/>\n      </div>\n      <div id="yasqe"></div>\n    </div>\n    <div id="yasr"></div>\n  </div>\n</div>')}])}();