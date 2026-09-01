@description('Azure region of the deployment')
param location string = resourceGroup().id

@description('Tags to add to the resources')
param tags object = {
  env: 'dev'
}

@description('Name of the storage account')
param storageName string = 'storageharshad'

@allowed([
  'Standard_LRS'
  'Standard_ZRS'
  'Standard_GRS'
  'Standard_GZRS'
  'Standard_RAGRS'
  'Standard_RAGZRS'
  'Premium_LRS'
  'Premium_ZRS'
])

@description('Storage SKU')
param storageSkuName string = 'Standard_LRS'

var storageNameCleaned = replace(storageName, '-', '')

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: storageNameCleaned
  location: location
  tags: tags
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    allowSharedKeyAccess: true
    encryption: {
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: false
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
    }
    isHnsEnabled: false
    isNfsV3Enabled: false
    networkAcls: {

      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }
    keyPolicy: {
      keyExpirationPeriodInDays: 7
    }
    largeFileSharesState: 'Disabled'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: 'Enabled'
  }
}

resource storageAccountBlobService 'Microsoft.Storage/storageAccounts/blobServices@2021-09-01' = {
  name: 'default'
  parent: storage

  properties: {
    changeFeed: {
      enabled: true
      retentionInDays: 1
    }
    containerDeleteRetentionPolicy:{
      allowPermanentDelete: false
      enabled: true
      days: 1
    }
    cors: {}
    deleteRetentionPolicy: {
      enabled: true
      allowPermanentDelete: false
      days: 2
    }
    isVersioningEnabled: true
    lastAccessTimeTrackingPolicy: {
      enable: true
      blobType: [
        'blockBlob'
      ]
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
    }
    restorePolicy: {
      enabled: true
      days: 1
    }
  }
}


resource storageAccountBlobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-09-01' = {
  name: 'datacontainer'
  parent: storageAccountBlobService
  properties: {
    publicAccess: 'None'
  }
}

output storageId string = storage.id
output storageAccountName string = storage.name
output containerName string = storageAccountBlobContainer.name
output environmentObject object = environment()

@secure()
output storageAccountKey string = base64(storage.listKeys().keys[0].value)
