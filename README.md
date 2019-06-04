# Azure CNAB Quickstart 

This repository contains a set of Azure focused CNAB Packages contributed by the community that can be used to manage applications on Azure. To learn more about CNAB go [here](https://cnab.io/).

## Repository Structure

The repository contains the source for Azure focused CNAB bundles, each bundle is contained in a directory under one of the following directories:

* duffle - These bundles are defined and built using [Duffle](https://duffle.sh/ 'The duffle website')
* porter - These bundles are defined and built using [Porter](https://porter.sh/ 'The porter website')

The invocation image for each bundle is stored in an Azure Container Registry at (https://cnabquickstarts.azurecr.io) once the tools support pushing and pulling bundles to OCI registries then the entire bundle will be hosted in the registry

## How to Install a Package

Any CNAB compliant tool can be used to deploy these packages, to make it easy to install without having to download and install any software the following approaches can be used:

### Deploy using the Azure Portal

The easiest way to install a Package is to use the Deploy to Azure button from the README.md for each solution, this will launch the Azure Portal Template deployment experience

### Deploy using PowerShell

The easiest way to install a Bundle is to use Azure CloudShell, but any CNAB compliant tool can be used to install and manage an application. For instructions on setting up CloudShell see [this document](set_up_cloudshell.md) 


## How to Build a Package



## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com. All contributions made to and solutions provided in this repository are licensed under the MIT license which can be found [here](LICENSE).

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
https://duffle.sh/
