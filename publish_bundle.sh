#!/bin/sh

set -e 

tempfile="$(mktemp)"
jq '.invocationImages.cnab.configuration.registry="azure_cnab_quickstarts"' ./duffle.json > "${tempfile}"
mv "${tempfile}" > ./duffle.json
duffle init
duffle build