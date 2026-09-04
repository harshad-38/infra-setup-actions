// Creates a machine learning workspace, private endpoints and compute resources
// Compute resources include a GPU cluster, CPU cluster, compute instance and attached private AKS cluster
@description('Prefix for resource names')
param prefix string

@description('Storage Account to create a Data Store')
param storageAccountName string

@description('storage account container name to create datastore')
param containerName string

@description('To get the DNS suffic for Storage Account')
param environmentObject object

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('Machine learning workspace name')
param machineLearningName string

@description('Machine learning workspace number')
param num int

@description('Machine learning workspace display name')
param machineLearningFriendlyName string = machineLearningName

@description('Machine learning workspace description')
param machineLearningDescription string

@description('Resource ID of the application insights resource')
param applicationInsightsId string

@description('Resource ID of the container registry resource')
param containerRegistryId string

@description('Resource ID of the key vault resource')
param keyVaultId string

@description('Resource ID of the storage account resource')
param storageAccountId string

@description('Enable public IP for Azure Machine Learning compute nodes')
param amlComputePublicIp bool = true

@description('VM size for the default compute cluster')
param vmSizeParam string

@description('User Assigned Managed Identity ID for the Azure Machine Learning workspace')
param userAssignedManagedIdentityId string

@description('User that will access the compute instance form local environment')
param userObjectId string

resource machineLearning 'Microsoft.MachineLearningServices/workspaces@2022-05-01' = {
  name: machineLearningName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userAssignedManagedIdentityId}': {}
    }
  }
  properties: {
    // workspace organization
    friendlyName: machineLearningFriendlyName
    description: machineLearningDescription

    // dependent resources
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
    keyVault: keyVaultId
    storageAccount: storageAccountId

    // configuration for workspaces with private link endpoint
    imageBuildCompute: 'cluster001'
    publicNetworkAccess: 'Enabled'
    primaryUserAssignedIdentity: userAssignedManagedIdentityId
  }
}

module machineLearningCompute 'machinelearningCompute.bicep' = {
  name: '${machineLearningName}Compute'
  scope: resourceGroup()
  params: {
    userObjectId: userObjectId
    machineLearning: machineLearningName
    location: location
    prefix: prefix
    num: num
    tags: tags
    amlComputePublicIp: amlComputePublicIp
    vmSizeParam: vmSizeParam
  }
  dependsOn: [
    machineLearning
  ]
}

resource dataStore 'Microsoft.MachineLearningServices/workspaces/dataStores@2024-04-01' = {
  name: 'ml_datastore${num}'
  parent: machineLearning
  properties: {
    accountName: storageAccountName
    containerName: containerName
    credentials: {
      credentialsType: 'None'
    }
    datastoreType: 'AzureBlob'
    description: ''
    endpoint: environmentObject.suffixes.storage
    serviceDataAccessAuthIdentity: 'WorkspaceUserAssignedIdentity'
  }
}

module roleAssignments 'roleAssignments.bicep' = {
  name: '${machineLearning.name}RoleML'
  scope: resourceGroup('demoGroup')
  params: {
    principalID: machineLearning.identity.principalId
    roleDefinitionID: ['b78c5d69-af96-48a3-bf8d-a8b4d589de94']
  }
}

output machineLearningId string = machineLearning.identity.principalId
