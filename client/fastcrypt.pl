#!/usr/bin/env perl

## Filename:	fastcrypt.pl
## Description:	fastcry.pt CLI client
## Creator:		Winni Neessen <wn@neessen.net>

## Load required modules
use strict;
use warnings;
use Carp;
use Getopt::Long;
use Mojo::UserAgent;
use Mojo::JSON qw(decode_json);
our $VERSION = '1.0.0';

## Read options
my %opts;
GetOptions(
	'file|f=s'	=> \$opts{'file'},
);

## We need a Mojo UA
my $userAgent	= Mojo::UserAgent->new;
my $apiUrl		= 'https://fastcry.pt';
my $cookieJar;

## Fetch a cookie
my $cookieTx = $userAgent->get($apiUrl => { 'User-Agent' => 'fastcrypt.pl v' . $VERSION });
if (!defined($cookieTx)) {
	croak('Unable to create a transaction');
}
if (my $err = $cookieTx->error) {
	croak('Request to server failed: ' . $err->{message});
}
elsif (my $success = $cookieTx->success) {
	$cookieJar = $success->cookie('fastcrypt_sess')->value;
}
else {
	croak('Unexpected error');
}

## Upload the file
my $uploadTx = $userAgent->post($apiUrl . '/api/v1/upload' => { 'User-Agent' => 'fastcrypt.pl v' . $VERSION } => form => {file => {file => $opts{'file'}}});
$uploadTx->req->cookies({name => 'fastcrypt_sess', value => $cookieJar});
if (!defined($uploadTx)) {
	croak('Unable to create a transaction');
}
if (my $err = $uploadTx->error) {
	croak('Request to server failed: ' . $err->{message});
}
elsif (my $success = $uploadTx->success) {
	my $resultObj = decode_json($success->body);
	print 'Decryption URL:' . "\t\t" . $resultObj->{absurl} . "\n";
	print 'Decryption Password:' . "\t" . $resultObj->{password} . "\n";
	exit 0;
}
else {
	croak('Unexpected error');
}

exit 1
