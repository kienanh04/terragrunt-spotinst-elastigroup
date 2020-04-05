/// SpotInst Acc:
variable "spotinst_account" {}
variable "spotinst_token" {}

/// Remote state:
variable "tfstate_bucket" { default = "example-tfstate-bucket" }
variable "tfstate_region" { default = "us-west-2" }
variable "tfstate_profile" { default = "default" }
variable "tfstate_arn" { default = "" }
variable "tfstate_key_vpc" { default = "demo/vpc/terraform.tfstate" }

/// General:
variable "customized_name" { default = "" }
variable "name" { default = "spotinst_aws" }
variable "namespace" { default = "" }
variable "desc" { default = "Spotinst ElastiGroup" }
variable "product" { default = "Linux/UNIX" }
variable "aws_region" { default = "us-west-2" }
variable "aws_profile" { default = "default" }
variable "is_public" { default = true }
variable "subnet_ids" { 
  type = "list"
  default = []
}
variable "project_env" { default = "Production" }
variable "project_env_short" { default = "prd" }
variable "tags" {
  type = "list"
  default = [{
    "key"   = "SpotInst"
    "value" = "true"
  }]
} 
variable "enable_env_tags" { default = true }

/// AWS Route53 local:
variable "route53_local" { default = true }
variable "private_zone_id" { default = "" }
variable "domain_local" { default = "local" }
variable "private_record_ttl" { default = "300" }
variable "route53_temp_ip" { default = "10.10.10.10" }

/// Capacity:
variable "min_size" { default = "0" }
variable "max_size" { default = "0" }
variable "desired_capacity" { default = "0" }
variable "capacity_unit" { default = "instance" }

/// Launch Config:
variable "source_ec2_sg_tags" { default = { Type = "WebApp" } }
variable "image_id" { default = "ami-0cb72367e98845d43" }
variable "iam_instance_profile" { default = "" }
variable "key_name" { default = "" }
variable "security_groups" { default = [] }
variable "ebs_optimized" { default = true }
variable "placement_tenancy" { default = "default" }
variable "user_data" { default = "" }
variable "enable_monitoring" { default = false }
variable "health_check_type" { default = "EC2" }
variable "health_check_grace_period" { default = "300" }
variable "elastic_ips" { default = [] }
variable "network_interface" {
  type = "map"
  default = {
    "delete_on_termination" = true
    "device_index" = "0"
    "associate_public_ip_address" = false
  }
}
variable "ebs_block_device" { default = [] }
variable "ebs_device_name" { default = "/dev/xvda" }
variable "ebs_volume_type" { default = "gp2" }
variable "ebs_volume_size" { default = "8" }
variable "ebs_delete_on_termination" { default = "false" }

/// Compute:
variable "instance_types_ondemand" { default = "t3.nano" }
variable "instance_types_spot" { default = ["t3.nano","t2.nano"] }
variable "instance_types_preferred_spot" { default = ["t3.nano"] }
variable "instance_types_weights" { default = [] }

/// Load balancer:
variable "elastic_load_balancers" { default = [] }
variable "target_group_arns" { default = [] }

/// Strategy:
variable "orientation" { default = "costOriented" }
variable "spot_percentage" { default = "100" }
variable "draining_timeout" { default = "120" }
variable "lifetime_period" { default = "days" }
variable "fallback_to_ondemand" { default = true }
variable "utilize_reserved_instances" { default = false }
variable "revert_to_spot" {
  type = "map"
  default = {
    perform_at = "always"
  }
}

/// Stateful:
variable "block_devices_mode" { default = "reattach" }
variable "persist_root_device" { default = true }
variable "persist_block_devices" { default = true }
variable "persist_private_ip" { default = true }
