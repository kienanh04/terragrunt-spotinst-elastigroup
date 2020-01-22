provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

terraform {
  backend "s3" {}
}

data "aws_ami" "amazon2" {
  owners      = ["137112412989"]
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

}

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config {
    bucket         = "${var.tfstate_bucket}"
    key            = "${var.tfstate_key_vpc}"
    region         = "${var.tfstate_region}"
    profile        = "${var.tfstate_profile}"
    role_arn       = "${var.tfstate_arn}"
  }
}

locals {
  common_tags = [
    {
      key   = "Env"
      value = "${var.project_env}"
    },
    {
      key   = "Name"
      value = "${local.name}"
    }
  ]

  public_subnets  = "${compact(split(",", (length(var.subnet_ids) == "0" ? join(",", data.terraform_remote_state.vpc.public_subnets) : join(",", var.subnet_ids))))}"
  private_subnets = "${compact(split(",", (length(var.subnet_ids) == "0" ? join(",", data.terraform_remote_state.vpc.private_subnets) : join(",", var.subnet_ids))))}"
  subnet_ids = "${compact(split(",", (var.is_public ? join(",", local.public_subnets) : join(",", local.private_subnets))))}"
  key_name   = "${coalesce(var.key_name,data.terraform_remote_state.vpc.key_name)}"
  image_id   = "${coalesce(var.image_id,data.aws_ami.amazon2.id)}"
  name       = "${coalesce(var.customized_name,"${lower(var.project_env_short)}-${lower(var.name)}")}"
}

data "aws_security_groups" "ec2" {
  tags = "${merge(var.source_ec2_sg_tags, map("Env", "${var.project_env}"))}"
  filter {
    name   = "vpc-id"
    values = ["${data.terraform_remote_state.vpc.vpc_id}"]
  }
}

module "elastigroup" {
  source = "git::https://github.com/thanhbn87/terraform-spotinst-elastigroup.git?ref=tags/0.1.0"

  spotinst_account = "${var.spotinst_account}"
  spotinst_token   = "${var.spotinst_token}"

  name              = "${local.name}"
  namespace         = "${var.namespace}"
  desc              = "${var.desc}"
  product           = "${var.product}"
  aws_region        = "${var.aws_region}"
  aws_profile       = "${var.aws_profile}"
  subnet_ids        = "${local.subnet_ids}"
  project_env       = "${var.project_env}"
  project_env_short = "${var.project_env_short}"
  tags              = "${concat(var.tags,local.common_tags)}"

  ## Route53:
  route53_local      = "${var.route53_local}"
  private_zone_id    = "${var.private_zone_id}"
  domain_local       = "${var.domain_local}"
  private_record_ttl = "${var.private_record_ttl}"
  route53_temp_ip    = "${var.route53_temp_ip}"

  ## Capacity:
  min_size             = "${var.min_size}"
  max_size             = "${var.max_size}"
  desired_capacity     = "${var.desired_capacity}"
  capacity_unit        = "${var.capacity_unit}"

  ## Launch Config
  image_id                  = "${local.image_id}"
  iam_instance_profile      = "${var.iam_instance_profile}"
  key_name                  = "${local.key_name}"
  security_groups           = "${data.aws_security_groups.ec2.ids}"
  ebs_optimized             = "${var.ebs_optimized}"
  placement_tenancy         = "${var.placement_tenancy}"
  user_data                 = "${var.user_data}"
  enable_monitoring         = "${var.enable_monitoring}"
  health_check_type         = "${var.health_check_type}"
  health_check_grace_period = "${var.health_check_grace_period}"
  network_interface         = "${var.network_interface}"
  ebs_block_device          = "${var.ebs_block_device}"
  ebs_device_name           = "${var.ebs_device_name}"
  ebs_volume_type           = "${var.ebs_volume_type}"
  ebs_volume_size           = "${var.ebs_volume_size}"
  ebs_delete_on_termination = "${var.ebs_delete_on_termination}"

  // Compute
  instance_types_ondemand       = "${var.instance_types_ondemand}"
  instance_types_spot           = "${var.instance_types_spot}"
  instance_types_preferred_spot = "${var.instance_types_preferred_spot}"
  instance_types_weights        = "${var.instance_types_weights}"

  // Load balancer
  elastic_load_balancers = "${var.elastic_load_balancers}"
  target_group_arns = "${var.target_group_arns}"

  // Strategy
  orientation                = "${var.orientation}"
  spot_percentage            = "${var.spot_percentage}"
  draining_timeout           = "${var.draining_timeout}"
  lifetime_period            = "${var.lifetime_period}"
  fallback_to_ondemand       = "${var.fallback_to_ondemand}"
  utilize_reserved_instances = "${var.utilize_reserved_instances}"
  revert_to_spot             = ["${var.revert_to_spot}"]

  // Stateful
  block_devices_mode    = "${var.block_devices_mode}"
  persist_root_device   = "${var.persist_root_device}"
  persist_block_devices = "${var.persist_block_devices}"
  persist_private_ip    = "${var.persist_private_ip}"
}
