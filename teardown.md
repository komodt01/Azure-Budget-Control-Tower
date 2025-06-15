# Azure Budget Management - Teardown Guide

This guide provides step-by-step instructions for safely removing the Azure Budget Management infrastructure.

## 🚨 Pre-Teardown Checklist

Before proceeding with teardown, ensure:

- [ ] **Export budget reports** and historical data if needed for auditing
- [ ] **Notify stakeholders** about the budget monitoring removal
- [ ] **Document current budget thresholds** for future reference
- [ ] **Verify no active Logic App workflows** are processing critical alerts
- [ ] **Backup Key Vault secrets** if they contain important automation credentials
- [ ] **Check for dependencies** - other systems relying on action groups or Logic Apps

## 📋 Teardown Order

### Phase 1: Disable Notifications
```bash
# Stop budget notifications to prevent alerts during teardown
az consumption budget update \
  --subscription-id $(az account show --query id -o tsv) \
  --budget-name "monthly-subscription-budget" \
  --notifications '{}'
```

### Phase 2: Terraform Destroy
```bash
# Navigate to the azure directory
cd azure/

# Review what will be destroyed
terraform plan -destroy -var-file="terraform.tfvars"

# Confirm the destroy plan looks correct, then proceed
terraform destroy -var-file="terraform.tfvars"
```

### Phase 3: Manual Cleanup (if needed)

If Terraform destroy fails or leaves resources, manually clean up in this order:

#### 3.1 Budget Resources
```bash
# List all budgets
az consumption budget list --subscription-id $(az account show --query id -o tsv)

# Delete specific budget
az consumption budget delete \
  --subscription-id $(az account show --query id -o tsv) \
  --budget-name "monthly-subscription-budget"
```

#### 3.2 Logic Apps and Automation
```bash
# Delete Logic App
az logic workflow delete \
  --resource-group "rg-budget-management-prod" \
  --name "budget-automation-logic-app"
```

#### 3.3 Action Groups
```bash
# Delete Action Group
az monitor action-group delete \
  --resource-group "rg-budget-management-prod" \
  --name "budget-alert-action-group"
```

#### 3.4 Policy Assignments
```bash
# List policy assignments
az policy assignment list --query "[?displayName=='Budget Cost Control - Allowed VM SKUs']"

# Delete policy assignment
az policy assignment delete --name "budget-cost-control"
```

#### 3.5 Storage and Key Vault
```bash
# Delete Key Vault (soft delete enabled by default)
az keyvault delete \
  --name "budget-auto-kv-2025" \
  --resource-group "rg-budget-management-prod"

# Purge Key Vault (permanent deletion)
az keyvault purge --name "budget-auto-kv-2025"

# Delete Storage Account
az storage account delete \
  --name "budgetauto2025storage" \
  --resource-group "rg-budget-management-prod"
```

#### 3.6 Resource Group
```bash
# Delete the entire resource group (last step)
az group delete --name "rg-budget-management-prod" --yes
```

## 🔍 Verification Steps

After teardown, verify all resources are removed:

```bash
# Check for remaining budgets
az consumption budget list --subscription-id $(az account show --query id -o tsv)

# Check for remaining action groups
az monitor action-group list --resource-group "rg-budget-management-prod" 2>/dev/null

# Check for remaining Logic Apps
az logic workflow list --resource-group "rg-budget-management-prod" 2>/dev/null

# Verify resource group is deleted
az group show --name "rg-budget-management-prod" 2>/dev/null
```

## ⚠️ Common Issues and Solutions

### Issue: Budget Delete Permission Denied
**Solution:** Ensure you have `Microsoft.Consumption/budgets/delete` permission or `Owner`/`Contributor` role on the subscription.

### Issue: Key Vault Cannot Be Deleted
**Solution:** Key Vault has soft-delete protection. Use `az keyvault purge` after deletion to permanently remove.

### Issue: Policy Assignment Cannot Be Deleted
**Solution:** Check if policy assignment has system-assigned managed identity. Delete the identity first, then the policy.

### Issue: Storage Account Name Conflict
**Solution:** Storage account names are globally unique. If recreating, use a different name or wait 24 hours for the name to become available.

## 📊 Cost Impact Assessment

After teardown, expect these cost changes:
- **Budget alerts:** No direct cost (free service)
- **Action Groups:** Minimal cost savings (~$0.10/month per email)
- **Logic Apps:** Cost depends on executions (~$0.000025 per action)
- **Storage Account:** ~$0.05-$2/month depending on usage
- **Key Vault:** ~$0.03/month for standard tier

## 🔄 Re-deployment Notes

If you need to redeploy later:

1. **Update terraform.tfvars** with new globally unique names for:
   - Storage Account (`storage_account_name`)
   - Key Vault (`key_vault_name`)

2. **Consider date ranges** in budget configuration:
   - Update `budget_start_date` to current month
   - Adjust `budget_end_date` as needed

3. **Review email recipients** in case team members have changed

4. **Test notifications** after deployment with a small test budget

## 📞 Emergency Contacts

If issues arise during teardown:
- **Azure Support:** Create support ticket in Azure Portal
- **FinOps Team:** finops@company.com
- **IT Manager:** it-manager@company.com

## 📝 Documentation Updates

After successful teardown:
- [ ] Update infrastructure documentation
- [ ] Remove budget monitoring from operational runbooks
- [ ] Update team contact lists
- [ ] Archive Terraform state files securely