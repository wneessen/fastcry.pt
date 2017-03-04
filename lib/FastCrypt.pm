## Filename:    FastCrypt.pm
## Description: A quick, easy and secure file/note sharing tool
## Creator:     Winni Neessen <wn@neessen.net>

package FastCrypt;
use Mojo::Base 'Mojolicious';
use Data::Dumper;
use Carp;

## Main server startup method // startup() {{{
sub startup {
    my $self = shift;

    ## Load config files
    my $config = $self->plugin('Config', {file => 'conf/FastCrypt.conf'});
    my $secret = $self->plugin('Config', {file => 'conf/FastCryptSecret.conf'});

    ## Session settings
    $self->secrets([$secret->{sessionSecret}]);
    $self->sessions->secure($config->{sessionSecureFlag});
    $self->sessions->default_expiration($config->{sessionExpiration});
    $self->sessions->cookie_name($config->{productNameShort} . '_sess');

    ## Load some AppHelper plugins
    $self->plugin('FastCrypt::Plugin::ApiHelper');
    $self->plugin('FastCrypt::Plugin::TemplateHelper');

    ## Router
    my $r = $self->routes;

	## API routes
	my $api = $r->under('/api/v1')->to('api#checkApiAccess');
	$api->get('/test')->to('#testResponse');
	$api->post('/store')->to('#storeEntry')->name('apiStoreEntry');

    ## Web interface routes
    $r->get('/')->to('index#showForm')->name('defaultForm');
}
# }}}

1;
# vim: set ts=4 sw=4 sts=4 noet ft=perl norl:
