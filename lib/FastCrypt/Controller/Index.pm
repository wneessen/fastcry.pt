## Filename:		Index.pm
## Description:		Main index controller for Fastcrypt
## Creator:			Winfried Neessen <wn@neessen.net>

package FastCrypt::Controller::Index;
use Mojo::Base 'Mojolicious::Controller';

## Default index page // showForm() {{{
sub showForm {
	my $self = shift;
	my $defaultWrapper = 'wrapper/indexShowForm';

	## Set the authorization cookie for the API access
	$self->session(apiAccess => 1);

	return $self->render(status => 200, template => $defaultWrapper);
}
# }}}

1;
# vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
