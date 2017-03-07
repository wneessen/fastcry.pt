// FileDrop init
var options = {input: false,};
var zone = new FileDrop('entryBox', options);

zone.event('send', function (files) {
	var xhr = new XMLHttpRequest();
	files.each(function (file) {
		file.event('done', function (xhr) {
			zone.el.value = xhr.responseText;
		});
		file.event('xhrSetup', function (xhr) {
			var encPass = document.getElementById('entryPass').value;
			if (typeof encPass !== 'undefined' && encPass !== '') {
				xhr.setRequestHeader('X-Encryption-Pass', encPass);
			}
		});
		file.sendTo('/api/v1/upload');
	});
});
