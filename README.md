##################### prerequisites #######################
#
# Install all needed prerequisites
# 1. git: https://git-scm.com/downloads
# 2. .net core sdk: https://dotnet.microsoft.com/download
# 3. docker: https://www.docker.com/get-started
# 4. azure cli: https://docs.microsoft.com/en-us/cli/azure/
# 5. Valid Azure Subscription is needed
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

docker run --rm -d -p 5000:5000 [image id]

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

#set the correct subscriptions if multiple
az account set --subscription $subscriptionId

#create a resource group
az group create `
  --location centralus `
  --subscription $subscriptionId `
  --name [group name]

############### create/deploy contianer ###################        

#create an azure container
az acr create `
  --admin-enabled true `
  --sku Basic `
  --resource-group $groupName `
  --name [container name]

#show access key
az acr credential show --name [container name]

#log into container using docker
docker login [container name].azurecr.io
#NOTE: username is container name

#get image name
docker image list

#tag docker image
docker tag [imageId] [container name].azurecr.io/helloworld:latest

#push docker image to az container
docker push [container name].azurecr.io/helloworld:latest

###########################################################

################# create/deploy aks #######################

#create aks cluster
az aks create `
  --generate-ssh-keys `
  --node-count 2 `
  --resource-group [group name] `
  --name [cluster name] `
  --attach-acr [container name]

#list repos
az acr repository list --name [container name]

#merge aks with kubectl
az aks get-credentials --resource-group [group name] --name [cluster name]

#deploy container to cluster
kubectl apply -f deployment.yaml

###########################################################

##################### refrences ###########################
#
# https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-app
# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
#
###########################################################
