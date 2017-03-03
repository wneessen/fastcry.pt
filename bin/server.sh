#!/usr/bin/env sh

cd ..
env DBIC_TRACE=1 morbo -l http://0.0.0.0:5313 script/fast_crypt -v -w lib -w conf -w templates
