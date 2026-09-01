// Creates an Azure Container Registry with Azure Private Link endpoint
@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Container registry name')
param containerRegistryName string

var containerRegistryNameCleaned = replace(containerRegistryName, '-', '')

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-09-01' = {
  name: containerRegistryNameCleaned
  location: location
  tags: tags
  sku: {
    name:'Basic'
  }
  properties: {
    adminUserEnabled: true
    dataEndpointEnabled: true
    encryption: {
      // keyVaultProperties: {
      //   identity: 'string'
      //   keyIdentifier: 'string'
      // }
      status: 'disabled'
    }
    // networkRuleBypassOptions: 'AzureServices'
    // networkRuleSet: {
    //   defaultAction: 'Deny'
    // }
    policies: {
      exportPolicy:{
        status: 'disabled'
      }
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy:{
        status: 'disabled'
      }
      trustPolicy:{
        status: 'disabled'
        type:'Notary'
      }
  }
  publicNetworkAccess: 'Enabled'
  zoneRedundancy: 'Disabled'
}
}

output containerRegistryId string = containerRegistry.id
