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
    roleDefinitionID: ['b78c5d69-af96-48a3-bf8d-a8b4d589de94','ba92f5b4-2d11-453d-a403-e96b0029c9fe','8311e382-0749-4cb8-b61a-304f252e45ec','b86a8fe4-44ce-4948-aee5-eccb2c155cd7']
    principalType: 'ServicePrincipal'
  }
}

output userAssignedManagedIdentityId string = machineLerninguserAssignedManagedIdentity.id
