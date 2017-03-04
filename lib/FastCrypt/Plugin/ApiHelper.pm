## Filename:	ApiHelper.pm
## Description:	Set of API helper method for FastCrypt
## Creator:		Winni Neessen <wn@neessen.net>

package FastCrypt::Plugin::ApiHelper;
use Mojo::Base 'Mojolicious::Plugin';
use Carp;
use Data::Dumper;
use File::Path qw/make_path/;
our $VERSION = '0.01';

## Register the plugin // register {{{
sub register {
	my ($self, $app, $conf) = @_;
	
	## Initialize the helper
	$app->helper(jsonError	=> \&_jsonError);
	$app->helper(createDir	=> \&_createDir);
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
#}

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
#}

1;
