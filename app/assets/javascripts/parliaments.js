$(document).ready(function(){
	// parliament form
	if (gon.edit_parliament){
		// load the date time pickers
		$('#parliament_start_date').datepicker({
				dateFormat: 'dd-mm-yy',
		});
		if (gon.start_date !== undefined && gon.start_date.length > 0)
		{
			$("#parliament_start_date").datepicker("setDate", new Date(gon.start_date));
		}

		$('#parliament_end_date').datepicker({
				dateFormat: 'dd-mm-yy',
		});
		if (gon.end_date !== undefined && gon.end_date.length > 0)
		{
			$("#parliament_end_date").datepicker("setDate", new Date(gon.end_date));
		}
  }
});
