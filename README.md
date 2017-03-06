# fastcry.pt - A quick and easy encrypted note system

## Easyily share a note - quick, secure, anonymous

### Requirements
You will need Perl5 and Mojolicious as minimal requirements to run this. Also a "secrets" file needs to be created (which currently only stores the session secret).


```
touch conf/FastCryptSecret.conf
echo "{ sessionSecret => 'YOUR SECRET HERE', }" >conf/FastCryptSecret.conf
```

A "files" directory is also a requirement
```
mkdir files
```
