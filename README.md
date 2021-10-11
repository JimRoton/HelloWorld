##################### prerequisites #######################
#
# 1. Install git if needed
# 2. Install dotnet-sdk if needed
# 3. Install docker if needed
# 4. Install azure cli if needed
#
###########################################################

##################### test repo ###########################
#
# this section clones and test the repo
#
###########################################################
#clone repo
git clonse https://github.com/JimRoton/HelloWorld

#test repo
cd HelloWorld
dotnet build
dotnet run

#browse to https://localhost:50001/hello?myName=YourNameHere

##################### build docker image ###################
#
# this section builds and test the docker image
#
###########################################################

#build docker image using Dockerfile
docker build .

#list docker images
docker image list

docker run -p 5001:5001 [image id]

#browse to https://localhost:5001/hello?myName=YourNameHere

##################### deploy to aks #######################        
#
# this section create a container in azure, pushes to it
# creates an aks cluster in azure and deploys to it
#
###########################################################

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

#merge aks with kubectl
az aks get-credentials --resource-group $groupName --name $clusterName

#deploy container to cluster
kubectl apply -f deployment.yaml

##################### refrences ########################
#
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app
#
#######################################################
