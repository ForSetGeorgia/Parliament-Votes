$(document).ready(function(){

  function processing_fadein() {
    $('#processing_file_text').fadeIn("slow", processing_fadeout);
  }

  function processing_fadeout() {
    $('#processing_file_text').fadeOut("slow", processing_fadeout);
  }

  function animate_processing(){
    $('#processing_file_text').animate({opacity: 0}, 'slow', function(){
      $('#processing_file_text').animate({opacity: 1}, 'slow', function(){
        animate_processing();
      ;})
    ;})
  }

  $('form#upload_file').submit(function(){
    $('#processing_file').fadeIn("slow");
    animate_processing();
  });

});
