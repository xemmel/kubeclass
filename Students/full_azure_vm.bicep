param appName string
param location string = resourceGroup().location

param ipAddMask string = '10.77'
param clientIp string
param userName string = 'kubeAdmin'
param password string

//Nsg
resource nsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: 'nsg-${appName}'
  location: location 
  properties: {
    securityRules: [
      {
        name: 'RDP'
        properties: {
          protocol: 'TCP'
          priority: 1000
          direction: 'Inbound'
          access: 'Allow'
          sourcePortRange: '*'
          sourceAddressPrefix: clientIp
          destinationPortRange: '3389'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

//Vnet
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: 'vnet-${appName}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '${ipAddMask}.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'vm'
        properties: {
          addressPrefix: '${ipAddMask}.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
    ]
  }
}

//Public IP Address
resource pip 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: 'pip-${appName}'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

//NIC
resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: 'nic-${appName}'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: vnet.properties.subnets[0].id
          }
        }
      }
    ]
  }
}


//VM

resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: 'vm${appName}'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D4s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftwindowsdesktop'
        offer: 'windows-11'
        sku: 'win11-24h2-pron'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: 'disk-${appName}'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 127
      }
    }
    osProfile: {
      computerName: 'vm${appName}'
      adminUsername: userName
      adminPassword: password

    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    licenseType: 'Windows_Client'
  }
}

output ip string = pip.properties.ipAddress
