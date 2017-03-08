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
				var progBarDiv	= document.getElementById('progBarDiv');
				var progBar		= document.getElementById('progressBar');
				if (typeof progBar !== 'undefined' && typeof progBarDiv !== 'undefined') {
					progBar.style.width = 0;
					progBarDiv.style.display = 'none';
				};
				zone.el.value = '';

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
			var progBarDiv	= document.getElementById('progBarDiv');
			if (typeof progBarDiv !== 'undefined') {
				progBarDiv.style.display = 'block';
			}
			file.event('sendXHR', function () {
				var progBar = document.getElementById('progressBar');
				if (typeof progBar !== 'undefined') {
					progBar.style.width = 0;
				}
			});
			file.event('progress', function (current, total) {
				var progBar	= document.getElementById('progressBar');
				if (typeof progBar !== 'undefined') {
					var width = current / total * 100 + '%';
					progBar.style.width = width;
				}
			});
			
			// All good
			file.event('done', function (xhr) {
				var progBarDiv	= document.getElementById('progBarDiv');
				var progBar		= document.getElementById('progressBar');
				if (typeof progBar !== 'undefined' && typeof progBarDiv !== 'undefined') {
					progBar.style.width = 0;
					progBarDiv.style.display = 'none';
				};
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
