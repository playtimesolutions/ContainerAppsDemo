@secure()
param acrAccessKey string
param acrUsername string
param containerAppName string
param containerRegistry string
param cpu string = '0.5'
param environmentName string 
param imageName string
param location string
param memory string = '1.0Gi'
param maxReplicas int = 10
param minReplicas int = 0
param targetPort int = 80


resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2022-03-01' existing = {
  name: environmentName
}

resource containerApp 'Microsoft.App/containerApps@2022-03-01' = {
  name: containerAppName
  location: location
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

output fullyQualifiedDomainName string = '${containerAppName}.${containerAppEnvironment.properties.defaultDomain}'
