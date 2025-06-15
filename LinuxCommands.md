# Linux Commands Reference - Azure Budget Control Tower

This document contains all Linux/WSL commands used during the development and deployment of the Azure Budget Control Tower project.

## 🚀 **Project Setup Commands**

### **Directory Navigation**
```bash
# Navigate to Windows directory from WSL
cd "/mnt/c/Users/k_omo/Documents/GitHub_New/Azure Budget Control Tower"

# Alternative navigation with tab completion
cd /mnt/c/Users/k_omo/Documents/GitHub_New/
# Press Tab to auto-complete folder name

# Check current directory
pwd

# List files in directory
ls -la
ls *.tf*
```

### **File Management**
```bash
# Create backup files
cp main.tf main.tf.backup
cp main.tf main.tf.complex.backup
cp variables.tf variables.tf.complex.backup
cp terraform.tfvars terraform.tfvars.complex.backup

# Copy files
cp -r /mnt/c/Users/k_omo/Documents/GitHub_New/"Azure Budget Control Tower" ./azure-budget-control-tower

# Set proper file permissions
chmod 644 *.tf *.md *.tfvars
chmod 755 .

# View file contents
cat terraform.tfvars
cat main.tf
```

## 🔧 **Software Installation & Updates**

### **Terraform Installation Check & Update**
```bash
# Check if Terraform is installed
terraform version
which terraform

# Update Terraform via package manager
sudo apt update
sudo apt upgrade terraform

# Manual Terraform installation
wget https://releases.hashicorp.com/terraform/1.7.5/terraform_1.7.5_linux_amd64.zip
unzip terraform_1.7.5_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.7.5_linux_amd64.zip

# Install using snap
sudo snap install terraform

# Verify installation
terraform version
```

### **Azure CLI Commands**
```bash
# Login to Azure
az login

# List available subscriptions
az account list --output table
az account list --query "[].{Name:name, ID:id}" --output table

# Set active subscription
az account set --subscription "7d939770-deef-433d-9283-5bd5eb79aeaf"
az account set --subscription "Your Subscription Name"

# Verify current subscription
az account show
az account show --output table

# Get current subscription details
az account show --query id -o tsv
```

## 🏗️ **Terraform Workflow Commands**

### **Basic Terraform Operations**
```bash
# Initialize Terraform
terraform init

# Validate configuration syntax
terraform validate

# Plan deployment (dry run)
terraform plan -var-file="terraform.tfvars"

# Apply changes
terraform apply -var-file="terraform.tfvars"

# Destroy infrastructure
terraform destroy -var-file="terraform.tfvars"

# Show current state
terraform show

# List resources in state
terraform state list
```

### **Targeted Terraform Operations**
```bash
# Plan specific resource
terraform plan -target=azurerm_resource_group.budget_rg
terraform plan -target=azurerm_monitor_action_group.budget_alerts
terraform plan -target=azurerm_consumption_budget_subscription.main_budget

# Apply specific resource
terraform apply -target=azurerm_resource_group.budget_rg

# Destroy specific resource
terraform destroy -target=azurerm_consumption_budget_subscription.main_budget
```

### **Terraform Debugging**
```bash
# Check provider versions
terraform version
terraform providers schema -json | jq '.provider_schemas'

# Detailed output
terraform plan -var-file="terraform.tfvars" -detailed-exitcode

# Validate without init
terraform validate -json
```

## ✏️ **File Editing Commands**

### **Using nano Editor**
```bash
# Edit files with nano
nano terraform.tfvars
nano main.tf
nano variables.tf

# Nano keyboard shortcuts:
# Ctrl+X - Exit
# Ctrl+O - Save (Write Out)
# Ctrl+K - Cut line
# Ctrl+U - Paste
# Ctrl+W - Search
```

### **Using VS Code**
```bash
# Open file in VS Code
code terraform.tfvars
code main.tf
code .  # Open entire directory
```

### **Using sed for Quick Edits**
```bash
# Find and replace in files
sed -i 's/tags = var.common_tags/# Note: tags not supported on consumption budgets/' main.tf

# Remove specific lines
sed -i '/tags = var.common_tags/d' main.tf

# Add line after pattern
sed -i '/resource_group_name/a budget_amount = 1' terraform.tfvars
```

## 🔍 **Troubleshooting Commands**

### **Azure Resource Verification**
```bash
# List budgets
az consumption budget list --subscription-id $(az account show --query id -o tsv)

# List resource groups
az group list --output table

# Check specific resource group
az group show --name "rg-budget-control-tower"

# List action groups
az monitor action-group list --resource-group "rg-budget-control-tower"

# Show action group details
az monitor action-group show --resource-group "rg-budget-control-tower" --name "budget-alerts"
```

