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

resource "nsxt_policy_group" "infra_ip" {
  description  = "Group containing Infrastructure IPs"
  display_name = "InfraIPSet"
  criteria {
    ipaddress_expression {
      ip_addresses = ["192.168.110.10", "192.169.110.90"]
    }
  }
}

data "nsxt_policy_service" "ldap" {
  display_name = "LDAP"
}

data "nsxt_policy_service" "syslog" {
  display_name = "Syslog (UDP)"
}

data "nsxt_policy_service" "ad" {
  display_name = "Active Directory Servives"
}

data "nsxt_policy_service" "dns" {
  display_name = "DNS"
}

data "nsxt_policy_service" "ntp" {
  display_name = "NTP"
}

data "nsxt_policy_service" "ldapssl" {
  display_name = "LDAP-over-SSL"
}

resource "nsxt_policy_security_policy" "firewall_section" {
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
    source_groups         = [nsxt_policy_group.infra_ip.path] 
  }

  rule {
    display_name          = "Infrastructure Services"
    description           = "Allow Infra Services"
    action                = "ALLOW"
    logged                = true
    ip_version            = "IPV4"
    destination_groups    = [nsxt_policy_group.infra_ip.path]
    services           = [data.nsxt_policy_service.ldap.path]
  }
}