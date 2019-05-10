#!/bin/sh

set -e 
duffle_version="/0.1.0-ralpha.5%2Benglishrose"
cnab_quickstart_registry="sdacr.azurecr.io"
repository="duffle"

echo "Download Duffle"

mkdir "${agent_temp_directory}/duffle"
curl https://github.com/deislabs/duffle/releases/download/${duffle_version}/duffle-linux-amd64 -L -o  ${agent_temp_directory}/duffle/duffle
chmod +x "${agent_temp_directory}/duffle/duffle"

# Update the path

echo "##vso[task.setvariable variable=PATH]${agent_temp_directory}/duffle:${PATH}"

echo "Get the files in the PR to find the solution folder name"

# Each bundle definition should exist with a directory under the duffle directory - the folder name is derived from the set of files that have been changed in this pull request

if [ "$(find "${repo_local_path}/duffle" -maxdepth 1 ! -type d)" ]; then 
    printf "Files should not be placed in the duffle directory - only duffle solution folders in this folder"
    exit 1 
fi

folder=$(curl "https://api.github.com/repos/${repo_name}/pulls/${pr_number}/files"|jq '[.[].filename| select(startswith("duffle"))][0]|split("/")[1]' --raw-output) 
echo "##vso[task.setvariable variable=taskdir]${repo_local_path}/duffle/${folder}"

cd "${repo_local_path}/duffle/${folder}"

cnab_name=$(jq '.name' ./duffle.json --raw-output) 

if [ "${cnab_name}" != "${folder}" ]; then 
    printf "Name property should in duffle.json should be the same as the solution directory name. Name property:%s Directory Name: %s" "${cnab_name}" "${folder}"
    exit 1 
fi

# Find the Docker Builder 

ii_name=$(jq '.invocationImages|.[]|select(.builder=="docker").name' ./duffle.json --raw-output) 

# Check the registry name

echo "registry: ${registry}"

registry=$(jq ".invocationImages.${ii_name}.configuration.registry" ./duffle.json --raw-output) 

if [ "${registry}" != "${cnab_quickstart_registry}/${repository}" ]; then 
    printf "Registry property of invocation image configuration should be set to %s in duffle.json" "${cnab_quickstart_registry}/${repository}"
    exit 1 
fi

image_repo="${registry}/${cnab_name}-${ii_name}" 
echo "Image Repo: ${image_repo}"
echo "##vso[task.setvariable variable=image_repo]${image_repo}"