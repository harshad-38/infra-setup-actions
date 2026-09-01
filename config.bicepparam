using './main.bicep'

param amlComputeDefaultVmSize = 'Standard_D2s_v3'
param amlComputePublicIp = false
param prefix = 'mlops'

param tags = {
  environment: 'devlopment'
  project: 'mlops'
}

