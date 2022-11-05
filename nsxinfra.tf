terraform {
  required_providers {
    nsxt = {
      source = "vmware/nsxt"
    }
  }
}

provider "nsxt" {
  host                  = "nsxmgr-01a"
  username              = "admin"
  password              = "VMware1!VMware1!"
  allow_unverified_ssl  = true
  max_retries           = 10
  retry_min_delay       = 500
  retry_max_delay       = 5000
  retry_on_status_codes = [429]
}

resource "nsxt_policy_security_policy" "firewall_section" {
  display_name = "Jenkins_Infra"
  description  = "Firewall section created by Terraform"
  scope        = [nsxt_policy_group.all_vms.path]
  category     = "Infrastructure"
  locked       = "false"
  stateful     = "true"

  # Allow communication to any VMs only on the ports defined earlier
  rule {
    display_name       = "Allow Jenkins Build Server1"
    description        = "In going rule"
    action             = "ALLOW"
    logged             = "false"
    ip_version         = "IPV4"
    sources            = "192.168.110.90"
  }