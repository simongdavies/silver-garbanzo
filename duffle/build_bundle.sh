#!/bin/sh

set -e 

echo "Download Duffle"

mkdir ${agent_temp_directory}/duffle
duffle_version="/0.1.0-ralpha.5%2Benglishrose"
curl https://github.com/deislabs/duffle/releases/download/${duffle_version}/duffle-linux-amd64 -L -o  ${agent_temp_directory}/duffle/duffle
chmod +x ${agent_temp_directory}/duffle
export PATH=${agent_temp_directory}/duffle:${PATH}

echo "Get the files in the PR to find the solution folder name"

# Each bundle definition should exist with a directory under the duffle directory - the folder name is derived from the set of files that have been changed in this pull request

folder=$(curl "https://api.github.com/repos/$(Build.Repository.Name)/pulls/$(System.PullRequest.PullRequestNumber)/files"|jq '[.[].filename| select(startswith("duffle"))][0]|split("/")[1]' --raw-output) 
echo "Building Bundle in Solution Directory: $(Build.Repository.LocalPath)/duffle/${folder}"
cd $(Build.Repository.LocalPath)/duffle/${folder}

duffle init
duffle build