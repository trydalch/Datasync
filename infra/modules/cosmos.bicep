targetScope = 'resourceGroup'

@minLength(1)
@description('The name of the test container to create')
param containerName string = 'Movies'

@minLength(1)
@description('The name of the test database to create')
param databaseName string = 'unittests'

@minLength(1)
@description('Primary location for all resources')
param location string = resourceGroup().location

@description('The name of the SQL Server to create.')
param serverName string

@description('The list of tags to apply to all resources.')
param tags object = {}

/*********************************************************************************/

resource cosmos_account 'Microsoft.DocumentDB/databaseAccounts@2024-02-15-preview' = {
  name: serverName
  location: location
  tags: tags
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    databaseAccountOfferType: 'Standard'
    enableAutomaticFailover: false
    disableKeyBasedMetadataWriteAccess: true
  }
}

resource cosmos_database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-02-15-preview' = {
  name: databaseName
  parent: cosmos_account
  properties: {
    resource: {
      id: databaseName
    }
  }
}

resource cosmos_container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  name: containerName
  parent: cosmos_database
  properties: {
    resource: {
      id: containerName
      partitionKey: {
        paths: ['/id']
        kind: 'Hash'
      }
      indexingPolicy: {
        indexingMode: 'consistent'
        includedPaths: [
          { path: '/*' }
        ]
        excludedPaths: [
          { path: '/_etag/?' }
        ]
        compositeIndexes: [
          [
            { path: '/UpdatedAt', order: 'ascending' }
            { path: '/Id', order: 'ascending' }
          ]
        ]
      }
      defaultTtl: 86400
    }
    options: {
      throughput: 400
    }
  }
}

/*********************************************************************************/

#disable-next-line outputs-should-not-contain-secrets
output COSMOS_CONNECTIONSTRING string = cosmos_account.listConnectionStrings().connectionStrings[0].connectionString
