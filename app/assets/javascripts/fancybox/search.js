$(document).ready(function(){
  $.extend( $.fn.dataTableExt.oStdClasses, {
      "sWrapper": "dataTables_wrapper form-inline"
  });

  $('#possible_sessions_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#possible_sessions_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 50,
    "bAutoWidth": false,
    "aaSorting": [[1, 'asc']],
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 0 ] }
    ]
  });

  $('#all_sessions_datatable').dataTable({
    "sDom": "<'row-fluid'<'span6'l><'span6'f>r>t<'row-fluid'<'span6'i><'span6'p>>",    
    "sPaginationType": "bootstrap",
    "bJQueryUI": true,
    "bProcessing": true,
    "bServerSide": true,
    "sAjaxSource": $('#all_sessions_datatable').data('source'),
    "oLanguage": {
      "sUrl": gon.datatable_i18n_url
    },
    "iDisplayLength": 50,
    "bAutoWidth": false,
    "aaSorting": [[1, 'asc']],
    "aoColumnDefs": [
      { 'bSortable': false, 'aTargets': [ 0 ] }
    ]
  });

});    

