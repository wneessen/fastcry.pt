// Filename:		fastcrypt.js
// Description:		JavaScript function library for fastcry.pt
// Creator:			Winfried Neessen <wn@neessen.net>

// Upload the text area data to the API // postData() {{{
function postData() {
	var entryForm	= document.getElementById('entryForm');
	var entryBox	= document.getElementById('entryBox');
	if (
		(typeof entryBox === 'undefined' || entryBox === null) ||
		(typeof entryForm === 'undefined' || entryForm === null)
	) {
		console.log('An error occured. "entryForm" or "entryBox" not found');
		swal({
			title:	'Holy smokes!',
			text:	'Something bad happend. We can\'t procceed any further. I am very sorry.',
			type:	'error',
			confirmButtonText: 'That\'s ok, I\'ll try again later',
		});
		return false;
	}
	if (entryBox.value === '') {
		console.log('entryBox is empty. Please fill in some data');
		swal({
			title:	'Oops!',
			text:	'You haven\'t entered any data.',
			type:	'error',
			confirmButtonText: 'I\'ll fix that!',
		});
		return false;
	}
	var entryData = entryBox.value;

	// Let's call the API
	var xhr = new XMLHttpRequest();
	xhr.addEventListener('load', function(event) {
		var responseObj = JSON.parse(xhr.responseText);

		if (responseObj.statuscode === 200) {
			entryBox.value = '';
			swal({
				title:		'All set!',
				text:		successData(responseObj.url, responseObj.password),
				html:		true,
				type:		'success',

				showCancelButton:	false,
				closeOnConfirm:		true,
			});
		}
		else {
			swal({
				title:	'Oops!',
				text:	'We are very sorry, but we couldn\'t process your request.',
				type:	'error',
				confirmButtonText: 'That\'s cool. I\'ll try again later!',
			});
			return false;
		}
	}, false);
	console.log(entryForm);
	xhr.open(entryForm.method, entryForm.action, true);
	xhr.send(new FormData(entryForm));
}
// }}}

// Prepare the output for the alert modal // successData() {{{
function successData(url, pass) {
	var hostName	 = document.createTextNode(window.location.hostname).data;
	var response	 = 'Your entry has been successfully encrypted and stored.<span class="successModal" style="margin-top: 15px; display: block;">';
	response		+= '<label>Decryption URL:<input onclick="select()" style="margin: 0; margin-left: -0.1875rem; padding: 0 0.1875rem; display: block" type="text" name="url" value="https://' + hostName + url + '" /></label><br />';
	response		+= '<label>Password:<input onclick="select()" style="display: block" type="text" name="pass" value="' + pass + '" /></label>';
	response		+= '</span>';

	return response;
}
// }}}

// vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
