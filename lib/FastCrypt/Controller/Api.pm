## Filename:		Api.pm
## Description:		Main API controller for Fastcrypt
## Creator:			Winfried Neessen <wn@neessen.net>

package FastCrypt::Controller::Api;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;
use Mojo::Util qw(xml_escape);
use UUID qw/uuid/;
use Data::Dumper;

## Check if client is allowed to access API // checkApiAccess() {{{
##		This is a very basic access check just to avoid bot 
##		to access the API automagically
sub checkApiAccess {
	my $self = shift;
	my $accessCheck = $self->session->{apiAccess} || 0;

	if(!defined($accessCheck) or $accessCheck != 1) {
		$self->jsonError('Access to API not granted', 403);
		return undef;
	}

	return 1;
}
# }}}

## A simple ping/pong method // ping() {{{
sub ping {
	my $self = shift;
	return $self->render(
		status	=> 200,
		json	=> {
			status		=> 'ok',
			statuscode	=> 200,
			ping		=> 'ping',
		},
	);
}
# }}}

## Store the data // storeEntry() {{{
sub storeEntry {
	my $self		= shift;
	my $validateObj	= $self->validation;
	my $entryData	= $self->param('fastcrypt_entry');
	my $encPass		= $self->param('fastcrypt_pass') || undef;
	my $csrfToken	= $self->param('csrf_token');
	my ($selfProvided);

	## We need at least a little bit of data
	if (!defined($entryData)) {
		$self->jsonError('No data submitted', 400);
		return undef;
	}
	
	## We support a maximum length
	if (length($entryData) > $self->config->{maxLength}) {
		$self->app->log->error('Request exceeds upload limit.');
		$self->jsonError('Requested data exceeds upload limit', 400);
		return undef;
	}

	## Check for CSFR Token
	if ($validateObj->csrf_protect->has_error($csrfToken)) {
		$self->app->log->error('Bad CSFR token');
		$self->jsonError('Bad CSFR token', 403);
		return undef;
	}
	
	## Generate a password (if none is given)
	if (!defined($encPass)) {
		$encPass = $self->genPass;
		undef $selfProvided;
	}
	else {
		$selfProvided = 1;
	}

	## Let's create a directory for the upload
	my $uuid = lc uuid;
	my $filePath = $self->createDir($uuid);
	if (!defined($filePath)) {
		$self->jsonError('An unexpected error occored.', 500);
		return undef;
	}

	## Make sure no datafile is present
	if (-e $filePath . '/data') {
		$self->app->log->error('Datafile "' . $filePath . '/data' . '" is already present. Aborting.');
		$self->jsonError('An unexpected error occored.', 500);
		return undef;
	}

	## Let open the files first
	open (ENCFILE, '>', $filePath . '/data') or do {
		$self->app->log->error('Unable to open file for writing: ' . $1);
		$self->jsonError('An unexpected error occured.', 500);
		return undef;
	};
	open (METAFILE, '>', $filePath . '/meta') or do {
		$self->app->log->error('Unable to open meta file for writing: ' . $1);
		$self->jsonError('An unexpected error occured.', 500);
		return undef;
	};

	## Encrypt the data and store it
	my $encPassData = $self->encData($encPass, $encPass);
	my $encData = $self->encData($entryData, $encPass);
	if (!defined($encPassData)) {
		$self->app->log->error('Encryption of meta data returned no data');
		$self->jsonError('An unexpected error occured.', 500);
		return undef;
	}
	if (!defined($encData)) {
		$self->app->log->error('Encryption returned no data');
		$self->jsonError('An unexpected error occured.', 500);
		return undef;
	}
	syswrite(METAFILE, $encPassData);
	syswrite(ENCFILE, $encData);
	close(METAFILE);
	close(ENCFILE);

	## Free some memory
	undef $encData;
	undef $entryData;

	## We are good so far
	if (defined($selfProvided) && $selfProvided == 1) { $encPass = '** SELFPROVIDED **' }
	return $self->render(
		status	=> 200,
		json	=> {
			status		=> 'ok',
			statuscode	=> 200,
			url			=> $self->url_for('decryptForm', uuid => $uuid),
			absurl		=> $self->url_for('decryptForm', uuid => $uuid)->to_abs,
			password	=> $encPass,
		},
	);
}
# }}}

## Decrypt the data // decryptEntry() {{{
sub decryptEntry {
	my $self		= shift;
	my $validateObj	= $self->validation;
	my $decPass		= $self->param('fastcrypt_pass') || undef;
	my $uuid		= $self->param('fastcrypt_id') || undef;
	my $csrfToken	= $self->param('csrf_token');

	## We need at least a little bit of data
	if (!defined($decPass)) {
		$self->jsonError('No password submitted', 400);
		return undef;
	}
	
	## The UUID is mandatory
	if (!defined($uuid)) {
		$self->jsonError('Fastcrypt ID not given', 400);
		return undef;
	}

	## Check for CSFR Token
	if ($validateObj->csrf_protect->has_error($csrfToken)) {
		$self->app->log->error('Bad CSFR token');
		$self->jsonError('Bad CSFR token', 403);
		return undef;
	}

	## Validate the password
	if (!$self->validatePass($uuid, $decPass)) {
		$self->jsonError('Decryption failed', 500);
		return undef;
	}

	## Decrypt the data
	my $data;
	my $filePath = $self->entryExists($uuid);
	open (ENCFILE, $filePath . '/data') or do {
		$self->app->log->error('Unable to open file for writing: ' . $1);
		$self->jsonError('An unexpected error occured.', 500);
		return undef;
	};
	while(my $lenght = sysread(ENCFILE, my $buffer, 1024)) {
		$data .= $buffer;
	}
	close(ENCFILE);
	my $decData = $self->decData($data, $decPass);
	if (!defined($decData)) {
		$self->app->log->error('Decryption returned no data');
		$self->jsonError('An unexpected error occured.', 500);
		return undef;
	}

	## Return the decrypted data
	return $self->render(
		status	=> 200,
		json	=> {
			status		=> 'ok',
			statuscode	=> 200,
			data		=> xml_escape($decData),
		},
	);
}
# }}}
	

1;
# vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
