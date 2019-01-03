$(document).ready(function(){

  function animate_request_processing(ths){
    var $text = $(ths).find(' + .processing_request .processing_request_text');
    $text.animate({opacity: 0}, 'slow', function(){
      $text.animate({opacity: 1}, 'slow', function(){
        animate_request_processing(ths);
      ;})
    ;})
  }

  $('table#laws_datatable tbody').on('click', 'tr td:last-of-type a.btn-make-public', function(e){
    var ths = this;
    // turn off all links to make sure no others are clicked while this is processing
    $('a.btn-make-public').fadeOut('fast');
    // show processing text
    $(ths).find(' + .processing_request').fadeIn("fast");
    animate_request_processing(ths);
  });

});
