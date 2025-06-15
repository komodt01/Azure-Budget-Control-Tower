# Simplified Variables for Azure Budget Control Tower

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-budget-control-tower"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "East US"
}

variable "budget_name" {
  description = "Name of the budget"
  type        = string
  default     = "monthly-subscription-budget"
}

variable "budget_amount" {
  description = "Budget amount in USD"
  type        = number
  default     = 1000
}

variable "budget_start_date" {
  description = "Budget start date (YYYY-MM-DD)"
  type        = string
  default     = "2025-06-01"
}

variable "action_group_name" {
  description = "Action group name"
  type        = string
  default     = "budget-alerts"
}

variable "action_group_short_name" {
  description = "Action group short name (max 12 chars)"
  type        = string
  default     = "budgetalert"
}

variable "alert_email" {
  description = "Email address for budget alerts"
  type        = string
  default     = "your-email@company.com"
}