using './main.bicep'

param amlComputeDefaultVmSize = 'Standard_D2s_v3'
param amlComputePublicIp = true
param prefix = 'mlops'
param userObjectId = '64c2543c-e0ea-41dd-8222-4f693d1ade94'
param location = 'centralindia'
param tags = {
  environment: 'devlopment'
  project: 'mlops'
}

