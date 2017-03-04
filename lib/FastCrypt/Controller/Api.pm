## Filename:		Api.pm
## Description:		Main API controller for Fastcrypt
## Creator:			Winfried Neessen <wn@neessen.net>

package FastCrypt::Controller::Api;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::JSON qw/decode_json/;
use Mojo::Upload;
use UUID qw/uuid/;
use Data::Dumper;

## Check if client is allowed to access API // checkApiAccess() {{{
##		This is a very basic access check just to avoid bot 
##		to access the API automagically
sub checkApiAccess {
	my $self = shift;
	#my $accessCheck = $self->session->{apiAccess} || 0;
	my $accessCheck = $self->session->{apiAccess} || 1;

	if(!defined($accessCheck) or $accessCheck != 1) {
		$self->jsonError('Access to API not granted', 403);
		return undef;
	}

	return 1;
}
# }}}

## A simple test response // testResponse() {{{
sub testResponse {
	my $self = shift;
	return $self->render(
		status	=> 200,
		json	=> {
			status		=> 'ok',
			statuscode	=> 200,
			test		=> 'Test succeeded',
		},
	);
}
# }}}

## Store the data // storeEntry() {{{
sub storeEntry {
	my $self		= shift;
	my $entryData	= $self->param('fastcrypt_entry');
	my $encPass		= $self->param('fastcrypt_pass');
	my $noPass		= $self->param('fastcrypt_nopass');

	## We need at least a little bit of data
	if (!defined($entryData)) {
		$self->jsonError('No data submitted', 400);
		return undef;
	}
	
	## We support a maximum length
	if (length($entryData) > $self->config->{maxLength}) {
		$self->jsonError('Requested data exceeds upload limit', 400);
		return undef;
	}
	
	## Generate a password (if none is given)
	if (!defined($encPass) && !defined($noPass)) {
		$encPass = $self->genPass;
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
		$self->log->app->error('Datafile "' . $filePath . '/data' . '" is already present. Aborting.');
		$self->jsonError('An unexpected error occored.', 500);
		return undef;
	}

	## Let open the file first
	open(ENCFILE, '>', $filePath . '/data') or do {
		$self->app->log->error('Unable to open file for writing: ' . $1);
		$self->jsonError('An unexpected error occured.', 500);
	};

	## Encrypt the data and store it
	my $encData = $self->encData($entryData, $encPass);
	syswrite(ENCFILE, $encData);
	$self->app->log->debug($encPass);


	close(ENCFILE);

	#$self->app->log->debug($self->encData($entryData, $encPass), $encPass);
	
	return $self->render(
		status	=> 200,
		json	=> {
			status		=> 'ok',
			statuscode	=> 200,
		},
	);

}
# }}}

1;
# vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
