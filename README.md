# Azure NAT Gateway Egress Baseline for Private VM

## 1. Title & Project Overview
This Terraform project provisions a secure outbound internet architecture for an Azure Linux virtual machine by using an Azure NAT Gateway as the explicit Source NAT (SNAT) path.

This implementation is crucial because Microsoft retired implicit/default internet access for Azure Virtual Machines on **March 31, 2026**. After this platform change, outbound access must be intentionally designed. This codebase addresses that requirement by attaching a private subnet to a NAT Gateway backed by a Standard static public IP, while keeping the VM itself private.

## 2. Architecture Highlights
This deployment creates the following Azure resources and relationships:

- Resource Group for all workload resources.
- Virtual Network and internal subnet for private workload placement.
- Standard Static Public IP pinned to **Availability Zone 1**.
- NAT Gateway pinned to **Availability Zone 1**.
- Public IP association to the NAT Gateway.
- Subnet association to the NAT Gateway for subnet-level outbound SNAT.
- Private Ubuntu Linux VM with a NIC that has **no public IP** attached.

## 3. Repository Structure
```text
.
├── main.tf
├── vm.tf
├── variables.tf
└── prod.tfvars
```

## 4. Prerequisites
Before running this project, ensure you have:

- Azure CLI installed and authenticated (`az login` completed).
- Terraform CLI **v1.5+**.
- An active Azure Subscription with permissions to create resource groups, networking resources, public IP, NAT Gateway, NIC, and Linux VM.

## 5. Deployment Guide
Run these commands from the repository root:

```bash
terraform init
```

```bash
terraform plan -var-file="prod.tfvars"
```

```bash
terraform apply -var-file="prod.tfvars"
```

`admin_password` is declared as a sensitive variable, so Terraform will prompt for it at runtime unless provided through a secure variable injection method.

## 6. Verification Step
Validate that outbound traffic uses the NAT Gateway public IP:

1. Open the Azure Portal.
2. Navigate to the deployed Linux VM.
3. Select **Run command**.
4. Execute:

```bash
curl -s ipinfo.io
```

5. Compare the returned `ip` value with the Public IP resource attached to the NAT Gateway.

Expected result: the VM reports the same public IP as the NAT Gateway public IP resource, confirming outbound traffic is egressing through explicit NAT Gateway SNAT.
