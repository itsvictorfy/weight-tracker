# Terraform README

This README provides an overview of the Terraform configuration that deploys infrastructure resources on Microsoft Azure. The Terraform script creates a Virtual Network (VNet) with two subnets, provisions two virtual machines (VMs), and sets up Network Security Groups (NSGs) for inbound traffic rules.

## Terraform Configuration

The Terraform configuration is defined in the `main.tf` file. The configuration sets up the following resources:

1. Azure Provider Configuration:
   - The required `azurerm` provider is configured with the specified version (3.0.0).

2. Data Sources:
   - The script uses data sources to query existing Azure resources. In this case, it fetches information from an existing Azure Key Vault (`testkv123`) to retrieve SSH credentials.

3. Resource Group:
   - Creates an Azure Resource Group to logically group all the resources.

4. Virtual Network (VNet) and Subnets:
   - Creates a VNet with two subnets (`web-subnet` and `db-subnet`) to segregate the resources.

5. Network Security Groups (NSGs):
   - Creates two NSGs (`web-nsg` and `db-nsg`) with associated security rules to control inbound traffic.

6. Public IP Address:
   - Creates a static public IP address (`web-pub-ip`) for the web VM.

7. Network Interfaces:
   - Creates two network interfaces (`web-nic` and `db-nic`) with private IP addresses to attach to the respective VMs.

8. Virtual Machines:
   - Deploys two virtual machines (`web-vm` and `db-vm`) using the specified image and VM size. The VMs are provisioned with the necessary software and configurations using the `remote-exec` provisioner.

9. Storage Account:
   - Creates an Azure Storage Account (`sa-weighttracket-db`) to store data disks for the database VM.

10. Managed Disk:
    - Creates an Azure Managed Disk (`db-volume`) to attach as a data disk to the database VM.

## Usage

1. Install Terraform and Azure CLI on your local machine.
2. Clone the repository or download the `main.tf` file.
3. Initialize the Terraform configuration:

```bash
terraform init
```

4. Review the execution plan:

```bash
terraform plan
```

5. Apply the Terraform configuration:

```bash
terraform apply
```

**Note:** The above Terraform script is just an example, and you should customize it according to your specific requirements. Be cautious when running the `terraform apply` command, as it will create resources in your Azure subscription.

## Clean Up

To destroy the resources and clean up the environment:

```bash
terraform destroy
```
