# A sample IaC project with terraform 


Used Terraform for managing infrastructure on ArvanCloud. The goal is to automate the setup of virtual machines, security groups, volumes, and networks, along with the setup of a k8s cluster and deploylment of a Helm cahrt.


## Key Learnings

- Understanding Terraform configuration and syntax.
- Setting up and configuring the ArvanCloud provider.
- Creating and managing various resources like virtual machines, security groups, volumes, and networks.
- Utilizing data sources to gather information about existing resources.
- Using provisioners to automate post-provisioning tasks.

    ### Terraform Concepts
    - Providers
    - Variables
    - Local Values
    - Resources
    - Data Sources
    - Outputs
    - Provisioners


## Run 

### 1.Initialize:

```bash
terraform init
```

### 2. Create variable file
Create a variable file to put your API key there. 

[How to get API key](https://docs.arvancloud.ir/fa/developer-tools/api/api-key)

`terraform.tfvars`
```bash
arvan_api_key = "apikey XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"
```

### 3. Apply

```bash
terraform apply
```

---


Get list of available resources on ArvanCloud:

```bash
terraform refresh -var="out=true"
```
