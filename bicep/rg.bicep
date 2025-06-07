targetScope = 'subscription'

// @description('Name of the resource group.')
param rgName string = 'newrg03100915'

// @description('Azure region for the resource group to create in.')
param rgLocation string = deployment().location

resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: rgName
  location: rgLocation
}

// module stg './storage.bicep' = {
//   name: 'storageDeployment'
//   params: {storageAccountName:'azstcon'}
// }

// param location string = resourceGroup().location

// var virtualNetworkName = 'my-vnet'
// var subnet1Name = 'Subnet-1'
// var subnet2Name = 'Subnet-2'

// resource virtualNetwork 'Microsoft.Network/virtualNetworks@2024-01-01' = {
//   name: virtualNetworkName
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         '10.0.0.0/16'
//       ]
//     }
//     subnets: [
//       {
//         name: subnet1Name
//         properties: {
//           addressPrefix: '10.0.0.0/24'
//         }
//       }
//       {
//         name: subnet2Name
//         properties: {
//           addressPrefix: '10.0.1.0/24'
//         }
//       }
//     ]
//   }
// }

// resource subnet1 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
//   name: subnet1Name
// }

// resource subnet2 'Microsoft.Network/virtualNetworks/subnets@2024-01-01' = {
//   name: subnet2Name
// }

// output subnet1ResourceId string = virtualNetwork::subnet1.id
// output subnet2ResourceId string = virtualNetwork::subnet2.id
