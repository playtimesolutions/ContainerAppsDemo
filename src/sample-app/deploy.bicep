param containerRegistryName string
param environmentName string
param imageName string
param location string = resourceGroup().location

resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: '${environmentName}-kv'
}

module sampleApp './../../modules/container-app.bicep' = {
  name: '${environmentName}-sample-app-container-app-deployment'
  params: {
    acrAccessKey: keyVault.getSecret('acr-accesskey')
    acrUsername: containerRegistryName
    containerAppName: 'sample-app'
    containerRegistry: '${containerRegistryName}.azurecr.io'
    environmentName: '${environmentName}-env'
    imageName: imageName
    location: location
  }
}

output fullyQualifiedDomainName string = sampleApp.outputs.fullyQualifiedDomainName
