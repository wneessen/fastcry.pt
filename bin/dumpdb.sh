#!/usr/bin/env sh

dbicdump -o dump_directory=../lib -o components='["InflateColumn::DateTime"]' FastCrypt::Schema dbi:mysql:dbname=fastcrypt fastcrypt 
