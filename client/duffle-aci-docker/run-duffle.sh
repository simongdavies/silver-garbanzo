#!/bin/bash
set -e
CNAB_QUICKSTART_REGISTRY="cnabquickstartstest.azurecr.io"

# Script to run duffle using ACI Driver in Docker
# All arguments are expected to be in ENV VARS
# Requires the following arguments plus any parameters/creds for the bundle 

# CNAB_INSTALLATION_NAME
# CNAB_ACTION
# CNAB_BUNDLE_NAME The anme os the bundle to install should be in the form of tool/bundlename (e.g porter/{name} or duffle/{name})
# ACI_LOCATION: The location to be used by the Duffle ACI Driver


if [ -z "${CNAB_INSTALLATION_NAME}" ]; then 
    echo "Environment Variable CNAB_INSTALLATION_NAME} should be set to the name of the instance installed/updated/deleted" 
    exit 1
fi 

if [ -z "${CNAB_ACTION}" ]; then 
    echo "Environment Variable CNAB_ACTION should be set to the name of action to be taken on the instance" 
    exit 1
fi 

if [ -z "${CNAB_BUNDLE_NAME}" ]; then 
    echo "Environment Variable CNAB_BUNDLE_NAME should be set to the name of the bundle to be installed/updated/deleted" 
    exit 1
fi 

if [ -z "${ACI_LOCATION}" ]; then 
    echo "Environment Variable ACI_LOCATION should be set to the location to be used by the ACI Driver" 
    exit 1
fi 

# TODO need to set up capability to use MSI instead of SPN  should validate these

# if [ -z "${ACI_MSI_TYPE}" ]; then 
#     echo "Environment Variable ACI_MSI_TYPE should be set to the MSI type to be used to run ACI" 
#     exit 1
# fi 

# if [ "${ACI_MSI_TYPE}" == "user" ]; then

#     if [ -z "${ACI_USER_MSI_RESOURCE_ID}" ]; then 
#         echo "Environment Variable ACI_USER_MSI_RESOURCE_ID should be should be set to the MSI USer Resource ID to be used to run ACI" 
#         exit 1
#     fi 

# else

#     if [ -z "${ACI_SYSTEM_MSI_ROLE}" ]; then 
#         echo "Environment Variable ACI_SYSTEM_MSI_ROLE should be set to the Role to assign to the System MSI used to run ACI" 
#         exit 1
#     fi 

#     if [ -z "${ACI_SYSTEM_MSI_SCOPE}" ]; then 
#         echo "Environment Variable ACI_SYSTEM_MSI_SCOPE should be set to the Scope to assign the ACI_SYSTEM_MSI_ROLE at for the System MSI used to run ACI" 
#         exit 1
#     fi 

# fi

oras pull "${CNAB_QUICKSTART_REGISTRY}/${CNAB_BUNDLE_NAME}/bundle.json:latest"

# Look for parameters in the bundle.json and set them in a TOML File
# Expects to find parameter values in ENV variable named after the bundle parameter in UPPER case
# Ignores missing environment variables if the parameter has a default value

# TODO Support File Source as well as ENV

touch params.toml

parameters=$(cat bundle.json|jq '.parameters|keys|.[]' -r)

for param in ${parameters};do 
    var=$(echo "${param^^}")
    if [ -z ${!var:-} ]; then
        # Only require a value if default values is not set
        if [ ! $(cat bundle.json|jq --arg key "${param}" '.parameters|.[$key]|has("defaultValue")') == true ]; then 
            printf "Bundle expects parameter: %s to be set using environment variable: %s\\n" "${param}" "${var}"
            exit 1
        fi
    else
        echo "${param}=\"${!var}\"" >> params.toml
    fi
done

# Look credentials in the bundle.json and set them in a credentials file
# Expects to find credentials values in ENV variable named after the bundle credential in UPPER case

touch credentials.yaml

echo "name: credentials" >> credentials.yaml
echo "credentials:" >> credentials.yaml

credentials=$(cat bundle.json|jq '.credentials|keys|.[]' -r)

for cred in ${credentials}; do
    var=$(echo "${cred^^}")
    if [ -z ${!var:-} ]; then
        printf "Bundle expects credential: %s to be set using environment variable: %s\\n" "${cred}" "${var}"
        exit 1
    else
        printf "%s name: %s \\n  source: \\n   env: %s \\n" "-" "${cred}" "${var}" >> credentials.yaml
    fi
done

# TODO mount storage for claims

export DUFFLE_HOME="${HOME/.duffle}"
duffle init 
mv credentials.yaml "${DUFFLE_HOME}/credentials/credentials.yaml"

# TODO Support custom actions

case "${CNAB_ACTION}" in
    install)
        echo "Installing the Application"  
        duffle install "${CNAB_INSTALLATION_NAME}" bundle.json -f -d aci-driver -c credentials -p params.toml -v 
        ;;
    uninstall)
        echo "Destroying the Application"        
        duffle uninstall "${CNAB_INSTALLATION_NAME}" -d aci-driver -c credentials -p params.toml -v
        ;;
    upgrade)
        echo "Upgrading the Application"
        duffle upgrade "${CNAB_INSTALLATION_NAME}" -d aci-driver -c credentials -p params.toml -v
        ;;
    *)
        echo "No action for ${CNAB_ACTION}"
        ;;
esac