provider "azurerm" {
  features {}
}

# Define the resource group without configuring location or tags
data "azurerm_resource_group" "rc-gp" {
  name = "adria"
 
  
}