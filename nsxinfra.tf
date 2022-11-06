terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
}

provider "nsxt" {
  version               = "~> 3.2"
  host                  = "nsxmgr-01a"
  username              = "admin"
  password              = "VMware1!VMware1!"
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

resource "nsxt_infra_policy" "InfraIPSet" {
  description  = "IS provisioned by Terraform"
  display_name = "InfraIPSet"
  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10", "192.169.110.90"]
    }
  }
}

resource "nsxt_infra_security_policy" "firewall_section" {
  display_name = "Jenkins_Infra"
  description  = "Firewall section created by Terraform"
  category     = "Infrastructure"
  locked       = "false"
  stateful     = "true"

  rule {
    display_name          = "Infrastructure Servers"
    description           = "Allow Infra MGMT"
    action                = "ALLOW"
    logged                = true
    ip_version            = "IPV4"
    source_groups         = [nsxt_infra_policy.InfraIPSet] 
  }
}