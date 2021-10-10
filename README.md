
##################### refrences ########################
#
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app
#
#######################################################

##################### prerequisites ########################
#
# 1. Install git if needed
# 2. Install dotnet-sdk if needed
# 3. Install docker if needed
# 4. Install azure cli if needed
#
#######################################################

#log into azure
az login

#list account subscriptions
az account subscription list --output table

#set the correct subscriptions if multiple
az account set \
  --subscription [subscription]

#create a resource group
az group create \
  --location centralus \
  --name [group name] \
  --subscription [subscription]

#create an azure container
az acr create \
  --admin-enabled true \
  --sku Basic \
  --resource-group [group name] \
  --name [container name]

#show access key
az acr credential show --name [container name]

#log into container using docker
docker login [container name].azurecr.io
#note: username is container name

#push docker image to az container
docker push [image]:[tag] [container name].azurecr.io/[project name]

#create aks cluster
az aks create \
  --generate-ssh-keys \
  --node-count 2 \
  --resource-group [group name] \
  --name [cluster name] \
  --attach-acr [container name]

#list repos
az acr repository list --name [container name]


