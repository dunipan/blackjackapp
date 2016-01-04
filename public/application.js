$(document).ready(function() {

	$(document).on('click', '#hit_form input', function() {

		$.ajax({
			type: 'POST', 
			url: '/game/player/hit'
		}).done(function(msg) {
			$('#game').replaceWith(msg);
		});
		return false;
	});

	$(document).on('click', '#stay_form input', function() {

		$.ajax({
			type: 'POST',
			url: '/game/player/stay'
		}).done(function(msg) {
			$('#game').replaceWith(msg)
		});
		return false;
	});

	$(document).on('click', '#dealer_button input', function() {

		$.ajax({
			type: 'POST',
			url: '/game/dealer/move'
		}).done(function(msg) {
			$('#game').replaceWith(msg)
		});
		return false;
	});


});