#!/bin/bash
set -e 

# By default these credentials will also be used to execute ACI Driver 
# TODO Change this to use logged in user by default

if [ -z "${AZURE_SUBSCRIPTION_ID}" ]; then 
    echo "Environment Variable AZURE_SUBSCRIPTION_ID should be set to the Azure Subscription Id to be used with CNAB Bundles" 
    exit 1
fi 

if [ -z "${AZURE_TENANT_ID}" ]; then 
    echo "Environment Variable AZURE_TENANT_ID should be set to the Azure Subscription Id to be used with CNAB Bundles" 
    exit 1
fi

if [ -z "${AZURE_CLIENT_ID}" ]; then 
    echo "Environment Variable AZURE_CLIENT_ID should be set to the Azure Service  to be used with CNAB Bundles" 
    exit 1
fi 

if [ -z "${AZURE_CLIENT_SECRET}" ]; then 
    echo "Environment Variable AZURE_CLIENT_SECRET should be set to the Azure Service Principal Client Secret to be used with CNAB Bundles" 
    exit 1
fi 

# TODO: check if there is a default location in the cli config

if [ -z "${ACI_LOCATION}" ]; then 
    echo "Environment Variable ACI_LOCATION should be set to the location to be used by the ACI Driver" 
    exit 1
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
echo Installed "duffle: $("${TOOLHOME}/duffle-aci-driver" version)"

# Install Porter
 
PORTER_URL=https://cdn.deislabs.io/porter
PORTER_VERSION="${PORTER_VERSION:-latest}"
FEED_URL="${PORTER_URL}/atom.xml"

echo "Installing porter to ${TOOLHOME}"
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

DEFAULT_CREDENTIALS_NAME="default-credentials"
DEFAULT_CREDENTIALS_LOCATION=simongdavies/silver-garbanzo/master
if [ -z "${DUFFLE_HOME}" ]; then 
    DUFFLE_HOME="${HOME}/.duffle"
fi

echo "Creating Default Credentials File from https://raw.githubusercontent.com/${DEFAULT_CREDENTIALS_LOCATION}${DEFAULT_CREDENTIALS_NAME}.yaml"
curl "https://raw.githubusercontent.com/${DEFAULT_CREDENTIALS_LOCATION}/${DEFAULT_CREDENTIALS_NAME}.yaml" -fLo "${DUFFLE_HOME}/credentials/${DEFAULT_CREDENTIALS_NAME}.yaml"
echo "Created Default Credentials"
"${TOOLHOME}/duffle" credentials list ${DEFAULT_CREDENTIALS_NAME}

if [ -f "${HOME}/.bashrc" ]; then
    source "${HOME}/.bashrc"
fi
