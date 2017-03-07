## Filename:	ApiHelper.pm
## Description:	Set of API helper method for FastCrypt
## Creator:		Winni Neessen <wn@neessen.net>

package FastCrypt::Plugin::ApiHelper;
use Mojo::Base 'Mojolicious::Plugin';
use Carp;
use Data::Dumper;
use File::Path qw/make_path/;
use UUID qw/uuid/;
our $VERSION = '0.01';

## Register the plugin // register {{{
sub register {
	my ($self, $app, $conf) = @_;
	
	## Initialize the helper
	$app->helper(jsonError		=> \&_jsonError);
	$app->helper(getStoreFiles	=> \&_getStoreFiles);
	$app->helper(createDir		=> \&_createDir);
	$app->helper(entryExists	=> \&_entryExists);
	$app->helper(validatePass	=> \&_validatePass);
}
# }}}

## Generate an exception JSON response // _jsonError() {{{
##		Requires:	errormsg, statuscode
##		Returns:	statuscode
sub _jsonError {
	my $self		= shift;
	my $errorMsg	= shift;
	my $statusCode	= shift;
	my %httpCodes	= (
		200		=> 'ok',
		400		=> 'bad request',
		401		=> 'unauthorized',
		403		=> 'forbidden',
		500		=> 'internal server error',
	);
	
	if (!defined($errorMsg) or !defined($statusCode)) {
		croak('Missing parameter for jsonException()');
	}

	$self->render(
		status	=> $statusCode,
		json	=> {
			status		=> $httpCodes{$statusCode},
			statuscode	=> $statusCode,
			errormsg	=> $errorMsg,
		},
	);

	return $statusCode;
}
# }}}

## Generate filehandles for storing the encrypted data // _getStoreFiles() {{{
##		Requires:	nothing
##		Returns:	encFileHandle, metaFileHandle, typeFileHandl
sub _getStoreFiles {
	my $self = shift;
	my $uuid = lc uuid;

	my $filePath = $self->createDir($uuid);
	return undef if !defined($filePath);

	## Make sure no datafile is present
	if (-e $filePath . '/data') {
		$self->app->log->error('Datafile "' . $filePath . '/data' . '" is already present. Aborting.');
		return undef;
	}
	
	## Open the files
	open (my $encFile, '>', $filePath . '/data') or do {
		$self->app->log->error('Unable to open file for writing: ' . $!);
		return undef;
	};
	open (my $metaFile, '>', $filePath . '/meta') or do {
		$self->app->log->error('Unable to open meta file for writing: ' . $!);
		return undef;
	};
	open (my $typeFile, '>', $filePath . '/type') or do {
		$self->app->log->error('Unable to open type file for writing: ' . $!);
		return undef;
	};

	return ($encFile, $metaFile, $typeFile, $uuid);
}
# }}}

## Create an directory for the uploaded data // _createDir() {{{
##		Requires:	uuid
##		Returns:	filepath
sub _createDir {
	my $self	= shift;
	my $uuid	= shift;
	my $root	= $ENV{'PWD'} . '/' . $self->config->{filePath};
	return undef if (!defined($uuid));
	if (!-d $root) {
		$self->app->log->error('Root file path "' . $root . '" not existant. Not allowing uploads.');
		return undef;
	}

	## Path creation
	my @splitUuid = split(/-/, $uuid, 5);
	my $fullPath = $root . '/' . join('/', @splitUuid);
	if (-d $fullPath) {
		$self->app->log->error($fullPath . ' is already present. This should not happen. Aborting.');
		return undef;
	}
	make_path($fullPath, {error => \my $createErr});
	if (@$createErr) {
		for my $entry (@$createErr) {
			my ($fileName, $errorMsg) = %$entry;
			if ($fileName eq '') {
				$self->app->log->error('General make_path error: ' . $errorMsg);
			}
			else {
				$self->app->log->error('Error running make_path for "' . $fileName . '": ' . $errorMsg);
			}
		}
		return undef;
	}

	## Validate the path is present
	if (-d $fullPath) {
		return $fullPath;
	}
	else {
		$self->app->log->error('Path creation did not throw an exception, but path is not present. Aborting.');
		return undef;
	}

	## We should never reach this point
	return undef;
}
# }}}

## Check if an entry exists in the filesystem // _entryExists() {{{
##		Requires:	uuid
##		Returns:	fullPath or undef
sub _entryExists {
	my $self = shift;
	my $uuid = shift;
	my $root = $ENV{'PWD'} . '/' . $self->config->{filePath};
	
	if (!defined($uuid)) {
		croak('Missing parameter for entryExists()');
	}

	my @splitUuid = split(/-/, $uuid, 5);
	my $fullPath = $root . '/' . join('/', @splitUuid);
	return undef if (!-d $fullPath);
	return undef if (!-e $fullPath . '/data');
	return undef if (!-f $fullPath . '/data');
	return undef if (!-e $fullPath . '/meta');
	return undef if (!-f $fullPath . '/meta');
	return $fullPath;
}
# }}}

## Check if the provided password will decrypt correctly // _validatePass() {{{
##		Requires:	uuid, password
##		Returns:	1 or undef
sub _validatePass {
	my $self = shift;
	my $uuid = shift;
	my $pass = shift;
	my $root = $ENV{'PWD'} . '/' . $self->config->{filePath};
	my ($data);
	
	if (!defined($uuid) || !defined($pass)) {
		croak('Missing parameter for entryExists()');
	}

	my @splitUuid = split(/-/, $uuid, 5);
	my $fullPath = $root . '/' . join('/', @splitUuid);
	open(METAFILE, $fullPath . '/meta') or do {
		$self->app->log->error('Unable to read meta file: ' . $!);
		return undef;
	};
	while(my $lenght = sysread(METAFILE, my $buffer, 1024)) {
		$data .= $buffer;
	}
	close(METAFILE);

	## Decrypt the data and validate
	my $decData = $self->decData($data, $pass);
	if ($decData ne $pass) {
		return undef;
	}
	else { 
		return 1;
	}

	## This point should never be reached
	return undef;
}
# }}}

1;
