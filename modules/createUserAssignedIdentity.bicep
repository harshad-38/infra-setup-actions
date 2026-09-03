@description('The location of the user assigned identity.')
param location string
@description('The name of the user assigned identity.')
param resourceName string

resource machineLerninguserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: resourceName
  location: location
}

module roleAssignments 'roleAssignments.bicep' = {
  name: '${machineLerninguserAssignedManagedIdentity.name}RoleML'
  scope: resourceGroup('demoGroup')
  params: {
    principalID: machineLerninguserAssignedManagedIdentity.properties.principalId
    roleDefinitionID: ['b78c5d69-af96-48a3-bf8d-a8b4d589de94']
  }
}

output userAssignedManagedIdentityId string = machineLerninguserAssignedManagedIdentity.id
