// Creates compute resources in the specified machine learning workspace
// Includes Compute Instance, Compute Cluster and attached Azure Kubernetes Service compute types
@description('Prefix for resource names')
param prefix string

@description('Azure Machine Learning workspace to create the compute resources in')
param machineLearning string

@description('Azure region of the deployment')
param location string

@description('To provide unique names to compute resources in different workspaces')
param num int

@description('Tags to add to the resources')
param tags object

@description('Resource ID of the Azure Kubernetes services resource')
param amlComputePublicIp bool

@description('VM size for the default compute cluster')
param vmSizeParam string

resource machineLearningCluster001 'Microsoft.MachineLearningServices/workspaces/computes@2022-05-01' = {
  name: '${machineLearning}/cluster${num}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'AmlCompute'
    computeLocation: location
    description: 'Machine Learning cluster 001'
    disableLocalAuth: true
    properties: {
      vmPriority: 'Dedicated'
      vmSize: vmSizeParam
      enableNodePublicIp: amlComputePublicIp 
      isolatedNetwork: false
      osType: 'Linux'
      remoteLoginPortPublicAccess: 'Disabled'
      scaleSettings: {
        minNodeCount: 0
        maxNodeCount: 5
        nodeIdleTimeBeforeScaleDown: 'PT120S'
      }
    }
  }
}

resource machineLearningComputeInstance001 'Microsoft.MachineLearningServices/workspaces/computes@2022-05-01' = {
  name: '${machineLearning}/${prefix}-ci00${num}'
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    computeType: 'ComputeInstance'
    computeLocation: location
    description: 'Machine Learning compute instance 002'
    disableLocalAuth: true
    properties: {
      applicationSharingPolicy: 'Personal'
      
      computeInstanceAuthorizationType: 'personal'
      
      sshSettings: {
        sshPublicAccess: 'Disabled'
      }
      vmSize: vmSizeParam
    }
  }
}

module roleAssignmentsComputeCluster 'roleAssignments.bicep' = {
  name: '${machineLearning}RoleCluster'
  scope: resourceGroup()
  params: {
    principalID: machineLearningCluster001.identity.principalId
    roleDefinitionID: ['acdd72a7-3385-48ef-bd42-f606fba81ae7', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe','7f951dda-4ed3-4680-a7ca-43fe172d538d','4633458b-17de-408a-b874-0445c86b69e6']
  }
}

module roleAssignmentsComputeInstance 'roleAssignments.bicep' = {
  name: '${machineLearning}Instance'
  scope: resourceGroup()
  params: {
    principalID: machineLearningComputeInstance001.identity.principalId
    roleDefinitionID: ['acdd72a7-3385-48ef-bd42-f606fba81ae7', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe','7f951dda-4ed3-4680-a7ca-43fe172d538d','4633458b-17de-408a-b874-0445c86b69e6']
  }
}

output clusterIdentity string = machineLearningCluster001.identity.principalId
output instanceIdentity string = machineLearningComputeInstance001.identity.principalId
