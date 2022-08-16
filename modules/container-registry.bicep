param containerRegistryName string
param keyVaultName string
param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2022-02-01-preview' = {
  name: containerRegistryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
    publicNetworkAccess: 'Enabled'
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource acrAccessKey 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'acr-accesskey'
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
    }
    value: containerRegistry.listCredentials().passwords[0].value
  }
}
