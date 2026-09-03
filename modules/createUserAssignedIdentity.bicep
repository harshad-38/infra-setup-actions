@description('The location of the user assigned identity.')
param location string
@description('The name of the user assigned identity.')
param resourceName string

resource machineLerninguserAssignedManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: resourceName
  location: location
}

output userAssignedManagedIdentityId string = machineLerninguserAssignedManagedIdentity.id
