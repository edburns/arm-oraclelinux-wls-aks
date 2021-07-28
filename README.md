## WebLogic Server on Azure Kubenetes Service

### Prerequisites

- [Bicep](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)
- [azure-javaee-iaas](https://github.com/Azure/azure-javaee-iaas)

### Build 

Please build `azure-javaee-iaas` first.

Then run the following command to generate ARM package and upload to marketplace center.

```bash
$ mvn -Pbicep -Ddev -Passembly clean install
```

