provider "azurerm" {
  version = "=1.28.0"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  subscription_id = "${var.subscription_id}"
  tenant_id = "${var.tenant_id}"
}

locals {
  server_name = "mysql-${var.sandbox_id}"
}

resource "azurerm_resource_group" "default" {
  name     = "mysql-${var.sandbox_id}-rg"
  location = "West US"
}

resource "azurerm_mysql_server" "default" {
  name                = "${local.server_name}"
  location            = "${azurerm_resource_group.default.location}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  administrator_login          = "${var.username}"
  administrator_login_password = "${var.password}"
  version                      = "5.7"
  ssl_enforcement              = "Enabled"

  sku {
    name     = "GP_Gen5_2"
    capacity = 2
    tier     = "GeneralPurpose"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    geo_redundant_backup  = "Disabled"
  }
}

resource "azurerm_mysql_database" "default" {
  name                = "${var.db_name}"
  resource_group_name = "${azurerm_resource_group.default.name}"
  server_name         = "${azurerm_mysql_server.default.name}"
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

data "azurerm_subnet" "default" {
  name                 = "app_subnet"
  virtual_network_name = "${var.virtual_network_name}"
  resource_group_name  = "${var.resource_group_name}"
}

resource "azurerm_mysql_virtual_network_rule" "default" {
  name                = "mysql-${var.sandbox_id}-vnet-rule"
  resource_group_name = "${azurerm_resource_group.default.name}"
  server_name         = "${azurerm_mysql_server.default.name}"
  subnet_id           = "${data.azurerm_subnet.default.id}"
}