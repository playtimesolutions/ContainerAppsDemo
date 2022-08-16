@secure()
param acrAccessKey string
param acrUsername string
param configValue string
param containerAppName string
param containerRegistry string
param cpu string = '0.5'
param environmentName string 
param imageName string
param keyVaultName string
param location string
param memory string = '1.0Gi'
param maxReplicas int = 10
param minReplicas int = 0
param targetPort int = 80


resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: environmentName
}

resource containerAppIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: '${containerAppName}-identity'
  location: location
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${containerAppIdentity.id}' : {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironment.id
    configuration: {
      secrets: [
        {
          name: 'acr-accesskey'
          value: acrAccessKey
        }
      ]      
      registries: [
        {
          server: containerRegistry
          username: acrUsername
          passwordSecretRef: 'acr-accesskey'
        }
      ]
      ingress: {
        external: true
        targetPort: targetPort
        transport: 'auto'
      }
    }
    template: {
      containers: [
        {
          image: '${containerRegistry}/${imageName}'
          name: containerAppName
          env: [
            {
              name: 'ASPNETCORE_ENVIRONMENT'
              value: 'Azure'
            }
            {
              name: 'AzureADManagedIdentityClientId'
              value: containerAppIdentity.properties.clientId
            }
            {
              name: 'AzureKeyVaultUri'
              value: 'https://${keyVaultName}.vault.azure.net'
            }
            {
              name: 'Settings__ConfigValue'
              value: configValue
            }
          ]
          resources: {
            cpu: json(cpu)
            memory: memory
          }
        }
      ]
      scale: {
        minReplicas: minReplicas
        maxReplicas: maxReplicas
        rules: [
          {
            name: 'http-rule'
            custom: {
              type: 'http'
              metadata: {
                concurrentRequests: '3'
              }
            }
          }
        ]
      }
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

resource keyVaultAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2019-09-01' = {
  name: 'add'
  parent: keyVault
  properties: {
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: containerAppIdentity.properties.principalId
        permissions: {
          secrets: [
            'get'
            'list'
          ]
        }    
      }
    ]
  }
}

resource runtimeSecret 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  name: 'dotnet-api-Settings--SecretValue'
  parent: keyVault
  properties: {
    attributes: {
      enabled: true
    }
    value: 'Some super secret value'
  }
}

output fullyQualifiedDomainName string = '${containerAppName}.${containerAppEnvironment.properties.defaultDomain}'
