#!/usr/bin/env bash

FOUNDATION_PATH=../../secushare_foundation
DEFAULT_PARAMS='--trace --time --poll --sass-dir ../fastcry.pt/scss --css-dir ../fastcry.pt/public/css --javascripts-dir ../fastcry.pt/public/js --force'
MODE=${1:-dev}
if [ "x$MODE" = "xdev" ]; then
    PARAMS='-s compressed'
elif [ "x$MODE" = "xprod" ]; then
    PARAMS='-s compressed'
else
    PARAMS='-s expanded'
fi
echo Starting Compass with: $DEFAULT_PARAMS $PARAMS
cd $FOUNDATION_PATH
bundle exec compass watch $DEFAULT_PARAMS $PARAMS
