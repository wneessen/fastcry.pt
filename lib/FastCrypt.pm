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
    $self->plugin('FastCrypt::Plugin::CryptoHelper');
    $self->plugin('FastCrypt::Plugin::TemplateHelper');

    ## Router
    my $r = $self->routes;

	## API routes
	my $api = $r->under('/api/v1')->to('api#checkApiAccess');
	$api->get('/ping')->to('#ping');
	$api->post('/store')->to('#storeEntry')->name('apiStoreEntry');
	$api->post('/decrypt')->to('#decryptEntry')->name('apiDecrytEntry');

    ## Web interface routes
    $r->get('/')->to('index#showForm')->name('defaultForm');
    $r->get('/about')->to('index#showAbout')->name('aboutPage');
    $r->get('/donate')->to('index#showDonate')->name('donatePage');
    $r->get('/d/:uuid' => [uuid => qr/[A-Za-z0-9]+\-[A-Za-z0-9]+\-[A-Za-z0-9]+\-[A-Za-z0-9]+\-[A-Za-z0-9]+/])->to('index#showDecrypt')->name('decryptForm');
}
# }}}

1;
# vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
