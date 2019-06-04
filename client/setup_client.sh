#!/bin/bash
set -e 

# Check if running in CloudShell

if [[ -z ${ACC_CLOUD} ]]; then 
    echo "This script is intended to run in Azure CloudShell" 
    exit 1
fi

# This is the subscription that is used to execute ACI Driver

if [ -z "${AZURE_SUBSCRIPTION_ID}" ]; then 

        AZURE_SUBSCRIPTION_ID=$(az account show --query id --output tsv)
        if [ -z "${AZURE_SUBSCRIPTION_ID}" ]; then  
            echo "Environment Variable AZURE_SUBSCRIPTION_ID should be set to the Azure Subscription Id to be used with CNAB Bundles" 
            exit 1
        else 
            echo "" >> "${HOME}/.bashrc"
            echo "START ADDING AZURE_SUBSCRIPTION ID ENVIRONEMNT VARIABLE FOR ACI DRIVER" >> "${HOME}/.bashrc"
            echo  export AZURE_SUBSCRIPTION_ID="${AZURE_SUBSCRIPTION_ID}" >> "${HOME}/.bashrc"
            echo "FINISH ADDING AZURE_SUBSCRIPTION ID ENVIRONEMNT VARIABLE FOR ACI DRIVER" >> "${HOME}/.bashrc"
            echo "" >> "${HOME}/.bashrc"
            echo ".bashrc updated added export AZURE_SUBSCRIPTION_ID=\"${AZURE_SUBSCRIPTION_ID}\"  "
        fi
fi 

# This is the location that is used to execute ACI Driver

if [ -z "${ACI_LOCATION}" ]; then 
    if [ -z "${ACC_LOCATION}" ]; then 
        echo "Environment Variable ACI_LOCATION should be set to the location to be used by the ACI Driver" 
        exit 1
    else
        echo "" >> "${HOME}/.bashrc"
        echo "START ADDING ACI_LOCATION ENVIRONEMNT VARIABLE FOR ACI DRIVER" >> "${HOME}/.bashrc"
        echo  export ACI_LOCATION="${ACC_LOCATION}" >> "${HOME}/.bashrc"
        echo "FINISH ADDING ACI_LOCATION ENVIRONEMNT VARIABLE FOR ACI DRIVER" >> "${HOME}/.bashrc"
        echo "" >> "${HOME}/.bashrc"
        echo ".bashrc updated added export ACI_LOCATION=\"${ACC_LOCATION}\"  "
    fi
fi 

# Set up Duffle, Porter and Oras 

DUFFLE_VERSION=aciidriver
DUFFLE_REPO=simongdavies/duffle
TOOLHOME="${HOME}/bin/cnabquickstarts"

# set up local folder for programs and update path

if [ ! -d  "${TOOLHOME}" ]; then 
    mkdir "${TOOLHOME}"  
    export PATH="${TOOLHOME}:${PATH}"
    if [ -f "${HOME}/.bashrc" ]; then
        echo "" >> "${HOME}/.bashrc"
        echo  export PATH="${TOOLHOME}:${PATH}" >> "${HOME}/.bashrc"
        echo ".bashrc updated to include ${TOOLHOME} in PATH "
    else 
        echo "Update your PATH to include ${TOOLHOME}"
    fi
fi;

# Install duffle 

echo "Installing duffle (https://github.com/${DUFFLE_REPO}/releases/download/${DUFFLE_VERSION}/duffle-linux-amd64) to ${TOOLHOME}"
curl "https://github.com/${DUFFLE_REPO}/releases/download/${DUFFLE_VERSION}/duffle-linux-amd64" -fLo "${TOOLHOME}/duffle"
chmod +x "${TOOLHOME}/duffle"
"${TOOLHOME}/duffle" init
echo Installed "duffle: $("${TOOLHOME}/duffle" version)"

# Install duffle aci driver

DUFFLE_ACI_DRIVER_VERSION=v.0.0.1
DUFFLE_ACI_DRIVER_REPO=simongdavies/duffle-aci-driver

echo "Installing duffle-aci-driver (https://github.com/${DUFFLE_ACI_DRIVER_REPO}/releases/download/${DUFFLE_ACI_DRIVER_VERSION}/duffle-aci-driver-linux-amd64) to ${TOOLHOME}"
curl "https://github.com/${DUFFLE_ACI_DRIVER_REPO}/releases/download/${DUFFLE_ACI_DRIVER_VERSION}/duffle-aci-driver-linux-amd64" -fLo "${TOOLHOME}/duffle-aci-driver"
chmod +x "${TOOLHOME}/duffle-aci-driver"
echo Installed "duffle-aci-driver: $("${TOOLHOME}/duffle-aci-driver" version)"

# Install Porter
 
PORTER_URL=https://cdn.deislabs.io/porter
PORTER_VERSION="${PORTER_VERSION:-latest}"
FEED_URL="${PORTER_URL}/atom.xml"

echo "Installing porter (${PORTER_URL}/${PORTER_VERSION}/porter-linux-amd64) to ${TOOLHOME}"
curl "${PORTER_URL}/${PORTER_VERSION}/porter-linux-amd64" -fLo "${TOOLHOME}/porter"
chmod +x "${TOOLHOME}/porter"
cp "${TOOLHOME}/porter" "${TOOLHOME}/porter-runtime"
echo Installed "Porter: $("${TOOLHOME}/porter" version)"

echo "Installing porter mixins"
"${TOOLHOME}/porter" mixin install exec --version "${PORTER_VERSION}" --feed-url "${FEED_URL}"
"${TOOLHOME}/porter" mixin install kubernetes --version "${PORTER_VERSION}" --feed-url "${FEED_URL}"
"${TOOLHOME}/porter" mixin install helm --version "${PORTER_VERSION}" --feed-url "${FEED_URL}"
"${TOOLHOME}/porter" mixin install azure --version "${PORTER_VERSION}" --feed-url "${FEED_URL}"
echo "Installed porter mixins"

ORAS_VERSION=0.5.0
ORAS_REPO=deislabs/oras
ORAS_DOWNLOAD_DIR=/tmp

echo "Installing oras"
curl https://github.com/${ORAS_REPO}/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz -fLo "${ORAS_DOWNLOAD_DIR}/oras_${ORAS_VERSION}_linux_amd64.tar.gz"
tar -zxf "${ORAS_DOWNLOAD_DIR}/oras_0.5.0_linux_amd64.tar.gz" -C "${TOOLHOME}"
chmod +x "${TOOLHOME}/oras"
echo Installed "Oras: $("${TOOLHOME}/oras" version)"

CNAB_QUICKSTARTS_REPO=simongdavies/silver-garbanzo
echo "Downloading Script to generate credential and parameter files"
curl "https://raw.githubusercontent.com/${CNAB_QUICKSTARTS_REPO}/master/client/generate-cnab-param-and-cred-files.sh" -fLo "${TOOLHOME}/generate-cnab-param-and-cred-files.sh"
chmod +x "${TOOLHOME}/generate-cnab-param-and-cred-files.sh"
echo "Downlaoded Script"

if [ -f "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc"
fi