$(document).ready(function(){
	// all delegate form
	if (gon.edit_all_delegate){
		// load the date time pickers
    var startDateTextBox = $('#all_delegate_started_at');
    var endDateTextBox = $('#all_delegate_ended_at');
		startDateTextBox.datepicker({
			dateFormat: 'dd/mm/yy',
	    onSelect: function (selectedDateTime){
		    endDateTextBox.datetimepicker('option', 'minDate', startDateTextBox.datepicker('getDate') );
	    }
		});
		if (gon.started_at !== undefined && gon.started_at.length > 0)
		{
			startDateTextBox.datepicker("setDate", new Date(gon.started_at));
		}
		
		endDateTextBox.datepicker({
			dateFormat: 'dd/mm/yy',
	    onSelect: function (selectedDateTime){
		    startDateTextBox.datetimepicker('option', 'maxDate', endDateTextBox.datetimepicker('getDate') );
	    }
		});
		if (gon.ended_at !== undefined && gon.ended_at.length > 0)
		{
			endDateTextBox.datepicker("setDate", new Date(gon.ended_at));
		}
	}
	
});

