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
use Mojo::Util qw(url_escape);
use Mojo::JSON qw(decode_json);
our $VERSION = '1.0.0';

## Read options
my %opts;
GetOptions(
	'file|f=s'	=> \$opts{'file'},
);

## Check the file presence
croak('File not present.') if (!-e $opts{'file'} || !-f $opts{'file'});

## We need a Mojo UA
my $userAgent	= Mojo::UserAgent->new;
my $apiUrl		= 'https://fastcry.pt';

## Upload the file
$userAgent->get($apiUrl => { 'User-Agent' => 'fastcrypt.pl v' . $VERSION });
my $uploadTx = $userAgent->post($apiUrl . '/api/v1/upload' => { 'User-Agent' => 'fastcrypt.pl v' . $VERSION } => Mojo::Asset::File->new(path => $opts{'file'})->slurp);
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
	print 'Decryption URL/PW:' . "\t" . $resultObj->{absurl} . '?fastcrypt_pass=' . url_escape($resultObj->{password}) . "\n";
	exit 0;
}
else {
	croak('Unexpected error');
}

exit 1
