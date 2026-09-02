// Execute this main file to configure Azure Machine Learning end-to-end in a moderately secure set up

// Parameters
@minLength(2)
@maxLength(10)
@description('Prefix for all resource names.')
param prefix string

@description('Azure region used for the deployment of all resources.')
param location string = resourceGroup().location

@description('Set of tags to apply to all resources.')
param tags object

// @description('Bastion subnet address prefix')
// param azureBastionSubnetPrefix string

// @description('Deploy a Bastion jumphost to access the network-isolated environment?')
// param deployJumphost bool

// @description('Jumphost virtual machine username')
// param dsvmJumpboxUsername string

// @secure()
// @minLength(8)
// @description('Jumphost virtual machine password')
// param dsvmJumpboxPassword string

@description('Enable public IP for Azure Machine Learning compute nodes')
param amlComputePublicIp bool

@description('VM size for the default compute cluster')
param amlComputeDefaultVmSize string

// Variables
var name = toLower('${prefix}')

// Create a short, unique suffix, that will be unique to each resource group
var uniqueSuffix = substring(uniqueString(resourceGroup().id), 2, 6)

// Dependent resources for the Azure Machine Learning workspace
module keyvault 'modules/keyVault.bicep' = {
  name: 'kvd-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    keyvaultName: 'kvd-${name}-${uniqueSuffix}-03'
    tags: tags
  }
}

module storage 'modules/storage.bicep' = {
  name: 'st${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    storageName: 'st${name}${uniqueSuffix}'
    storageSkuName: 'Standard_LRS'
    tags: tags
  }
}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: 'cr${name}${uniqueSuffix}-deployment'
  params: {
    location: location
    containerRegistryName: 'cr${name}${uniqueSuffix}'
    tags: tags
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {  
  name: 'appi-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    applicationInsightsName: 'appi-${name}-${uniqueSuffix}'
    logAnalyticsWorkspaceName: 'ws-${name}-${uniqueSuffix}'
    tags: tags
  }
}

module azuremlWorkspace 'modules/machineLearning.bicep' = {
  name: 'mlw-${name}-${uniqueSuffix}-deployment'
  scope: resourceGroup('demoGroup')
  params: {
    // workspace organization
    machineLearningName: 'mlw-${name}-${uniqueSuffix}'
    machineLearningFriendlyName: 'Private link endpoint sample workspace'
    machineLearningDescription: 'This is an example workspace having a private link endpoint.'
    location: location
    prefix: name
    tags: tags
    num: 1
    // dependent resources
    applicationInsightsId: applicationInsights.outputs.applicationInsightsId
    containerRegistryId: containerRegistry.outputs.containerRegistryId
    keyVaultId: keyvault.outputs.keyvaultId
    storageAccountId: storage.outputs.storageId
    storageAccountName: storage.outputs.storageAccountName
    containerName: storage.outputs.containerName
    environmentObject: storage.outputs.environmentObject

    // compute
    amlComputePublicIp: amlComputePublicIp
    vmSizeParam: amlComputeDefaultVmSize
  }
}

module azuremlWorkspaceTwo 'modules/machineLearning.bicep' = {
  name: 'mlw-${name}-${uniqueSuffix}-second-deployment'
  scope: resourceGroup('demo')
  params: {
    // workspace organization
    machineLearningName: 'mlw-${name}-${uniqueSuffix}-two'
    machineLearningFriendlyName: 'Private link endpoint sample workspace'
    machineLearningDescription: 'This is an example workspace having a private link endpoint.'
    location: location
    prefix: name
    tags: tags
    num: 2

    // dependent resources
    applicationInsightsId: applicationInsights.outputs.applicationInsightsId
    containerRegistryId: containerRegistry.outputs.containerRegistryId
    keyVaultId: keyvault.outputs.keyvaultId
    storageAccountId: storage.outputs.storageId
    storageAccountName: storage.outputs.storageAccountName
    containerName: storage.outputs.containerName
    environmentObject: storage.outputs.environmentObject

    // compute
    amlComputePublicIp: amlComputePublicIp
    vmSizeParam: amlComputeDefaultVmSize
  }
}

module machineLearningRegistry 'modules/machineLearningRegistry.bicep' = {
  name: 'mlr-${name}-${uniqueSuffix}-deployment'
  params: {
    location: location
    tags: tags
    registryName: 'mlr-${name}-${uniqueSuffix}'
    storageAccountType: 'Standard_LRS'
  }
}
