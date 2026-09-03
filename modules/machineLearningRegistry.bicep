param registryName string

param location string

param storageAccountType string

param userAssignedManagedIdentityId string

param tags object

var acrName = 'acr-${registryName}-${substring(uniqueString(resourceGroup().id), 2, 6)}'

var storageName = 'st${registryName}${substring(uniqueString(resourceGroup().id), 2, 6)}'

resource mlRegistry 'Microsoft.MachineLearningServices/registries@2023-04-01' = {
  name: registryName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned,UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
  properties: {
    regionDetails: [
      {
        acrDetails: [
          {
            systemCreatedAcrAccount: {
              acrAccountName: acrName
              acrAccountSku: 'Premium'
              
            }
          }
        ]
        location: location

        storageAccountDetails: [
          {
            systemCreatedStorageAccount: {
              storageAccountName: storageName
              storageAccountHnsEnabled: true
              allowBlobPublicAccess: true
              storageAccountType: storageAccountType
            }
          }
        ]
      }
    ]
    publicNetworkAccess: 'Enabled'
  }

}

module roleAssignments 'roleAssignments.bicep' = {
  name: 'roleAssignmentsMLRegistry'
  scope: resourceGroup('demoGroup')
  params: {
    principalID: mlRegistry.identity.principalId
    roleDefinitionID: ['b78c5d69-af96-48a3-bf8d-a8b4d589de94']
  }
}

