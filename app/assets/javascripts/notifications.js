// enable form fields for the provided type
function enable_notifications(type){
	$('#' + type + '_notifications input').removeAttr('disabled');
	$('#' + type + '_notifications select').removeAttr('disabled');
	$('#' + type + '_notifications').css('opacity', 1.0);
	$('#' + type + '_notifications').css('filter', 'alpha(opacity=100)');
}

function disable_all_fields(type){
	$('#' + type + '_notifications input').attr('disabled', 'disabled');
	$('#' + type + '_notifications select').attr('disabled', 'disabled');
	$('#' + type + '_notifications').fadeTo('fast', 0.5);
}

function enable_all_fields(type){
	$('#' + type + '_notifications input').removeAttr('disabled');
	$('#' + type + '_notifications select').removeAttr('disabled');
	$('#' + type + '_notifications').fadeTo('fast', 1.0);
}

function all_clicked(type){
	$('input#' + type + '_none').removeAttr('checked');
}

function none_clicked(type){
	$('input#' + type + '_all').removeAttr('checked');
}

$(document).ready(function(){
	if (gon.notifications){
		if (gon.enable_notifications) {
			// enable new file
			enable_notifications('language');
			enable_notifications('new_file');
			enable_notifications('new_delegate');
			enable_notifications('change_vote');
			enable_notifications('law_is_public');
		}

		// if want all notifications turn on fields
		// else, turn them off
		$("input[name='enable_notifications']").click(function(){
			if ($(this).val() === 'true') {
			  enable_all_fields('language');
			  enable_all_fields('new_file');
			  enable_all_fields('new_delegate');
  			enable_all_fields('change_vote');
  			enable_all_fields('law_is_public');
			} else {
			  disable_all_fields('language');
			  disable_all_fields('new_file');
			  disable_all_fields('new_delegate');
  			disable_all_fields('change_vote');
  			disable_all_fields('law_is_public');
			}
		});


		// register click events to clear out other form fields
		// for new files
		$('input#files_all').click(function(){
			all_clicked('files');
		});
		$('input#files_none').click(function(){
			none_clicked('files');
		});
		$('input#new_delegates_all').click(function(){
			all_clicked('new_delegates');
		});
		$('input#new_delegates_none').click(function(){
			none_clicked('new_delegates');
		});
		// for change vote
		$('input#change_votes_all').click(function(){
			all_clicked('change_votes');
		});
		$('input#change_votes_none').click(function(){
			none_clicked('change_votes');
		});
		// for law is public
		$('input#law_is_public_all').click(function(){
			all_clicked('law_is_public');
		});
		$('input#law_is_public_none').click(function(){
			none_clicked('law_is_public');
		});


	}

});
