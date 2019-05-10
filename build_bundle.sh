#!/bin/bash

set -e 

echo "Building Bundle in Solution Directory: $(pwd)"

duffle init
duffle build

ii_tag="$(docker image ls ${image_registry}/${image_repo} --format='{{lower .Tag}}')"
echo "Invocation Image Tag: ${ii_tag}"
echo "##vso[task.setvariable variable=ii_tag]${ii_tag}"
