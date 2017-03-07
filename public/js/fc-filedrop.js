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
				var responseObj = JSON.parse(xhr.responseText);
				if (responseObj.statuscode === 406) {
					swal({
						title:	'Oops!',
						text:	'Sorry, but we do not support the type of file you dropped.',
						type:	'error',
						confirmButtonText: 'That\s ok. I\'ll choose a different file.',
					});
				}
				return false;
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
