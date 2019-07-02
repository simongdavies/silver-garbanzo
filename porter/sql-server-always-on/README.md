# SQL Server Always On Availability Groups on AKS

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fsimongdavies%2Fsilver-garbanzo%2Fmaster%2Fporter%2Fsql-server-always-on%2Fazuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/> 
</a>

This Bundle installs a SQL Server always on availability group on a new AKS Cluster, on install it will:

* Create a new AKS Cluster
* Deploy the SQL Server Operator
* Create Secrets for SQL Server sa password and master password
* Deploy SQL Server Containers, persistent volumes, persistent volume claims and load balancers
* Create services to connect to praimary and scondary replicas

It creates an AKS Cluster with 4 nodes with agent VM Size of Standard_DS2_v2.

Full details can be found [here](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-kubernetes-deploy?view=sqlallproducts-allversions)

## Parameters and Credentials

| Name	| Description  	|
|---	|---	|

| azure_client_id  	| AAD Client ID for Azure account authentication - used to authenticate to Azure using Service Principal for ACI creation to run bundle and also for AKS Cluster 	|
| azure_client_secret  	|  AAD Client Secret for Azure account authentication - used to authenticate to Azure using Service Principal for ACI creation to run bundle and also for AKS Cluster	|
| azure_tenant_id  	|  Azure AAD Tenant Id Azure account authentication - used to authenticate to Azure using Service Principal for ACI creation to run bundle and also for AKS Cluster	|
| azure_subscription_id    | Azure Subscription Id - this is the subscription to be used for ACI creation to run bundle and also for AKS Cluster    | 
| sql_sapassword  	|   The Password to be set for the sa user in SQL Server	|
| sql_masterkeypassword  	|   The Password for the SQL Server Master Key	|
| aks_resource_group  	|   The name of the resource group to create the AKS Cluster in	|
| aks_cluster_name  	|  The name to use fr the AKS Cluster that is created 	|
| location 	|   The Location to create the resources in	|