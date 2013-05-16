var agenda_laws_only = true;
var agenda_dt;
var laws_dt;
var passed_laws_dt;

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


function get_law_parliament_options(){
  x = [];
  $('input[name="law_parliament_options_checkbox"]:checked').each(function(){
    x.push($(this).val());
  });
  return x;
}

function get_member_parliament_options(){
  x = [];
  $('input[name="member_parliament_options_checkbox"]:checked').each(function(){
    x.push($(this).val());
  });
  return x;
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
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bStateSave": true,
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
      $("#voting_results_datatable td").filter(function() { return $.text([this]) == gon.table_cell_yes; })
       .addClass("table_cell_yes");
      $("#voting_results_datatable td").filter(function() { return $.text([this]) == gon.table_cell_no; })
       .addClass("table_cell_no");
      $("#voting_results_datatable td").filter(function() { return $.text([this]) == gon.table_cell_abstain; })
       .addClass("table_cell_abstain");
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
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bStateSave": true,
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
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bStateSave": true,
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
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bStateSave": true,
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
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bStateSave": true,
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


  passed_laws_dt = $('#passed_laws_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "bStateSave": true,
    "aoColumns": [{"sWidth":"100px"},null,null,null,null,null,null],
    "sAjaxSource": $('#passed_laws_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 10,
    "aaSorting": [[0, 'desc']],
    "fnServerParams": function ( aoData ) {
      aoData.push( { name: "parliament", value: get_law_parliament_options} ),
      aoData.push( { name: "start_date", value: $('#start_date').val()} ),
      aoData.push( { name: "end_date", value: $('#end_date').val()} )
    }
  });

  // when options change, update datatable
  $('input[name="law_parliament_options_checkbox"]').click(function(){
    passed_laws_dt.fnDraw();
  });

  var member_dt = $('#members_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "bStateSave": true,
    "sAjaxSource": $('#members_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 10,
    "fnServerParams": function ( aoData ) {
      aoData.push( { name: "parliament", value: get_member_parliament_options} );
    }
  });

  // when options change, update datatable
  $('input[name="member_parliament_options_checkbox"]').click(function(){
    member_dt.fnDraw();
  });

  $('#voting_results_public_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "bStateSave": true,
    "sAjaxSource": $('#voting_results_public_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 200,
    "bLengthChange": false,
    "fnDrawCallback": function () {
      $("#voting_results_public_datatable td").filter(function() { return $.text([this]) == gon.table_cell_yes; })
       .addClass("table_cell_yes");
      $("#voting_results_public_datatable td").filter(function() { return $.text([this]) == gon.table_cell_no; })
       .addClass("table_cell_no");
      $("#voting_results_public_datatable td").filter(function() { return $.text([this]) == gon.table_cell_abstain; })
       .addClass("table_cell_abstain");
    }
  });

  $('#member_votes_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bAutoWidth": false,
    "bStateSave": true,
    "sAjaxSource": $('#member_votes_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 25,
    "aaSorting": [[0, 'desc']],
    "fnDrawCallback": function () {
      $("#member_votes_datatable td").filter(function() { return $.text([this]) == gon.table_cell_yes; })
       .addClass("table_cell_yes");
      $("#member_votes_datatable td").filter(function() { return $.text([this]) == gon.table_cell_no; })
       .addClass("table_cell_no");
      $("#member_votes_datatable td").filter(function() { return $.text([this]) == gon.table_cell_abstain; })
       .addClass("table_cell_abstain");
    }
  });

  $('#users_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": false,
    "bProcessing": true,
    "bServerSide": true,
    "bDestroy": true,
    "bStateSave": true,
    "sAjaxSource": $('#users_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 10,
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 3 ] }
    ]
  });


});

