YASR.plugins.kml = (yasr, parent, options) ->
	id = yasr.container.closest('[id]').attr('id')
	{
		parent : parent
		yasr : yasr
		name : "KML"
		hideFromSelection : false
		priority : 1
		canHandleResults : (yasr) -> true
		draw : !->
			endpoint = yasr.yasqe.getOption('sparql').endpoint
			query = yasr.yasqe.getValue!
			url='http://demo.seco.tkk.fi/sparql2kml/?endpoint=' + encodeURIComponent(endpoint) + '&query=' + encodeURIComponent(query)
			parent.html('<button id="kml-copy" class="yasr_btn" style="float:right;position:relative; top:-30px;margin-bottom:-30px">Copy</button><div>URL for KML file: <a href="" id="kml-url"></a> (<a id="kml-e4d" href="" target="_blank">in Europeana 4D</a>)</div>')
			$('#kml-url').text(url).attr('href',url)
			$('#kml-e4d').attr('href','http://www.informatik.uni-leipzig.de:8080/e4D/?source1=1&kml1='+encodeURIComponent(url))
			$('#kml-copy').click(!-> window.prompt('Copy to clipboard with Ctrl/Cmd-C',url))
			$.ajax('https://www.googleapis.com/urlshortener/v1/url',
				data : JSON.stringify(
					key : "AIzaSyDtS96pmj2IeRdw81zobVDpCfs0rFphHvc"
					longUrl : url
				)
				contentType : 'application/json',
				type : 'POST'
			).success((data) !->
				url := data.id
				$('#kml-url').text(url).attr('href',url)
				$('#kml-e4d').attr('href','http://www.informatik.uni-leipzig.de:8080/e4D/?source1=1&kml1='+encodeURIComponent(url))
			)
	}

