$(document).ready(function(){

	if(gon.passed_laws_filter){
    var locale = I18n.currentLocale();
    if (locale == "en"){
      locale = "";
    }
    $.datepicker.setDefaults( $.datepicker.regional[ locale ] );

		// load the date pickers
		$('#start_date').datepicker({
				dateFormat: 'yy-mm-dd', 
        changeYear: true,
        yearRange: "2010:2013",
        changeMonth: true,
				onSelect: function (selectedDateTime){
				    var start = $(this).datetimepicker('getDate');
				    $('#end_date').datetimepicker('option', 'minDate', new Date(start.getTime()));
            // update data table
            passed_laws_dt.fnDraw();
				}
		});
		$('#end_date').datepicker({
				dateFormat: 'yy-mm-dd', 
        changeYear: true,
        yearRange: "2010:2013",
        changeMonth: true,
				onClose: function(dateText, inst) {
				    var startDateTextBox = $('#start_date');
				    if (startDateTextBox.val() != '') {
				        var testStartDate = new Date(startDateTextBox.val());
				        var testEndDate = new Date(dateText);
				        if (testStartDate > testEndDate)
				            startDateTextBox.val(dateText);
				    }
				    else {
				        startDateTextBox.val(dateText);
				    }
				},
				onSelect: function (selectedDateTime){
				    var end = $(this).datetimepicker('getDate');
				    $('#start_date').datetimepicker('option', 'maxDate', new Date(end.getTime()) );
            // update data table
            passed_laws_dt.fnDraw();
				}
		});
	}
});
