param configValue string
param containerRegistryName string
param environmentName string
param imageName string
param keyVaultName string
param location string = resourceGroup().location

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: '${environmentName}-kv'
}

module dotnetApi './container-app.bicep' = {
  name: '${environmentName}-dotnet-api-container-app-deployment'
  params: {
    acrAccessKey: keyVault.getSecret('acr-accesskey')
    acrUsername: containerRegistryName
    configValue: configValue
    containerAppName: 'dotnet-api'
    containerRegistry: '${containerRegistryName}.azurecr.io'
    environmentName: '${environmentName}-env'
    imageName: imageName
    keyVaultName: keyVaultName
    location: location
  }
}

output fullyQualifiedDomainName string = dotnetApi.outputs.fullyQualifiedDomainName
