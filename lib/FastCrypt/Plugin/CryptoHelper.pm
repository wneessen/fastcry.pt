## Filename:	CryptoHelper.pm
## Description:	Set of cryptographic helper utilities for FastCrypt
## Creator:		Winni Neessen <wn@neessen.net>

package FastCrypt::Plugin::CryptoHelper;
use Mojo::Base 'Mojolicious::Plugin';
use Carp;
use Data::Dumper;
use Bytes::Random::Secure;
use Crypt::CBC;
use Digest::SHA;
use MIME::Base64;
our $VERSION = '0.01';

## Define some constant defaults
use constant DEFAULT_SALT_LENGTH	=> 32;
use constant DEFAULT_SALT_RETURN	=> 'hex';
use constant DEFAULT_PASS_LENGTH	=> 15;
use constant DEFAULT_RAND_BITS		=> 4096;
use constant DEFAULT_HASH_BITS		=> 256;

## Password defaults
use constant PW_LOWER_CHARS			=> qq(abcdefghjkmnpqrstuvwxyz);
use constant PW_UPPER_CHARS			=> qq(ABCDEFGHJKMNPQRSTUVWXYZ);
use constant PW_SPECIAL_CHARS		=> qq(#/!\$%&+-*);
use constant PW_NUMBERS				=> qq(23456789);
use constant PW_DEFAULT_USEUPPER	=> 1;
use constant PW_DEFAULT_USENUMBER	=> 1;
use constant PW_DEFAULT_USESPECIAL	=> 1;

## Register the plugin // register {{{
sub register {
	my ($self, $app, $conf) = @_;
	
	## Initialize the helper
	$app->helper(genPass	=> \&_genPass);
	$app->helper(genRandObj	=> \&_genRandObj);
	$app->helper(encData	=> \&_encData);
	$app->helper(decData	=> \&_decData);
	$app->helper(shaHash	=> \&_shaHash)
}
# }}}

## Generate a secure password // _genPass() {{{
##		Requires:	nothing
##		Optional:	password length, no special characters
##		Returns:	password string
sub _genPass {
	my $self			= shift;
	my $passLength		= shift;
	my $noSpecialChar	= shift;

	if (!defined($passLength)) {
		$passLength = $self->config->{pwLength} || DEFAULT_PASS_LENGTH;
	}

	## Override defaults with config settings
	my $useUpper	= defined($self->config->{pwUseUpper})		? $self->config->{pwUseUpper}	: PW_DEFAULT_USEUPPER;
	my $useNumber	= defined($self->config->{pwUseNumber})		? $self->config->{pwUseNumber}	: PW_DEFAULT_USENUMBER;
	my $useSpecial	= defined($self->config->{pwUseSpecial})	? $self->config->{pwUseSpecial}	: PW_DEFAULT_USESPECIAL;
	
	## If explicitly disabled, don't add special characters
	if (defined($noSpecialChar)) { $useSpecial = 2 }

	## Generate the secure password
	my $csPrng = $self->genRandObj;
	my $charRange	 = PW_LOWER_CHARS;
	$charRange		.= (defined($useUpper)		&& $useUpper == 1)		? PW_UPPER_CHARS	: '';
	$charRange		.= (defined($useNumber)		&& $useNumber == 1)		? PW_NUMBERS		: '';
	$charRange		.= (defined($useSpecial)	&& $useSpecial == 1)	? PW_SPECIAL_CHARS	: '';

	return $csPrng->string_from($charRange, $passLength);
}
# }}}

## Generate a random bytes object // _genRandObj() {{{
##		Requires:	nothing
##		Returns:	random bytes object
sub _genRandObj {
	my $self = shift;
	my $rand = Bytes::Random::Secure->new(
		Bits		=> DEFAULT_RAND_BITS,
		NonBlocking	=> 1,
	);
	if (!defined($rand)) {
		$self->app->log->error('Unable to create random bytes object. Aborting. ' . $!);
		croak('Unable to create cryptographically safe random object. Safe encryption not give. Aborting.');
	}

	return $rand;
}
# }}}

## Encrypt given data // _encData() {{{
##		Requires:	data, password
##		Returns:	encrypted data
sub _encData {
	my $self		= shift;
	my $plainText	= shift;
	my $passWord	= shift;

	## Hash the password
	my $passHash = $self->shaHash($passWord, 256);

	## Encrypt the data
	my $cryptObj = Crypt::CBC->new(-key => $passHash, -cipher => 'Rijndael', -salt => 1);
	my $cipherText = $cryptObj->encrypt($plainText);
	undef $plainText;
	undef $passWord;
	undef $passHash;

	return $cipherText;
}
# }}}

## Decrypt given data // _decData() {{{
##		Requires:	data, password
##		Returns:	decrypted data
sub _decData {
	my $self		= shift;
	my $cipherText	= shift;
	my $passWord	= shift;

	## Hash the password
	my $passHash = $self->shaHash($passWord, 256);

	## Encrypt the data
	my $cryptObj = Crypt::CBC->new(-key => $passHash, -cipher => 'Rijndael', -salt => 1);
	my $plainText = $cryptObj->decrypt($cipherText);
	undef $cipherText;
	undef $passWord;
	undef $passHash;

	return $plainText;
}
# }}}

## Hash given data with SHA digest // _shaHash() {{{
##		Requires:	data
##		Optional:	bitsize
##		Returns:	hashdigest
sub _shaHash {
	my $self		= shift;
	my $plainText	= shift;
	my $bitSize		= shift || DEFAULT_HASH_BITS;

	my $digestObj	= Digest::SHA->new($bitSize);
	$digestObj->add($plainText);
	return $digestObj->digest;
}
# }}}

1;
# vim: set ts=4 sw=4 sts=4 noet ft=perl foldmethod=marker norl:
