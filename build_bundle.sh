#!/bin/sh

set -e 

echo "Building Bundle in Solution Directory: $(pwd)"

duffle init
duffle build