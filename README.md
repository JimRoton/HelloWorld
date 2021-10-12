##################### prerequisites #######################
#
# Install all needed prerequisites
# 1. git: https://git-scm.com/downloads
# 2. .net core sdk: https://dotnet.microsoft.com/download
# 3. docker: https://www.docker.com/get-started
# 4. azure cli: https://docs.microsoft.com/en-us/cli/azure/
# 5. Valid Azure Subscription is needed
#
# NOTE: the scripts below are formatted for PowerShell
#
###########################################################

##################### test repo ###########################
#
# this section clones and test the repo
#
###########################################################
#clone repo
git clone https://github.com/JimRoton/HelloWorld

#test repo
cd HelloWorld
dotnet build
dotnet run

#browse to http://localhost:50000/hello?myName=YourNameHere

##################### build docker image ##################
#
# this section builds and test the docker image
#
###########################################################

#build docker image using Dockerfile
docker build .

#list docker images
docker image list

#capture imageId
$imageId="[Image Id]"

docker run --rm -d -p 5000:5000 $imageId

#browse to http://localhost:5000/hello?myName=YourNameHere

##################### deploy to aks #######################        
#
# this section creates a container in azure, pushes to it
# creates an aks cluster in azure and deploys to it
#
###########################################################

#log into azure
az login

#list account subscriptions
az account subscription list --output table

#NOTE: you may be prompted to add 'extension account'.

$subscriptionId="[Subscription Id]"

#set the correct subscriptions if multiple
az account set --subscription $subscriptionId

############### create/deploy contianer ###################        

#create a group name
$groupName="[group name]"

#create a resource group
az group create `
  --location centralus `
  --subscription $subscriptionId `
  --name $groupName

#create container name
$containerName="[container name]"

#create an azure container
az acr create `
  --admin-enabled true `
  --sku Basic `
  --resource-group $groupName `
  --name $containerName

#show access key
az acr credential show --name $containerName

#grab login creds
$un="[user name]"
$pwd="[password]"

#log into container using docker
docker login -u $un -p $pwd "$($containerName).azurecr.io"

#get image name
docker image list

#tag docker image
docker tag $imageId "$($containerName).azurecr.io/helloworld:latest"

#push docker image to az container
docker push "$($containerName).azurecr.io/helloworld:latest"

###########################################################

################# create/deploy aks #######################

#create cluster name
$clusterName="[cluster name]"

#create aks cluster
az aks create `
  --generate-ssh-keys `
  --node-count 2 `
  --resource-group $groupName `
  --name $clusterName `
  --attach-acr $containerName

#list repos
az acr repository list --name $containerName

#merge aks with kubectl
az aks get-credentials `
  --resource-group $groupName `
  --name $clusterName

#deploy container to cluster
kubectl apply -f deployment.yaml

#browse to api
http://[cluster ip]:5000/hello?myName=Jim

###########################################################

##################### refrences ###########################
#
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
# https://docs.microsoft.com/en-us/azure/aks/concepts-network
#
###########################################################
