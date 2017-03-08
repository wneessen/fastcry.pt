// FileDrop init
var entryBox = document.getElementById('entryBox');
if (typeof entryBox !== 'undefined' || entryBox !== '') {
	// Init filedrop
	var options = {input: false,};
	var zone = new FileDrop('entryBox', options);

	zone.event('send', function (files) {
		var xhr = new XMLHttpRequest();
		files.each(function (file) {

			// Error handling
			file.event('error', function (e, xhr) {	
				zone.el.value = '';
				console.log(xhr.status);
				// nginx returned 413, not fastcrypt
				if (xhr.status === 413) {
					swal({
						title:	'Oops!',
						text:	'Sorry, but the file you dropped, exceeds the upload limit.',
						type:	'error',
						confirmButtonText: 'That\s ok. I\'ll choose a smaller file.',
					});
					return false;
				}

				// fastcrypt returned errors
				var responseObj = JSON.parse(xhr.responseText);
				if (responseObj.statuscode === 406) {
					swal({
						title:	'Oops!',
						text:	'Sorry, but we do not support the type of file you dropped.',
						type:	'error',
						confirmButtonText: 'That\s ok. I\'ll choose a different file.',
					});
				}
				if (responseObj.statuscode === 413) {
					swal({
						title:	'Oops!',
						text:	'Sorry, but the file you dropped, exceeds the upload limit.',
						type:	'error',
						confirmButtonText: 'That\s ok. I\'ll choose a smaller file.',
					});
				}
				if (responseObj.statuscode === 500) {
					swal({
						title:	'Oops!',
						text:	'An unexpected error occured. We are very sorry about that.',
						type:	'error',
						confirmButtonText: 'That\s ok. I\'ll try again later.',
					});
				}
				return false;
			});

			// Progress bar
			file.event('sendXHR', function () {
				fd.byID('bar_zone10').style.width = 0;
			});
			file.event('progress', function (current, total) {
				var width = current / total * 100 + '%';
				console.log('Progress: ' + width);
				fd.byID('bar_zone10').style.width = width;
			});
			
			// All good
			file.event('done', function (xhr) {
				var encPass = document.getElementById('entryPass').value;
				if (typeof encPass !== 'undefined' && encPass !== '') {
					encPass.value = '';
				};
				zone.el.value = '';
				var responseObj = JSON.parse(xhr.responseText);
				
				swal({
					title:		'All set!',
					text:		successData(responseObj.absurl, responseObj.password),
					html:		true,
					type:		'success',
	
					showCancelButton:	false,
					closeOnConfirm:		true,
				});
			});
			
			// XHR object setup
			file.event('xhrSetup', function (xhr) {
				var encPass = document.getElementById('entryPass').value;
				if (typeof encPass !== 'undefined' && encPass !== '') {
					xhr.setRequestHeader('X-Encryption-Pass', encPass);
				}
			});
			// Send the file
			file.sendTo('/api/v1/upload');
		});
	});
}
