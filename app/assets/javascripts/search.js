var agenda_laws_only = true;
var agenda_dt;

$(document).ready(function(){
  var value = getParameterByName('laws_only');
  if (value == "false"){
    agenda_laws_only = false;
  }


  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });


  $('#voting_results_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#voting_results_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 0 ] }
    ],
    "iDisplayLength": 150,
    "aLengthMenu": [[25, 50, 100, 150], [25, 50, 100, 150]],
    "fnInitComplete": function () {
	    $("#voting_results_datatable td a.fancybox").fancybox({
        transitionIn: 'elastic',
        transitionOut: 'elastic',
	      width: 400,
		    onComplete: function ()
		    {
		      focus_fancybox_input();
	      }
      });
    }
  });

  agenda_dt = $('#agendas_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#agendas_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 8 ] }
    ],
    "iDisplayLength": 50,
    "aLengthMenu": [[10, 20, 50, 100], [10, 20, 50, 100]],
    "fnServerParams": function ( aoData ) {
      aoData.push( { name: "laws_only", value: agenda_laws_only} );
    },
    "fnInitComplete": function () {
	    $("#agendas_datatable td a.fancybox").fancybox({
        transitionIn: 'elastic',
        transitionOut: 'elastic',
	      width: 400,
		    onComplete: function ()
		    {
		      focus_fancybox_input();
	      }
      });
    }
  });

  $('#upload_files_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#upload_files_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "bFilter": false,
    "bInfo": false,
    "aaSorting": [[1, 'desc']],
    "iDisplayLength": 25,
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 7 ] }
    ]
  });

  $('#deleted_files_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#deleted_files_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "bFilter": false,
    "bInfo": false,
    "iDisplayLength": 25,
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 8 ] }
    ]
  });

});