### **System Information**
```bash
# Check WSL version
wsl --version
lsb_release -a

# Check available disk space
df -h

# Check memory usage
free -h

# Check running processes
ps aux | grep terraform
```

### **Network & Connectivity**
```bash
# Test internet connectivity
ping 8.8.8.8
curl -I https://management.azure.com/

# Check DNS resolution
nslookup management.azure.com
```

## 🧹 **Cleanup Commands**

### **File Cleanup**
```bash
# Remove backup files
rm *.backup
rm terraform_*.zip

# Clean Terraform files
rm -rf .terraform/
rm terraform.tfstate*
rm .terraform.lock.hcl

# Remove temporary files
rm -f *.tmp
find . -name "*.tmp" -delete
```

### **Azure Resource Cleanup**
```bash
# Delete specific budget
az consumption budget delete \
  --subscription-id $(az account show --query id -o tsv) \
  --budget-name "monthly-subscription-budget"

# Delete action group
az monitor action-group delete \
  --resource-group "rg-budget-control-tower" \
  --name "budget-alerts"

# Delete resource group (and all contained resources)
az group delete --name "rg-budget-control-tower" --yes

# Verify cleanup
az group list --output table
az consumption budget list --subscription-id $(az account show --query id -o tsv)
```

## 📋 **Project Verification Commands**

### **Pre-Deployment Checks**
```bash
# Verify file structure
tree .
ls -la *.tf *.md

# Check Terraform syntax
terraform fmt -check
terraform validate

# Verify Azure authentication
az account show
az account list-locations --output table
```

### **Post-Deployment Verification**
```bash
# Check created resources
terraform state list
terraform show

# Verify in Azure Portal via CLI
az group show --name "rg-budget-control-tower"
az consumption budget show \
  --subscription-id $(az account show --query id -o tsv) \
  --budget-name "monthly-subscription-budget"
```

## 📊 **Monitoring Commands**

### **Real-time Monitoring**
```bash
# Watch Terraform apply in real-time
terraform apply -var-file="terraform.tfvars" | tee deployment.log

# Monitor Azure activity
az monitor activity-log list --max-events 10 --output table

# Check cost information
az consumption usage list --top 5
```

### **Log Analysis**
```bash
# Search logs for errors
grep -i error *.log
grep -i "failed" deployment.log

# View last few lines of log
tail -f deployment.log

# Search for specific patterns
grep -n "budget" main.tf
grep -r "consumption" .
```

## 🔐 **Security Commands**

### **Permission Management**
```bash
# Check current user permissions
whoami
groups

# Set secure file permissions
chmod 600 terraform.tfstate
chmod 644 *.tf
chmod 755 *.sh

# Check file permissions
ls -la
stat terraform.tfvars
```

### **Azure Security**
```bash
# Check current Azure user
az account show --query user.name

# List role assignments
az role assignment list --assignee $(az account show --query user.name -o tsv)

# Check subscription permissions
az role assignment list --scope "/subscriptions/$(az account show --query id -o tsv)"
```

## 🎯 **Performance & Optimization**

### **Performance Monitoring**
```bash
# Time command execution
time terraform plan -var-file="terraform.tfvars"

# Monitor system resources during deployment
htop  # if installed
top

# Check disk I/O
iostat  # if installed
```

### **Optimization Commands**
```bash
# Clean Terraform cache
terraform init -upgrade

# Parallel operations (use with caution)
terraform apply -parallelism=10

# Reduced output
terraform apply -var-file="terraform.tfvars" -auto-approve
```

---

## 📝 **Command Summary by Phase**

### **Setup Phase**
```bash
cd "/mnt/c/Users/k_omo/Documents/GitHub_New/Azure Budget Control Tower"
terraform version
az login
az account set --subscription "7d939770-deef-433d-9283-5bd5eb79aeaf"
```

### **Development Phase**
```bash
terraform init
nano terraform.tfvars
terraform validate
terraform plan -var-file="terraform.tfvars"
```

### **Deployment Phase**
```bash
terraform apply -var-file="terraform.tfvars"
# Type 'yes' when prompted
```

### **Verification Phase**
```bash
az group show --name "rg-budget-control-tower"
terraform state list
```

### **Cleanup Phase**
```bash
terraform destroy -var-file="terraform.tfvars"
# Type 'yes' when prompted
```

These commands provide a complete reference for reproducing the Azure Budget Control Tower deployment and management workflow.