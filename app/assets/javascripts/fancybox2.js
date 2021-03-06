  function focus_fancybox_input ()
  {
    if (gon.highlight_first_form_field)
    {
      $("#fancybox-content :input:visible:enabled:first").focus();
    }

  }

	// if a link with 'fancybox-nested' class is clicked, get the html and replace with current html
	function fancybox_nested_links() {
		$.get($(this).attr('href'), function(data){
			// pull out the html starting with div class="content"
			var x = $('div.content', data).html();
			// insert the new html
			$('#fancybox-content div.content').html(x);
			// register any new fancybox-nested links
			$('#fancybox-content a.fancybox-nested').click(fancybox_nested_links);
			focus_fancybox_input();
		});

		return false;
	}


$(document).ready(function(){

	// register click function for 'fancybox-nested' class that should only be used on pages that are opened in fancybox
	$('#fancybox-content a.fancybox-nested').on('click', fancybox_nested_links);

	// register fancybox
	$("a.fancybox").fancybox({
    transitionIn: 'elastic',
    transitionOut: 'elastic',
	  width: 400,
		onComplete: function ()
		{
		  focus_fancybox_input();
	  }
  });

  $("a#fancybox_inline").fancybox({
		'hideOnContentClick': true
	});

	$("a#fancybox_pdf").fancybox({
    'width': $(window).width() * .8,
    'height': $(window).height() * .8,
    'type':'iframe',
		'hideOnContentClick': true
  });

});
