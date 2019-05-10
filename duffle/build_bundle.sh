#!/bin/sh

set -e 

echo "Download Duffle"

duffle_version="/0.1.0-ralpha.5%2Benglishrose"
curl https://github.com/deislabs/duffle/releases/download/${duffle_version}/duffle-linux-amd64 -L -o  $(Agent.ToolsDirectory)/duffle
chmod +x $(Agent.ToolsDirectory)/duffle

echo "Get the files in the PR to find the solution folder name"

# Each bundle definition should exist with a directory under the duffle directory - the folder name is derived from the set of files that have been changed in this pull request

folder=$(curl "https://api.github.com/repos/$(Build.Repository.Name)/pulls/$(System.PullRequest.PullRequestNumber)/files")|jq [.[].filename| select(startswith("duffle"))][0]|split("/")[1]

echo "Building Bundle in Solution Directory: $(Build.Repository.LocalPath)/duffle/${folder}"

cd $(Build.Repository.LocalPath)/duffle/${folder}
$(Agent.ToolsDirectory)/duffle init
$(Agent.ToolsDirectory)/duffle build