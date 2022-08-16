#!/bin/bash
set -e

# Params
ENVIRONMENT_NAME=$1
CONTAINER_REGISTRY_NAME=$2

# Vars
RESOURCE_GROUP="$ENVIRONMENT_NAME-rg"
KEYVAULT_NAME="$ENVIRONMENT_NAME-kv"
DEPLOYMENT_NAME="$ENVIRONMENT_NAME-dotnet-api-deployment"
LOCATION=$(az group show --name container-app-demo-rg | jq .location)
CONTAINER_REGISTRY_URL="${CONTAINER_REGISTRY_NAME}.azurecr.io"

echo "#######################################################"
echo "Environment Name:   $ENVIRONMENT_NAME"
echo "Resource Group:     $RESOURCE_GROUP"
echo "Keyvault Name:      $KEYVAULT_NAME"
echo "Container Registry: $CONTAINER_REGISTRY_URL"
echo "#######################################################"
echo ""

TAG=$(date '+%Y%m%d%H%M%S')  
IMAGE_NAME="dotnet-api:$TAG"
CONTAINER_IMAGE="$CONTAINER_REGISTRY_URL/$IMAGE_NAME"

docker build -t dotnet-api:latest .
docker tag  dotnet-api:latest $CONTAINER_IMAGE

# Login to the container registry
az acr login --name $CONTAINER_REGISTRY_NAME

# Push the image
docker push $CONTAINER_IMAGE

# Deploy the demo app
az deployment group create \
	--resource-group $RESOURCE_GROUP \
	--name $DEPLOYMENT_NAME \
	--template-file devops/deploy.bicep \
	--parameters "configValue=Defined in a Container App environment variable" \
	--parameters "containerRegistryName=$CONTAINER_REGISTRY_NAME" \
	--parameters "environmentName=$ENVIRONMENT_NAME" \
	--parameters "imageName=$IMAGE_NAME" \
	--parameters "keyVaultName=$KEYVAULT_NAME" \
	--query properties.outputs.fullyQualifiedDomainName.value