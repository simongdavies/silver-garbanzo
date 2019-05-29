#!/bin/bash

set -e 
duffle_version="/0.1.0-ralpha.5%2Benglishrose"
repository_path="duffle"
cnab_quickstart_registry="cnabquickstartstest.azurecr.io"

# Update could be in either the duffle or the porter directory or it could be an update that is not related to a solution, this should only happen on a merge as builds are only trigged for PR when changes are made in the dufffle or porter folder

echo "Get the files in the PR or merge commit to find the solution folder name"

if [ "${reason}" == "IndividualCI" ]; then
    owner_and_repo="${repo_uri##https://github.com/}"
    commit_uri=https://api.github.com/repos/${owner_and_repo}/commits/${source_version}
    echo "Merge Commit uri: ${commit_uri}"
    files=$(curl "${commit_uri}"|jq '[.files[].filename]') 
fi

echo "Download Duffle"

mkdir "${agent_temp_directory}/duffle"
curl https://github.com/deislabs/duffle/releases/download/${duffle_version}/duffle-linux-amd64 -L -o  ${agent_temp_directory}/duffle/duffle
chmod +x "${agent_temp_directory}/duffle/duffle"

# Update the path

echo "##vso[task.setvariable variable=PATH]${agent_temp_directory}/duffle:${PATH}"

# Each bundle definition should exist with a directory under the duffle directory - the folder name is derived from the set of files that have been changed in this pull request

if [ "$(find "${repo_local_path}/duffle" -maxdepth 1 ! -type d)" ]; then 
    printf "Files should not be placed in the duffle directory - only duffle solution folders in this folder"
    exit 1 
fi

echo "Get the files in the PR or merge commit to find the solution folder name"

if [ ${reason} == "IndividualCI" ]; then
    owner_and_repo="${repo_uri##https://github.com/}"
    commit_uri=https://api.github.com/repos/${owner_and_repo}/commits/${source_version}
    echo "Merge Commit uri: ${commit_uri}"
    folder=$(curl "${commit_uri}"|jq '[.files[].filename|select(startswith("duffle"))][0]|split("/")[1]' --raw-output) 
fi

if [ ${reason} ==  "PullRequest" ]; then
    folder=$(curl "https://api.github.com/repos/${repo_name}/pulls/${pr_number}/files"|jq '[.[].filename| select(startswith("duffle"))][0]|split("/")[1]' --raw-output) 
fi 

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

registry=$(jq ".invocationImages.${ii_name}.configuration.registry" ./duffle.json --raw-output) 

echo "registry: ${registry}"

if [ "${registry}" != "${cnab_quickstart_registry}/${repository_path}" ]; then 
    printf "Registry property of invocation image configuration should be set to %s in duffle.json" "${cnab_quickstart_registry}/${repository_path}"
    exit 1 
fi

image_repo="${repository_path}/${cnab_name}-${ii_name}" 
echo "image_repo: ${image_repo}"
echo "##vso[task.setvariable variable=image_repo]${image_repo}"
echo "##vso[task.setvariable variable=image_registry]${cnab_quickstart_registry}"