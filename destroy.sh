#!/bin/sh
set -e

# Params
ENVIRONMENT_NAME=$1

# Vars
RESOURCE_GROUP="$ENVIRONMENT_NAME-rg"
KEYVAULT_NAME="$ENVIRONMENT_NAME-kv"

echo "#######################################################"
echo "Resource Group:     $RESOURCE_GROUP"
echo "Keyvault Name:      $KEYVAULT_NAME"
echo "#######################################################"
echo ""

# Delete resource group
az group delete --name $RESOURCE_GROUP

# Purge keyvault
az keyvault purge --name $KEYVAULT_NAME