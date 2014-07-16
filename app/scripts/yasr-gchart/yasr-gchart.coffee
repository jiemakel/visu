'use strict'
YASR.plugins.gchart = (yasr, parent, options) ->
	id = yasr.container.closest('[id]').attr('id')
	if (!yasr.options.gchart?) then yasr.options.gchart = {}
	if (!yasr.options.gchart.motionChartState?) then yasr.options.gchart.motionChartState = localStorage.getItem(id+"_motionChartState")
	if (!yasr.options.gchart.chartConfig?) then yasr.options.gchart.chartConfig = localStorage.getItem(id+"_chartConfig")
	googleType = (binding) ->
		if (binding.type? && (binding.type == 'typed-literal' || binding.type == 'literal'))
			switch (binding.datatype)
				when "http://www.w3.org/2001/XMLSchema#float", "http://www.w3.org/2001/XMLSchema#decimal", "http://www.w3.org/2001/XMLSchema#int", "http://www.w3.org/2001/XMLSchema#integer", "http://www.w3.org/2001/XMLSchema#long", "http://www.w3.org/2001/XMLSchema#gYearMonth", "http://www.w3.org/2001/XMLSchema#gYear", "http://www.w3.org/2001/XMLSchema#gMonthDay", "http://www.w3.org/2001/XMLSchema#gDay", "http://www.w3.org/2001/XMLSchema#gMonth" then return "number"
				when "http://www.w3.org/2001/XMLSchema#date" then return "date"
				when "http://www.w3.org/2001/XMLSchema#dateTime" then return "datetime"
				when "http://www.w3.org/2001/XMLSchema#time" then return "timeofday"
				else return "string"
		else return "string"
	castGoogleType = (binding) ->
		if (!binding?) then return null
		if (binding.type? && (binding.type == 'typed-literal' || binding.type == 'literal'))
			switch (binding.datatype)
				when "http://www.w3.org/2001/XMLSchema#float", "http://www.w3.org/2001/XMLSchema#decimal", "http://www.w3.org/2001/XMLSchema#int", "http://www.w3.org/2001/XMLSchema#integer", "http://www.w3.org/2001/XMLSchema#long", "http://www.w3.org/2001/XMLSchema#gYearMonth", "http://www.w3.org/2001/XMLSchema#gYear", "http://www.w3.org/2001/XMLSchema#gMonthDay", "http://www.w3.org/2001/XMLSchema#gDay", "http://www.w3.org/2001/XMLSchema#gMonth" then return Number(binding.value)
				when "http://www.w3.org/2001/XMLSchema#date", "http://www.w3.org/2001/XMLSchema#dateTime", "http://www.w3.org/2001/XMLSchema#time" then return new Date(binding.value)
				else return binding.value
		else return binding.value
	editor = new google.visualization.ChartEditor()
	google.visualization.events.addListener(editor,'ok', () ->
		chartWrapper = editor.getChartWrapper()
		if (chartWrapper.getChartType()=="MotionChart")
			yasr.options.gchart.motionChartState = chartWrapper.n
			localStorage.setItem(id+"_motionChartState",yasr.options.gchart.motionChartState)
			chartWrapper.setOption("state",yasr.options.gchart.motionChartState)
			chartWrapper.setOption("width",800)
			chartWrapper.setOption("height",500)
			google.visualization.events.addListener(chartWrapper,'ready', () ->
				motionChart = chartWrapper.getChart()
				google.visualization.events.addListener(motionChart,'statechange', () ->
					yasr.options.gchart.motionChartState = motionChart.getState()
					localStorage.setItem(id+"_motionChartState",yasr.options.gchart.motionChartState)
				)
			)
		tmp = chartWrapper.getDataTable()
		chartWrapper.setDataTable(null)
		yasr.options.gchart.chartConfig = chartWrapper.toJSON()
		localStorage.setItem(id+"_chartConfig",yasr.options.gchart.chartConfig)
		chartWrapper.setDataTable(tmp)
		chartWrapper.draw()
	)
	{
		options : options
		container : $('<div><div id="chart"></div></div>')
		parent : parent
		yasr : yasr
		name : "Google Chart"
		hideFromSelection : false
		priority : 5
		editor : editor
		canHandleResults : (yasr) -> yasr.results?.getVariables()?.length > 0;
		draw : () ->
			parent.html('<button id="typeeditor" class="yasr_btn" style="float:right;position:relative; top:-30px;margin-bottom:-30px">Type</button><div id="chart"></div>')
			$('#typeeditor').click(() -> editor.openDialog(wrapper))
			dataTable = new google.visualization.DataTable()
			results = yasr.results.getAsJson()
			for variable in results.head.vars
				type = googleType(results.results.bindings[0][variable])
				dataTable.addColumn(type,variable)
			for binding in results.results.bindings
				row = []
				for variable in results.head.vars
					row.push(castGoogleType(binding[variable]))
				dataTable.addRow(row)
			if (yasr.options.gchart.chartConfig)
				wrapper = new google.visualization.ChartWrapper(yasr.options.gchart.chartConfig)
				if (wrapper.getChartType()=="MotionChart" && yasr.options.gchart.motionChartState?) 
					wrapper.setOption("state",yasr.options.gchart.motionChartState)
					google.visualization.events.addListener(wrapper,'ready', () ->
						motionChart = wrapper.getChart()
						google.visualization.events.addListener(motionChart,'statechange', () ->
							yasr.options.gchart.motionChartState = motionChart.getState()
							localStorage.setItem(id+"_motionChartState",yasr.options.gchart.motionChartState)
						)
					)
				wrapper.setDataTable(dataTable)
			else
				wrapper = new google.visualization.ChartWrapper(
					chartType: 'Table'
					dataTable: dataTable
					options: {title: 'VISUalization'}
					containerId: 'chart'
				)
			wrapper.draw()
	}

