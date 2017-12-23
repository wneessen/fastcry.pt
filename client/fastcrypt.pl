#!/usr/bin/env perl

## Filename:	fastcrypt.pl
## Description:	fastcry.pt CLI client
## Creator:		Winni Neessen <wn@neessen.net>

## Read opts at first
my %opts;
BEGIN {
	use Getopt::Long;
	GetOptions(
		'file|f=s'	=> \$opts{file},
		'help|h'	=> \$opts{help},
		'debug|d'	=> \$opts{debug},
	);
	$ENV{MOJO_USERAGENT_DEBUG} = 1 if (defined($opts{debug}));
}

## Load required modules
use strict;
use warnings;
use Carp;
use Mojo::UserAgent;
use Mojo::Util qw(url_escape);
use Mojo::JSON qw(decode_json);

## Some vars
our $VERSION	= '1.0.2';
my $xua			= 'fastcrypt.pl v' . $VERSION;
my $apiUrl		= 'https://fastcry.pt';

## Need some help?
showHelp() if (defined($opts{help}));
showHelp() if (!defined($opts{file}));

## Check the file presence
croak('File not present.') if (!-e $opts{file} || !-f $opts{file});

## Upload the file
my $userAgent	= Mojo::UserAgent->new;
$userAgent->get($apiUrl => { 'User-Agent' => $xua });
my $uploadTx = $userAgent->post(
	$apiUrl . '/api/v1/upload' => {'User-Agent' => $xua} => Mojo::Asset::File->new(path => $opts{file})->slurp
);
if (!defined($uploadTx)) {
	croak('Unable to create a transaction');
}
if (my $err = $uploadTx->error) {
	croak('Server request failed: ' . $err->{message});
}
elsif (my $success = $uploadTx->success) {
	my $resultObj = decode_json($success->body);
	print 'Decryption URL:' . "\t\t" . $resultObj->{absurl} . "\n";
	print 'Decryption Password:' . "\t" . $resultObj->{password} . "\n";
	print 'Decryption URL/PW:' . "\t" . $resultObj->{absurl} . '?fastcrypt_pass=' . url_escape($resultObj->{password}) . "\n";
	exit 0;
}
else {
	croak('An unexpected error occured. We are sorry.');
}

sub showHelp {
	print "Usage: $0 [OPTIONS]\n";
	print "\n\t-f, --file\t\tPath to file to upload";
	print "\n\t-h, --help\t\tDisplay this help message.\n";
	print "\n";
	exit 1;
}
