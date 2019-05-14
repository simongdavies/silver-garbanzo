#!/bin/bash

set -e 
duffle_version="/0.1.0-ralpha.5%2Benglishrose"
cnab_quickstart_registry="sdacr.azurecr.io"
build_required=false

# Update could be in either the duffle or the porter directory or it could be an update that is not related to a solution, this should only happen on a merge as builds are only trigged for PR when changes are made in the dufffle or porter folder

echo "Get the files in the PR or merge commit to find the solution folder name"

if [ "${reason}" == "IndividualCI" ]; then
    owner_and_repo="${repo_uri##https://github.com/}"
    commit_uri=https://api.github.com/repos/${owner_and_repo}/commits/${source_version}
    echo "Merge Commit uri: ${commit_uri}"
    files=$(curl "${commit_uri}"|jq '[.files[].filename]') 
fi

if [ "${reason}" == "PullRequest" ]; then
    pr_uri="https://api.github.com/repos/${repo_name}/pulls/${pr_number}/files"
    echo "PR uri: ${pr_uri}"
    files=$(curl "${pr_uri}"|jq '[.[].filename]') 
fi

printf "file:\\n%s\\n" "${files}"

tool=$(echo "${files}"|jq 'if . | contains(["/"]) then .|map(select(contains("/")))[0]|split("/")[0]  else empty end')

printf "tool:%s\\n" "${tool}"

# Each bundle definition should exist with a directory under the duffle directory - the folder name is derived from the set of files that have been changed in this pull request

if [ "${tool}" ]; then
    folder=$(echo "${files}"|jq --arg tool "${tool}" '.|map(select(startswith($tool)))[0]|split("/")[0]' --raw-output)
    echo "##vso[task.setvariable variable=tool]${tool}"
fi

printf "folder:%s\\n" "${folder}"

if [ "${folder}" ]; then
    if [ "$(find "${repo_local_path}/${folder}" -maxdepth 1 ! -type d)" ]; then 
        printf "Files should not be placed in the %s directory - only %s solution folders in this folder. \\n" "${folder}" "${folder}"
        exit 1 
    fi
fi

if [ "${folder}" == "duffle" ]; then

    echo "Download Duffle"

    mkdir "${agent_temp_directory}/duffle"
    curl https://github.com/deislabs/duffle/releases/download/${duffle_version}/duffle-linux-amd64 -L -o  "${agent_temp_directory}/duffle/duffle"
    chmod +x "${agent_temp_directory}/duffle/duffle"

    # Update the path

    echo '##vso[task.prependpath]${agent_temp_directory}/duffle'

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

    if [ "${registry}" != "${cnab_quickstart_registry}/${folder}" ]; then 
        printf "Registry property of invocation image configuration should be set to %s in duffle.json" "${cnab_quickstart_registry}/${folder}"
        exit 1 
    fi

    image_repo="${folder}/${cnab_name}-${ii_name}" 
    echo "image_repo: ${image_repo}"
    echo "##vso[task.setvariable variable=image_repo]${image_repo}"
    echo "##vso[task.setvariable variable=image_registry]${cnab_quickstart_registry}"
    build_required=true
fi

# Download porter

if [ "${folder}" == "porter" ]; then
    curl https://deislabs.blob.core.windows.net/porter/latest/install-linux.sh | bash
    build_required=true
fi

 echo "##vso[task.setvariable variable=BuildRequired]${build_required}"
