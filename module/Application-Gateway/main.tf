# Data Sources


data "azurerm_subnet" "appgw_subnet" {
  for_each = var.APGws
  name                 = each.value.subnet_name
  virtual_network_name = each.value.virtual_network_name
  resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "appgw_pip" {
  for_each = var.APGws
  name                = each.value.public_ip_name
  resource_group_name = each.value.resource_group_name
}


# Azure Application Gateway

resource "azurerm_application_gateway" "appgw" {

  for_each = var.APGws
  name                = each.value.appgw_name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  sku {
    name     = each.value.sku_name
    tier     = each.value.sku_tier
    capacity = each.value.capacity
  }
  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = data.azurerm_subnet.appgw_subnet[each.key].id
  }
  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = data.azurerm_public_ip.appgw_pip[each.key].id
  }
  frontend_port {
    name = "http-port"
    port = each.value.frontend_port
  }

  # Backend Address Pools

backend_address_pool {
    name         = "frontend-backend-pool"
    ip_addresses = [each.value.frontend_private_ip]
}

backend_address_pool {
    name         = "backend-backend-pool"
    ip_addresses = [each.value.backend_private_ip]
}

backend_http_settings {
  name                  = "frontend-http-settings"
  cookie_based_affinity = "Disabled"
  path                  = "/"
  port                  = 80
  protocol              = "Http"
  request_timeout       = 30
  probe_name = "frontend-probe"
}

backend_http_settings {
  name                  = "backend-http-settings"
  cookie_based_affinity = "Disabled"
  path                  = "/"
  port                  = 5000
  protocol              = "Http"
  request_timeout       = 30
  probe_name = "backend-probe"
  
}

# Health Probe - Frontend

probe {
  name                                      = "frontend-probe"
  protocol                                  = "Http"
  host                                      = each.value.frontend_private_ip
  path                                      = "/"
  interval                                  = 30
  timeout                                   = 30
  unhealthy_threshold                       = 3
  pick_host_name_from_backend_http_settings = false

  match {
    status_code = ["200-399"]
  }
}

# Health Probe - Backend

probe {
  name                                      = "backend-probe"
  protocol                                  = "Http"
  host                                      = each.value.backend_private_ip
  path                                      = "/"
  interval                                  = 30
  timeout                                   = 30
  unhealthy_threshold                       = 3
  pick_host_name_from_backend_http_settings = false

  match {
    status_code = ["200-399"]
  }
}

# HTTP Listener

http_listener {
  name                           = "http-listener"
  frontend_ip_configuration_name = "frontend-ip-configuration"
  frontend_port_name             = "http-port"
  protocol                       = "Http"
}

# URL Path Map

url_path_map {
  name                               = "cineverse-path-map"
  default_backend_address_pool_name  = "frontend-backend-pool"
  default_backend_http_settings_name = "frontend-http-settings"

  path_rule {
    name                       = "api-path"
    paths                      = ["/api/*"]
    backend_address_pool_name  = "backend-backend-pool"
    backend_http_settings_name = "backend-http-settings"
  }
}

request_routing_rule {
  name               = "cineverse-routing-rule"
  priority           = 100
  rule_type          = "PathBasedRouting"
  http_listener_name = "http-listener"
  url_path_map_name  = "cineverse-path-map"
}

}

