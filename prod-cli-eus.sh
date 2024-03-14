#!/bin/bash

subscriptionId="aad26b95-4fc9-423c-8256-122695288dc3"   # Using GrafanaTest ¨C ChinaTestIntegration2 as default subscription
resourceGroup="amg-cli-test"
location="eastus"
CreateTimeForRG=$(date "+%Y%m%d%H%M")
CreateTimeForAMG=$(date "+%Y%m%d%H%M")

set -e

echo "Starting tests..."
SrcRoot="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )"
echo "SrcRoot $SrcRoot"

echo "Logging in to Azure with setting subscription"
az account set --subscription $subscriptionId

echo "Creating resource group $resourceGroup-$CreateTimeForRG"
az group create --location $location --name $"$resourceGroup-$CreateTimeForRG" --tags CreateAt=$CreateTimeForAMG Creator=UnitTest

echo "Installing amg az cli extension, if it had already been installed, will be skipped automatically"
az extension add --name amg

echo "Creating Grafana workspace: amg-cli-$CreateTimeForAMG"
az grafana create -g $"$resourceGroup-$CreateTimeForRG" -n "amg-cli-$CreateTimeForAMG" --location $location

echo "Check if Grafana workspace created Successfully via az grafana show"
az grafana show -n "amg-cli-$CreateTimeForAMG" > clitest-localfile.txt

if grep -q '"provisioningState": "Succeeded"' clitest-localfile.txt
then 
    echo "Grafana workspace successfully created"
 else [ $exit_code -ne 0 ];
    echo "Grafana workspace created failed"
    exit $exit_code
fi

echo "Check if Grafana workspace created Successfully via az grafana list"
az grafana list -g $"$resourceGroup-$CreateTimeForRG" > clitest-localfile.txt

if grep -q "amg-cli-$CreateTimeForAMG" clitest-localfile.txt
then 
    echo "Grafana workspace successfully created"
 else [ $exit_code -ne 0 ];
    echo "Grafana workspace created failed"
    exit $exit_code
fi

echo "Enable API key, deterministic outbound ip and add tags for Grafana workspace"
az grafana update -n "amg-cli-$CreateTimeForAMG" --api-key enabled --tags CreateAt=$CreateTimeForAMG Creator=UnitTest --deterministic-outbound-ip enabled

echo "Check if Grafana workspace updated Successfully"
az grafana show -n "amg-cli-$CreateTimeForAMG" > clitest-localfile.txt

if grep -q '"apiKey": "Enabled"' clitest-localfile.txt
then 
    echo "API Key enabled successfully"
else [ $exit_code -ne 0 ];
    echo "Grafana workspace upated failed"
    exit $exit_code
fi
if grep -q '"deterministicOutboundIp": "Enabled"' clitest-localfile.txt
then
    echo "Dterministic Outbound IP enabled successfully"
 else [ $exit_code -ne 0 ];
    echo "Grafana workspace upated failed"
    exit $exit_code
fi

echo "Delete workspace"
az grafana delete -n "amg-cli-$CreateTimeForAMG" --yes

echo "Delete resource group"
az group delete --name $"$resourceGroup-$CreateTimeForRG"

if [ $exit_code -ne 0 ]; then
    echo "Failed to test"
    exit $exit_code
fi

echo "Successfully finished testing!"
echo "**********[Liftr]**********[https://aka.ms/liftr]**********[Liftr]**********[https://aka.ms/liftr]**********"