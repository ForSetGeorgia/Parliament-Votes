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
        yearRange: gon.parl_start_year + ":" + gon.parl_end_year,
        changeMonth: true,
				onSelect: function (selectedDateTime){
				    var start = $(this).datepicker('getDate');
				    $('#end_date').datepicker('option', 'minDate', new Date(start.getTime()));
            // update data table
            passed_laws_dt.fnDraw();
				}
		});
		$('#end_date').datepicker({
				dateFormat: 'yy-mm-dd', 
        changeYear: true,
        yearRange: gon.parl_start_year + ":" + gon.parl_end_year,
        changeMonth: true,
				onSelect: function (selectedDateTime){
				    var end = $(this).datepicker('getDate');
				    $('#start_date').datepicker('option', 'maxDate', new Date(end.getTime()) );
            // update data table
            passed_laws_dt.fnDraw();
				}
		});

    // update the year range when the parliament options change
    $('input[name="law_parliament_options_checkbox"]').click(function(){
      var start_ary = [];
      var end_ary = [];
      var start, end;
      var now = new Date().getFullYear().toString();
      $('input[name="law_parliament_options_checkbox"]:checked').each(function(){
        start_ary.push($(this).data('start'));
        end_ary.push($(this).data('end'));
      });

      if (start_ary.length == 0){
        start = gon.parl_start_year;
      }else{
        start = Math.min.apply(Math,start_ary).toString();
      }
      if (end_ary.length == 0){
        end = gon.parl_end_year;
      }else{
        end = Math.max.apply(Math,end_ary).toString();
      }

      if (end > now){
        end = now
      }

      // if there are dates in the textbox and they are not in the new range, reset the values
      // also reset default date
      if ($('#start_date').datepicker('getDate') != null){
        var old_year = $('#start_date').datepicker('getDate').getFullYear().toString();
        if (start > old_year || end < old_year){
          $('#start_date').datepicker('setDate', '');
			    $('#start_date').datepicker('option', 'maxDate', '');
        }
      } else if (start > now || end < now){
        $('#start_date').datepicker('option', 'defaultDate', new Date(start + '1-1'));
      } else{
        $('#start_date').datepicker('option', 'defaultDate', new Date());
      }
      if ($('#end_date').datepicker('getDate') != null){
        var old_year = $('#end_date').datepicker('getDate').getFullYear().toString();
        if (start > old_year || end < old_year){
          $('#end_date').datepicker('setDate', '');
			    $('#end_date').datepicker('option', 'minDate', '');
        }
      } else if (start > now || end < now){
        $('#end_date').datepicker('option', 'defaultDate', new Date(start + '1-1'));
      } else{
        $('#end_date').datepicker('option', 'defaultDate', new Date());
      }

      // if value exists for start or end, make sure the min/max value for end/start are set
      var d = $('#start_date').datepicker('getDate');
      if (d != null){
		    $('#end_date').datepicker('option', 'minDate', new Date(d.getTime()));
        if ($('#end_date').datepicker('option', 'defaultDate') == null || end < $('#end_date').datepicker('option', 'defaultDate').getFullYear().toString()){
          $('#end_date').datepicker('option', 'defaultDate', $('#end_date').datepicker('option', 'minDate'));
        }
      }
      d = $('#end_date').datepicker('getDate');
      if (d != null){
		    $('#start_date').datepicker('option', 'maxDate', new Date(d.getTime()));
        if ($('#start_date').datepicker('option', 'defaultDate') == null || start > $('#start_date').datepicker('option', 'defaultDate').getFullYear().toString()){
          $('#start_date').datepicker('option', 'defaultDate', $('#start_date').datepicker('option', 'maxDate'));
        }
      }

      // reset year range
      $("#start_date").datepicker( "option", "yearRange", start + ":" + end );
      $("#end_date").datepicker( "option", "yearRange", start + ":" + end );
      
      $("#start_date").datepicker("refresh");
      $("#end_date").datepicker( "refresh" );

      
    });
	}
});
