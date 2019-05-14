# Azure CNAB Quickstart Bundles

This repository contains a set of Azure focused CNAB Bundles contributed by the community that can be used to manage applications on Azure. To learn more about CNAB go [here](https://cnab.io/).

## How to install a Bundle

The easiest way to install a Bundle is to use Azure CloudShell, but any CNAB compliant tool can be used to install and manage an application. For instructions on setting up CloudShell see [this document](set_up_cloudshell.md) 

## Repository Structure

The repository contains the source for Azure focused CNAB bundles, each bundle is contained in a directory under one of the following directories:

* duffle - These bundles are defined and built using [Duffle](https://duffle.sh/ 'The duffle website')
* porter - These bundles are defined and built using [Porter](https://porter.sh/ 'The porter website')

The invocation image for each bundle is stored in an Azure Container Registry at (https://cnabquickstarts.azurecr.io) once the tools support pushing and pulling bundles to OCI registries then the entire bundle will be hosted in the registry

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
https://duffle.sh/
