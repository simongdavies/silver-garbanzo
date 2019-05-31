# Spring Music Demo App with Azure Cosmos DB

This CNAB bundle is created using Duffle.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsimongdavies%2Fsilver-garbanzo%2Fmaster%2Fduffle%2Fspring-music%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/> 
</a>

### Prerequistes

- Duffle on local machine. https://github.com/deislabs/duffle
- Docker on local machine (eg - Docker for Mac)
- Bash
- Azure service principal with rights to create a RG, AKS, Cosmos, etc. 

    ```bash
    az ad sp create-for-rbac --name ServicePrincipalName
    ```

More details here: https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli?view=azure-cli-latest 

### Build / Install this bundle

* Setup duffle credential set

    ```bash
    duffle credential generate azure spring-music
    # enter values for clientid, pwd, sub, tenant
    # or create local env variables
    ```
 * Build bundle 

    ```bash
    duffle build .
    ```

* Install bundle

    ```
    duffle install --credentials=azure spring-music spring-music:0.1.0
    ```
