#!/bin/bash
set -e

# Params
ENVIRONMENT_NAME=$1
LOCATION=$2

#Vars
RESOURCE_GROUP="$ENVIRONMENT_NAME-rg"
KEYVAULT_NAME="$ENVIRONMENT_NAME-kv"
DEPLOYMENT_NAME="$ENVIRONMENT_NAME-deployment"

# Generate a pseudo-unique container registry name
UNIQUENESS=$(echo -n $RESOURCE_GROUP | sha256sum | head -c 6)
CONTAINER_REGISTRY_NAME="${ENVIRONMENT_NAME//-/}${UNIQUENESS}"
CONTAINER_REGISTRY_URL="${CONTAINER_REGISTRY_NAME}.azurecr.io"

echo "#######################################################"
echo "Environment Name:        $ENVIRONMENT_NAME"
echo "Location:                $LOCATION"
echo "Resource Group:          $RESOURCE_GROUP"
echo "Keyvault Name:           $KEYVAULT_NAME"
echo "Deployment Name          $DEPLOYMENT_NAME"
echo "Container Registry Name: $CONTAINER_REGISTRY_NAME"
echo "#######################################################"
echo ""

# Create resource group
az group create \
    --location $LOCATION \
	--name $RESOURCE_GROUP

# Deploy environment
az deployment group create \
	--resource-group $RESOURCE_GROUP \
	--name $DEPLOYMENT_NAME \
	--template-file environment.bicep \
	--parameters "containerRegistryName=$CONTAINER_REGISTRY_NAME" \
	--parameters "environmentName=$ENVIRONMENT_NAME" \
	--parameters "keyVaultName=$KEYVAULT_NAME"