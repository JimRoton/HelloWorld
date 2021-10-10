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

#get subscription id
subscriptionId=$(az account show --query id --output tsv)
echo $subscriptionId

#set the correct subscriptions if multiple
az account set \
  --subscription $subscriptionId

groupName=[group name]

#create a resource group
az group create \
  --location centralus \
  --subscription $subscriptionId \
  --name $groupName

containerName=[container name]

#create an azure container
az acr create \
  --admin-enabled true \
  --sku Basic \
  --resource-group $groupName \
  --name $containerName

#show access key
az acr credential show --name $containerName

#log into container using docker
docker login {$containerName}.azurecr.io
#note: username is container name

#get image name
docker image list

#push docker image to az container
docker push [image]:[tag] {$containerName}.azurecr.io/helloworld

clusterName=[cluster name]

#create aks cluster
az aks create \
  --generate-ssh-keys \
  --node-count 2 \
  --resource-group $groupName \
  --name $clusterName \
  --attach-acr $containerName

#list repos
az acr repository list --name $containerName

##################### refrences ########################
#
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app
#
#######################################################
