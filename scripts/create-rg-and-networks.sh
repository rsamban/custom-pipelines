#!/bin/bash
TERRAFORM_STORAGE_RG=mol-terraform-state-rg
AZURE_LOCATION=westus
# Create the resource groups - We expect the resource groups and vnets to be present with vpc peering with
# vnet in dmz.
AZURE_MULTI_RESGROUP_NETWORK=mol_pcf_nw_rg
AZURE_MULTI_RESGROUP_PCF=mol_pcf_rg
AZURE_MULTI_RESGROUP_INFRA_VNET_NAME=ra_multirg_vnet
AZURE_TERRAFORM_VNET_CIDR="192.168.0.0/20"
AZURE_TERRAFORM_SUBNET_INFRA_CIDR="192.168.0.0/26"
AZURE_TERRAFORM_SUBNET_INFRA_DNS="168.63.129.16,8.8.8.8"
AZURE_TERRAFORM_SUBNET_INFRA_GATEWAY="192.168.0.1"
AZURE_TERRAFORM_SUBNET_INFRA_RESERVED="192.168.0.1-192.168.0.9"
AZURE_TERRAFORM_SUBNET_ERT_CIDR="192.168.4.0/22"
AZURE_TERRAFORM_SUBNET_ERT_DNS="168.63.129.16,8.8.8.8"
AZURE_TERRAFORM_SUBNET_ERT_GATEWAY="192.168.4.1"
AZURE_TERRAFORM_SUBNET_ERT_RESERVED="192.168.4.1-192.168.4.9"
AZURE_TERRAFORM_SUBNET_SERVICES1_CIDR="192.168.8.0/22"
AZURE_TERRAFORM_SUBNET_SERVICES1_DNS="168.63.129.16,8.8.8.8"
AZURE_TERRAFORM_SUBNET_SERVICES1_GATEWAY="192.168.8.1"
AZURE_TERRAFORM_SUBNET_SERVICES1_RESERVED="192.168.8.1-192.168.8.9"
AZURE_TERRAFORM_SUBNET_DYNAMIC_SERVICES_CIDR="192.168.12.0/22"
AZURE_TERRAFORM_SUBNET_DYNAMIC_SERVICES_DNS="168.63.129.16,8.8.8.8"
AZURE_TERRAFORM_SUBNET_DYNAMIC_SERVICES_GATEWAY="192.168.12.1"
AZURE_TERRAFORM_SUBNET_DYNAMIC_SERVICES_RESERVED="192.168.12.1-192.168.12.9"

AZURE_MULTI_RESGROUP_INFRA_SUBNET_NAME=infra # already exists
AZURE_MULTI_RESGROUP_ERT_SUBNET_NAME=ert # new
AZURE_MULTI_RESGROUP_SERVICES1_SUBNET_NAME=services # new
AZURE_MULTI_RESGROUP_DYNAMIC_SERVICES_SUBNET_NAME=dynamic_services # new
AZURE_TERRAFORM_VNET_DNS="168.63.129.16 8.8.8.8" # new

# Create resource group if needed - redundant as resource groups are created in the create_sp_and_roles.sh script
if [[ -z $(az group list | jq --arg rg "$AZURE_MULTI_RESGROUP_NETWORK" '.[] | select(.name == $rg) | .name' | tr -d '"') ]]; then
  az group create -n "$AZURE_MULTI_RESGROUP_NETWORK" -l "$AZURE_LOCATION"
fi

# check if vnet exists, if not create. We expect vnet to exists because
if [[ -z $(az network vnet show -n $AZURE_MULTI_RESGROUP_INFRA_VNET_NAME -g $AZURE_MULTI_RESGROUP_NETWORK | jq '.name' | tr -d '"') ]]; then
  az network vnet create -n "$AZURE_MULTI_RESGROUP_INFRA_VNET_NAME" \
      --address-prefix "$AZURE_TERRAFORM_VNET_CIDR" \
      -g "$AZURE_MULTI_RESGROUP_NETWORK" \
      -l "$AZURE_LOCATION" \
      --dns-servers $AZURE_TERRAFORM_VNET_DNS
  az network vnet subnet create -n "$AZURE_MULTI_RESGROUP_INFRA_SUBNET_NAME" \
    -g "$AZURE_MULTI_RESGROUP_NETWORK" \
    --address-prefix "$AZURE_TERRAFORM_SUBNET_INFRA_CIDR" \
    --vnet-name "$AZURE_MULTI_RESGROUP_INFRA_VNET_NAME"
  az network vnet subnet create -n "$AZURE_MULTI_RESGROUP_ERT_SUBNET_NAME" \
    -g "$AZURE_MULTI_RESGROUP_NETWORK" \
    --address-prefix "$AZURE_TERRAFORM_SUBNET_ERT_CIDR" \
    --vnet-name "$AZURE_MULTI_RESGROUP_INFRA_VNET_NAME"
  az network vnet subnet create -n "$AZURE_MULTI_RESGROUP_SERVICES1_SUBNET_NAME" \
    -g "$AZURE_MULTI_RESGROUP_NETWORK" \
    --address-prefix "$AZURE_TERRAFORM_SUBNET_SERVICES1_CIDR" \
    --vnet-name "$AZURE_MULTI_RESGROUP_INFRA_VNET_NAME"
  az network vnet subnet create -n "$AZURE_MULTI_RESGROUP_DYNAMIC_SERVICES_SUBNET_NAME" \
    -g "$AZURE_MULTI_RESGROUP_NETWORK" \
    --address-prefix "$AZURE_TERRAFORM_SUBNET_DYNAMIC_SERVICES_CIDR" \
    --vnet-name "$AZURE_MULTI_RESGROUP_INFRA_VNET_NAME"
fi

# Create resource group if needed - redundant as resource groups are created in the create_sp_and_roles.sh script
if [[ -z $(az group list | jq --arg rg "$AZURE_MULTI_RESGROUP_NETWORK" '.[] | select(.name == $rg) | .name' | tr -d '"') ]]; then
  az group create -n "$AZURE_MULTI_RESGROUP_NETWORK" -l "$AZURE_LOCATION"
fi
