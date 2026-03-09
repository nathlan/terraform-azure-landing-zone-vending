# Landing Zone Outputs

output "subscription_ids" {
  description = "Map of landing zone keys to their subscription IDs."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.subscription_id
  }
}

output "subscription_resource_ids" {
  description = "Map of landing zone keys to their subscription resource IDs."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.subscription_resource_id
  }
}

output "resource_group_resource_ids" {
  description = "Map of landing zone keys to their resource group resource IDs."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.resource_group_resource_ids
  }
}

output "virtual_network_resource_ids" {
  description = "Map of landing zone keys to their virtual network resource IDs."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.virtual_network_resource_ids
  }
}

output "umi_client_ids" {
  description = "Map of landing zone keys to their UMI client IDs."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.umi_client_ids
  }
}

output "umi_principal_ids" {
  description = "Map of landing zone keys to their UMI principal IDs (object IDs)."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.umi_principal_ids
  }
}

output "umi_resource_ids" {
  description = "Map of landing zone keys to their UMI resource IDs."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.umi_resource_ids
  }
}

output "tfplan_client_ids" {
  description = "Map of landing zone keys to their Terraform plan UMI client IDs (id-<workload>-<env>-<workload>-tfplan, Reader role)."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.umi_client_ids["plan"]
  }
}

output "tfapply_client_ids" {
  description = "Map of landing zone keys to their Terraform apply UMI client IDs (id-<workload>-<env>-<workload>-tfapply, Owner role)."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.umi_client_ids["apply"]
  }
}

output "budget_resource_ids" {
  description = "Map of landing zone keys to their budget resource IDs."
  value = {
    for lz_key, lz in module.landing_zone_vending :
    lz_key => lz.budget_resource_id
  }
}

output "calculated_address_prefixes" {
  description = "The automatically calculated address prefixes for virtual networks."
  value       = length(local.vnet_prefix_sizes) > 0 ? module.ip_addresses[0].address_prefixes : null
}

output "virtual_network_address_spaces" {
  description = "Map of landing zone keys to their virtual network address spaces."
  value = {
    for lz_key, lz in local.virtual_networks :
    lz_key => lz != null ? lz.address_space : null
  }
}

output "landing_zone_names" {
  description = "Map of landing zone keys to their auto-generated subscription names."
  value       = local.subscription_names
}
