var agenda_laws_only = true;
var agenda_dt;
var laws_dt;

  function register_fancybox_live_click(){
    $(function(){ 
      $("a.fancybox_live").live("click", function() {
        console.log('fancybox live click event');

        $(this).filter(':not(.fb_on)').fancybox({
          transitionIn: 'elastic',
          transitionOut: 'elastic',
          width: 400,
          onComplete: function ()
          {
            focus_fancybox_input();
          }
        }).addClass('fb_on');

        $(this).triggerHandler('click');
        return false;
      });
    }); 
  }


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
    "fnDrawCallback": function () {
	    $("#voting_results_datatable td a.fancybox_live").fancybox({
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
      { 'bSortable': false, 'aTargets': [ 9 ] }
    ],
    "iDisplayLength": 50,
    "aLengthMenu": [[10, 20, 50, 100], [10, 20, 50, 100]],
    "fnServerParams": function ( aoData ) {
      aoData.push( { name: "laws_only", value: agenda_laws_only} );
    },
    "fnDrawCallback": function () {
	    $("#agendas_datatable td a.fancybox_live").fancybox({
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



  laws_dt = $('#laws_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#laws_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 8 ] }
    ],
    "iDisplayLength": 50,
    "fnDrawCallback": function () {
	    $("#laws_datatable td a.fancybox_live").fancybox({
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


  $('#passed_laws_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#passed_laws_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 10,
    "aaSorting": [[0, 'desc']]
  });

  $('#members_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#members_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 50,
    "bLengthChange": false

  });

  $('#voting_results_public_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#voting_results_public_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 150,
    "aLengthMenu": [[25, 50, 100, 150], [25, 50, 100, 150]]
  });

  $('#member_votes_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#member_votes_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 25,
    "aaSorting": [[0, 'desc']]
  });


});

