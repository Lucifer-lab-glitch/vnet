
# The name of your virtual network
# You can choose any name for your VNet. It doesn't have to match an existing resource.
vnet_name = "my-vnet"

# Azure region where the resources will be deployed
# Example: "eastus", "westus2", "centralus", etc.
location = "eastus"

# The name of the resource group where the VNet will be deployed
# Resource groups can be viewed in the Azure Portal under "Resource Groups".
resource_group_name = "my-resource-group"

# The address space (CIDR blocks) to associate with your VNet
# This can be any valid CIDR block (e.g., "10.0.0.0/16"). Choose a range that doesn’t overlap with other VNets.
address_space = ["10.0.0.0/16"]

# DNS servers for the VNet
# Use public DNS servers like "8.8.8.8" (Google) or your own DNS servers if applicable.
dns_servers = ["8.8.8.8"]

# Tags to apply to all resources
# Tags help you organize resources. Common examples are "environment = dev", "owner = team-name".
tags = {
  environment = "dev"
}

# Subnet definitions
# For each subnet, you’ll need the following:
# - `address_prefixes`: The CIDR blocks for the subnet (e.g., "10.0.1.0/24").
# - `nsg_id`: The full resource ID of the Network Security Group (NSG) you want to associate. 
#   You can find this in the Azure Portal by navigating to the NSG, selecting “Properties,” and copying the “Resource ID”.
# - `route_table_id`: The full resource ID of the route table you want to associate.
#   This can be found in the Azure Portal by navigating to the route table, selecting “Properties,” and copying the “Resource ID”.
# - `service_endpoints`: (Optional) Any Azure service endpoints you want to enable (e.g., ["Microsoft.Sql"]).
subnets = {
  "subnet1" = {
    address_prefixes = ["10.0.1.0/24"]
    nsg_id = "/subscriptions/87c9cdc0-75e2-4e53-b528-673f2cedc16f/resourceGroups/your-resource-group/providers/Microsoft.Network/networkSecurityGroups/nsg1"
    route_table_id = "/subscriptions/87c9cdc0-75e2-4e53-b528-673f2cedc16f/resourceGroups/your-resource-group/providers/Microsoft.Network/routeTables/rt1"
    service_endpoints = ["Microsoft.Sql"]
  },
  "subnet2" = {
    address_prefixes = ["10.0.2.0/24"]
    # If no NSG or route table is needed, leave these null or remove them
    nsg_id = null
    route_table_id = null
    service_endpoints = []
  }
}

# VNet peering definitions
# For each peering, you’ll need:
# - `remote_vnet_id`: The full resource ID of the remote VNet.
#   In the Azure Portal, navigate to the remote VNet, select “Properties,” and copy the “Resource ID”.
# - The other boolean values depend on how you want the VNet to interact with the remote VNet.
peerings = {
  "peer1" = {
    remote_vnet_id = "/subscriptions/87c9cdc0-75e2-4e53-b528-673f2cedc16f/resourceGroups/remote-rg/providers/Microsoft.Network/virtualNetworks/remote-vnet"
    allow_vnet_access = true
    allow_forwarded_traffic = true
    allow_gateway_transit = false
    use_remote_gateways = false
  }
}

# Route tables
# Define each route table. Each entry needs:
# - `next_hop_ip`: The IP address of the next hop (e.g., "192.168.1.1").
# To find this, check your network documentation or the configuration of your environment.
route_tables = {
  "rt1" = {
    next_hop_ip = "192.168.1.1"
  }
}

# Virtual Network Gateway Configuration
# You need the following:
# - `gateway_name`: The name of the virtual network gateway. Pick a descriptive name.
# - `gateway_type`: Either "Vpn" or "ExpressRoute".
# - `vpn_type`: Either "RouteBased" or "PolicyBased".
# - `gateway_sku`: The SKU for the gateway (e.g., "VpnGw1", "Basic"). Choose based on your required capacity.
# - `gateway_public_ip_id`: The full resource ID of the Public IP assigned to the gateway.
#   In the Azure Portal, navigate to the Public IP, select “Properties,” and copy the “Resource ID”.
# - `gateway_subnet_id`: The full resource ID of the GatewaySubnet in the VNet.
#   The GatewaySubnet must exist in your VNet. Go to the subnet, select “Properties,” and copy the “Resource ID”.
gateway_name = "my-gateway"
gateway_type = "Vpn"
vpn_type = "RouteBased"
gateway_sku = "VpnGw1"
active_active = false
enable_bgp = false
gateway_public_ip_id = "/subscriptions/87c9cdc0-75e2-4e53-b528-673f2cedc16f/resourceGroups/your-rg/providers/Microsoft.Network/publicIPAddresses/my-gateway-ip"
gateway_subnet_id = "/subscriptions/87c9cdc0-75e2-4e53-b528-673f2cedc16f/resourceGroups/your-rg/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/GatewaySubnet"
