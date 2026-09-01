@description('Principal Id to which the role has to be assigned')
param principalID string

@description('Role defintion ID which consists of priviledges to be granted to ML Workspace')
param roleDefinitionID array

@description('Array of unique names for the compute cluster role assignments')
var roleAssignmentNames = [for roleId in roleDefinitionID: guid(principalID, roleId, resourceGroup().id)]

resource roleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleId, index) in roleDefinitionID: {
  name: roleAssignmentNames[index]
  properties:{
    principalId: principalID
    principalType: 'ServicePrincipal'
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleId)
  }
}]

