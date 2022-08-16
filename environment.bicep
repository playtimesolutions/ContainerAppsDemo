param containerRegistryName string
param environmentName string
param keyVaultName string
param location string = resourceGroup().location

module keyVault './modules/keyvault.bicep' = {
  name: '${environmentName}-kv-deployment'
  params: {
    keyVaultName: keyVaultName
    location: location
  }
}

module containerRegistry './modules/container-registry.bicep' = {
  name: '${environmentName}-acr-deployment'
  dependsOn: [keyVault]
  params: {
    containerRegistryName: containerRegistryName
    keyVaultName: keyVaultName
    location: location
  }
}

module containerAppEnvironment './modules/container-app-environment.bicep' = {
  name: '${environmentName}-env-deployment'
  dependsOn: [containerRegistry]
  params: {
    environmentName: environmentName
    keyVaultName: keyVaultName
    location: location
  }
}
