#! /bin/bash

set -ue

cd sample/
yarn
yarn run build
rm -rf ../docs/
mv dist ../docs
