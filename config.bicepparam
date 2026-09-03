using './main.bicep'

param amlComputeDefaultVmSize = 'Standard_D2s_v3'
param amlComputePublicIp = true
param prefix = 'mlops'
param location = 'centralindia'
param tags = {
  environment: 'devlopment'
  project: 'mlops'
}

