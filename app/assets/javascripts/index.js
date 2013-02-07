$(document).ready(function(){

  function procressing_fadein() {
    $('#processing_file_text').fadeIn("slow", procressing_fadeout);
  }

  function procressing_fadeout() {
    $('#processing_file_text').fadeOut("slow", procressing_fadeout);
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
