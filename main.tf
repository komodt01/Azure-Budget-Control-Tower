# Azure Budget Control Tower - Simplified Working Version
# This creates the core budget functionality without complex features

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Get current subscription details
data "azurerm_subscription" "current" {}

# Resource Group for budget resources
resource "azurerm_resource_group" "budget_rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Production"
    Purpose     = "Budget Management"
    Project     = "Azure Budget Control Tower"
  }
}

# Action Group for email notifications
resource "azurerm_monitor_action_group" "budget_alerts" {
  name                = var.action_group_name
  resource_group_name = azurerm_resource_group.budget_rg.name
  short_name          = var.action_group_short_name

  email_receiver {
    name          = "FinOps Team"
    email_address = var.alert_email
  }

  tags = {
    Environment = "Production"
    Purpose     = "Budget Alerts"
  }
}

# The main budget with alerts
resource "azurerm_consumption_budget_subscription" "main_budget" {
  name            = var.budget_name
  subscription_id = data.azurerm_subscription.current.id
  amount          = var.budget_amount
  time_grain      = "Monthly"

  time_period {
    start_date = var.budget_start_date
  }

  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = [var.alert_email]
    contact_groups = [azurerm_monitor_action_group.budget_alerts.id]
  }

  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = [var.alert_email]
    contact_groups = [azurerm_monitor_action_group.budget_alerts.id]
  }
}