## Filename:		Index.pm
## Description:		Main index controller for Fastcrypt
## Creator:			Winfried Neessen <wn@neessen.net>

package FastCrypt::Controller::Index;
use Mojo::Base 'Mojolicious::Controller';

## Start page - show encryption form // showForm() {{{
sub showForm {
	my $self = shift;
	my $defaultWrapper = 'wrapper/indexShowForm';

	## Set the authorization cookie for the API access
	$self->session(apiAccess => 1);

	return $self->render(status => 200, template => $defaultWrapper);
}
# }}}

## Present decryption form // showDecrypt() {{{
sub showDecrypt {
	my $self = shift;
	my $defaultWrapper = 'wrapper/indexShowDecrypt';
	my $uuid = $self->stash('uuid');

	## First make sure the entry exists
	if (!$self->entryExists($uuid)) {
		return $self->render(status => 404, text => 'Entry not found');
	}

	## Set the authorization cookie for the API access
	$self->session(apiAccess => 1);

	return $self->render(status => 200, template => $defaultWrapper);
}
# }}}

## About page // showAbout() {{{
sub showAbout {
	my $self = shift;
	my $defaultWrapper = 'wrapper/indexShowAbout';

	## Set the authorization cookie for the API access
	$self->session(apiAccess => 1);

	return $self->render(status => 200, template => $defaultWrapper);
}
# }}}

## Imprint page // showImprint() {{{
sub showImprint {
	my $self = shift;
	my $defaultWrapper = 'wrapper/indexShowImprint';

	## Set the authorization cookie for the API access
	$self->session(apiAccess => 1);

	return $self->render(status => 200, template => $defaultWrapper);
}
# }}}

1;
# vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
