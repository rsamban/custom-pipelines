#!/bin/bash
TERRAFORM_STORAGE_NAME=moltfstate
TERRAFORM_STORAGE_RG=mol-terraform-state-rg
AZURE_LOCATION=westus






# Create resource group if needed - for storage account to store terrraform state
if [[ -z $(az group list | jq --arg rg "$TERRAFORM_STORAGE_RG" '.[] | select(.name == $rg) | .name' | tr -d '"') ]]; then
  az group create -n "$TERRAFORM_STORAGE_RG" -l "$AZURE_LOCATION"
fi
if [[ -z $(az storage account show -n$TERRAFORM_STORAGE_NAME -g $TERRAFORM_STORAGE_RG | jq '.name' | tr -d '"') ]]; then
  echo "Creating $TERRAFORM_STORAGE_NAME in resource group $TERRAFORM_STORAGE_RG"
  az storage account create -n "$TERRAFORM_STORAGE_NAME" -g "$TERRAFORM_STORAGE_RG" --sku Standard_LRS --kind Storage -l "$AZURE_LOCATION"
  TERRAFORM_STORAGE_CONNECTION_STRING=$(az storage account show-connection-string -g $TERRAFORM_STORAGE_RG -n $TERRAFORM_STORAGE_NAME | jq .connectionString | tr -d '"')
  az storage container create -n tfstate --connection-string "$TERRAFORM_STORAGE_CONNECTION_STRING"
fi
