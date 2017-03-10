// Filename:		fastcrypt.js
// Description:		JavaScript function library for fastcry.pt
// Creator:			Winfried Neessen <wn@neessen.net>

// Upload the text area data to the API // postData() {{{
function postData() {
	var entryForm	= document.getElementById('entryForm');
	var entryBox	= document.getElementById('entryBox');
	var entryPass	= document.getElementById('entryPass');
	if (
		(typeof entryBox === 'undefined' || entryBox === null) ||
		(typeof entryPass === 'undefined' || entryPass === null) ||
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

	// Lets call the API
	var xhr = new XMLHttpRequest();
	xhr.addEventListener('load', function(event) {
		var responseObj = JSON.parse(xhr.responseText);

		if (responseObj.statuscode === 200) {
			entryBox.value = '';
			entryPass.value = '';
			swal({
				title:		'All set!',
				text:		successData(responseObj.absurl, responseObj.password),
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
	xhr.open(entryForm.method, '/api/v1/store', true);
	xhr.send(new FormData(entryForm));
}
// }}}

// Prepare the output for the alert modal // successData() {{{
function successData(url, pass) {
	var response	 = 'Your entry has been successfully encrypted and stored.<span class="successModal" style="margin-top: 15px; display: block;">';
	response		+= '<label>Decryption URL:<input onclick="select()" style="margin: 0; margin-left: -0.1875rem; padding: 0 0.1875rem; display: block" type="text" name="url" value="' + url + '" /></label><br />';
	response		+= '<label>Password:<input onclick="select()" style="display: block" type="text" name="pass" value="' + pass + '" /></label>';
	if (pass !== '** SELF-PROVIDED **') {
		response		+= '<br /><label>Decryption URL (including Password):<input onclick="select()" style="display: block" type="text" name="pass" value="' + url + '?fastcrypt_pass=' + encodeURIComponent(pass) + '" />';
		response		+= '<small><strong>WARNING:</strong> Do not send this URL via unencrypted channels</small></label>'
	}
	response		+= '</span>';

	return response;
}
// }}}

// Decrypt the data via the API // decData() {{{
function decData() {
	var decryptForm = document.getElementById('decryptForm');
	var decryptPass	= document.getElementById('decryptPass');
	if (
		(typeof decryptPass === 'undefined' || decryptPass === null) ||
		(typeof decryptForm === 'undefined' || decryptForm === null)
	) {
		console.log('An error occured. "decryptForm" or "decryptPass" not found');
		swal({
			title:	'Holy smokes!',
			text:	'Something bad happend. We can\'t procceed any further. I am very sorry.',
			type:	'error',
			confirmButtonText: 'That\'s ok, I\'ll try again later',
		});
		return false;
	}

	// Lets call the API
	var styleSheet = document.styleSheets[0];
	var xhr = new XMLHttpRequest();
	xhr.addEventListener('load', function(event) {
		var responseObj = JSON.parse(xhr.responseText);

		if (responseObj.statuscode === 200) {
			var fileExt = responseObj.filetype.split('/')[1];
			if (fileExt === 'plain') { fileExt = 'txt' }
			decryptPass.value = ''
			styleSheet.insertRule('.sweet-alert { width: 70%; left: 50%; position: fixed; margin-left: -35%; }', 3);
			var imgPattern	= /^image\//;
			var pdfPattern	= /^application\/pdf/;
			var matchImage	= responseObj.filetype.match(imgPattern);
			var matchPdf	= responseObj.filetype.match(pdfPattern);
			if (matchImage) {
				swal({
					title:		'Decryption done!',
					text:		successDecImg(),
					html:		true,
					type:		'success',
	
					showCancelButton:	false,
					closeOnConfirm:		true,
				});
				showImage(responseObj.data);
				var downloadBtn = document.getElementById('downloadBtn');
				if (typeof downloadBtn !== 'undefined' && downloadBtn !== null) {
					downloadBtn.href	= responseObj.data;
					downloadBtn.target	= '_blank';
					downloadBtn.download= 'download.' + fileExt;
				}
			}
			else if (matchPdf) {
				swal({
					title:		'Decryption done!',
					text:		successDecPdf(responseObj.data),
					html:		true,
					type:		'success',
	
					showCancelButton:	false,
					closeOnConfirm:		true,
				});
				var downloadBtn = document.getElementById('downloadBtn');
				if (typeof downloadBtn !== 'undefined' && downloadBtn !== null) {
					downloadBtn.href	= responseObj.data;
					downloadBtn.target	= '_blank';
					downloadBtn.download= 'download.' + fileExt;
				}
			}
			else {
				swal({
					title:		'Decryption done!',
					text:		successDec(responseObj.data),
					html:		true,
					type:		'success',
	
					showCancelButton:	false,
					closeOnConfirm:		true,
				});
				var downloadBtn = document.getElementById('downloadBtn');
				if (typeof downloadBtn !== 'undefined' && downloadBtn !== null) {
					downloadBtn.href	= 'data:text/plain,' + responseObj.data;
					downloadBtn.target	= '_blank';
					downloadBtn.download= 'download.' + fileExt;
				}
			}
		}
		else {
			styleSheet.insertRule('.sweet-alert { width: 40%; left: 50%; position: fixed; margin-left: -20%; }', 4);
			swal({
				title:	'Oops!',
				text:	'We are very sorry, but we couldn\'t process your request.',
				type:	'error',
				confirmButtonText: 'That\'s cool. I\'ll try again later!',
			});
			return false;
		}
	}, false);
	xhr.open(decryptForm.method, decryptForm.action, true);
	xhr.send(new FormData(decryptForm));
}
// }}}

// Prepare the output for the decryption alert modal // successDec() {{{
function successDec(data) {
	var response	 = 'Your note has been successfully decrypted.<span class="successModal" style="margin-top: 15px; display: block;">';
	response		+= '<label>Your note:';
	response		+= '<textarea id="decBox" onclick="select()" style="margin: 0; margin-left: -0.1875rem; padding: 0 0.1875rem; display: block" name="yourdata">' + data + '</textarea>';
	response		+= '</label><br /><a href="#" id="downloadBtn">Download as file</a></span>';

	return response;
}
// }}}

// Prepare the output for the decryption alert modal (with image) // successDecImg() {{{
function successDecImg() {
	var response	 = 'Your note has been successfully decrypted.<span class="successModal" style="margin-top: 15px; display: block;">';
	response		+= '<label>Your image:<br />';
	response		+= '<div id="imgDiv"><canvas id="decImg"></canvas></div>';
	response		+= '</label><br /><a href="#" id="downloadBtn">Download image as file</a></span>';

	return response;
}
// }}}

// Prepare the output for the decryption alert modal (with PDF) // successDecPdf() {{{
function successDecPdf(data) {
	var response	 = 'Your note has been successfully decrypted.<span class="successModal" style="margin-top: 15px; display: block;">';
	response		+= '<label>Your PDF:<br />';
	response		+= '<div id="pdfDiv"><object data="' + data + '" type="application/pdf" width="100%" height="100%"></object></div>';
	response		+= '</label><br /><a href="#" id="downloadBtn">Download PDF as file</a></span>';

	return response;
}
// }}}

// Load an image and present it // loadImage() {{{
function showImage(data) {
	var decImg		= document.getElementById('decImg').getContext("2d");
	var tempImage	= new Image();
	tempImage.onload = function(e) {
		var w = e.target.width;
		var h = e.target.height;
		decImg.canvas.width = w;
		decImg.canvas.height = h;
		decImg.drawImage(tempImage, 1, 1);
	}
	tempImage.src = data;
	return true;
}
// }}}

// UTF8-safe Base64 encoding // b64Encode() {{{
function b64Encode(string) {
	return btoa(encodeURIComponent(string).replace(/%([0-9A-F]{2})/g, function(match, p1) {
		return String.fromCharCode('0x' + p1);
	}));
}
// }}}

// vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
