// Copyright (c) 2019, 2020, Oracle Corporation and/or its affiliates.
// Licensed under the Universal Permissive License v 1.0 as shown at https://oss.oracle.com/licenses/upl.

param _artifactsLocation string
@secure()
param _artifactsLocationSasToken string = ''

param appgwAlias string = 'appgw-contoso-alias'
param appgwName string = 'appgw-contoso'
@allowed([
  'haveCert'
  'haveKeyVault'
  'generateCert'
])
@description('Three scenarios we support for deploying app gateway')
param appgwCertificateOption string = 'haveCert'
param appgwForAdminServer bool = true
@secure()
param appgwFrontendSSLCertData string = newGuid()
@secure()
param appgwFrontendSSLCertPsw string = newGuid()
param aksClusterRGName string = 'aks-contoso-rg'
param aksClusterName string = 'aks-contoso'
param dnszoneAdminConsoleLabel string = 'admin'
param dnszoneAppGatewayLabel string = 'www'
param dnszoneName string = 'contoso.xyz'
param dnszoneRGName string = 'dns-contoso-rg'
param enableAppGWIngress bool = false
param enableCookieBasedAffinity bool = false
param enableCustomSSL bool = false
param enableDNSConfiguration bool = false
param identity object
param lbSvcValues array = []
param location string = 'eastus'
@secure()
param servicePrincipal string = newGuid()
param useInternalLB bool = false
param utcValue string = utcNow()
param vnetName string = 'vnet-contoso'
param wlsDomainName string = 'domain1' 
param wlsDomainUID string = 'sample-domain1'

var const_appgwHelmConfigTemplate='appgw-helm-config.yaml.template'
var const_appgwSARoleBindingFile='appgw-ingress-clusterAdmin-roleBinding.yaml'
var const_arguments = '${aksClusterRGName} ${aksClusterName} ${wlsDomainName} ${wlsDomainUID} "${string(lbSvcValues)}" ${enableAppGWIngress} ${subscription().id} ${resourceGroup().name} ${appgwName} ${vnetName} ${string(servicePrincipal)} ${appgwForAdminServer} ${enableDNSConfiguration} ${dnszoneRGName} ${dnszoneName} ${dnszoneAdminConsoleLabel} ${dnszoneAppGatewayLabel} ${appgwAlias} ${useInternalLB} ${appgwFrontendSSLCertData} ${appgwFrontendSSLCertPsw} ${appgwCertificateOption} ${enableCustomSSL} ${enableCookieBasedAffinity}'
var const_commonScript = 'common.sh'
var const_scriptLocation = uri(_artifactsLocation, 'scripts/')
var const_primaryScript = 'setupNetworking.sh'

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ds-networking-deployment'
  location: location
  kind: 'AzureCLI'
  identity: identity
  properties: {
    azCliVersion: '2.15.0'
    arguments: const_arguments
    primaryScriptUri: uri(const_scriptLocation, '${const_primaryScript}${_artifactsLocationSasToken}')
    supportingScriptUris: [
      uri(const_scriptLocation, '${const_appgwHelmConfigTemplate}${_artifactsLocationSasToken}')
      uri(const_scriptLocation, '${const_appgwSARoleBindingFile}${_artifactsLocationSasToken}')
      uri(const_scriptLocation, '${const_commonScript}${_artifactsLocationSasToken}')
    ]
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    forceUpdateTag: utcValue
  }
}

output adminConsoleLBUrl string = length(lbSvcValues) > 0 && (reference('ds-networking-deployment').outputs.adminConsoleEndpoint != 'null') ? format('http://{0}/',reference('ds-networking-deployment').outputs.adminConsoleEndpoint): ''
output clusterLBUrl string = length(lbSvcValues) > 0 && (reference('ds-networking-deployment').outputs.clusterEndpoint != 'null') ? format('http://{0}/',reference('ds-networking-deployment').outputs.clusterEndpoint): ''

