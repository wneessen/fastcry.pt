## Filename:	TemplateHelper.pm
## Description:	Set of template helper utilities for FastCrypt
## Creator:		Winni Neessen <wn@neessen.net>

package FastCrypt::Plugin::TemplateHelper;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(xml_escape html_unescape);
our $VERSION = '0.01';

## Register the plugin // register {{{
sub register {
	my ($self, $app, $conf) = @_;

	## Initialize the helper
	$app->helper(devHtmlComment   => \&_devHtmlComment);
}
# }}}

## Add HTML if in development mode // _devHtmlComment() {{{
sub _devHtmlComment {
	my ($self, $comment) = @_;
	if (lc($self->app->mode) eq 'development') {
		my $comment = xml_escape($comment);
		return '<!-- ' . $comment . ' //-->';
	}
}
# }}}

1;
