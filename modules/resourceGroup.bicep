@description('Loacation where the resource group is created')
param resourceGroupLocation string

@description('Resource group name')
param resourceGroupName string

targetScope='subscription'

resource newRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
}
