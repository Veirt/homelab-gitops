locals {
  name   = "aws-k3s-agent"
  region = "ap-southeast-3"

  instance_type    = "t3.small"
  root_volume_size = 24

  ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIICPssbZ9enLBa59KTQVIf3saDp+I5tVIJ5/+U7dp5XD"

  tags = {
    Name      = local.name
    Project   = "homelab"
    ManagedBy = "terraform"
  }
}

data "aws_ssm_parameter" "al2023_x86_64" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_key_pair" "default" {
  key_name   = local.name
  public_key = local.ssh_public_key

  tags = local.tags
}

resource "aws_vpc" "default" {
  cidr_block                       = "10.73.0.0/24"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_egress_only_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_subnet" "default" {
  vpc_id                          = aws_vpc.default.id
  availability_zone               = data.aws_availability_zones.available.names[0]
  cidr_block                      = cidrsubnet(aws_vpc.default.cidr_block, 4, 0)
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.default.ipv6_cidr_block, 8, 0)
  assign_ipv6_address_on_creation = true
  map_public_ip_on_launch         = true

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_route" "ipv6_internet" {
  route_table_id              = aws_route_table.default.id
  destination_ipv6_cidr_block = "::/0"
  egress_only_gateway_id      = aws_egress_only_internet_gateway.default.id
}

resource "aws_route" "ipv4_internet" {
  route_table_id         = aws_route_table.default.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id
}

resource "aws_route_table_association" "default" {
  subnet_id      = aws_subnet.default.id
  route_table_id = aws_route_table.default.id
}

resource "aws_security_group" "instance" {
  name        = local.name
  description = "Outbound-only access for the Tailscale k3s agent"
  vpc_id      = aws_vpc.default.id

  tags = merge(local.tags, {
    Name = local.name
  })
}

resource "aws_vpc_security_group_egress_rule" "all_ipv4" {
  security_group_id = aws_security_group.instance.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_ipv6" {
  security_group_id = aws_security_group.instance.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}

resource "aws_launch_template" "instance" {
  name_prefix            = "${local.name}-"
  image_id               = data.aws_ssm_parameter.al2023_x86_64.value
  instance_type          = local.instance_type
  key_name               = aws_key_pair.default.key_name
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      delete_on_termination = true
      encrypted             = true
      volume_size           = local.root_volume_size
      volume_type           = "gp3"
    }
  }

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_protocol_ipv6          = "enabled"
    http_put_response_hop_limit = 2
    http_tokens                 = "required"
    instance_metadata_tags      = "enabled"
  }

  monitoring {
    enabled = false
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    ipv6_address_count          = 1
    security_groups             = [aws_security_group.instance.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  tag_specifications {
    resource_type = "network-interface"
    tags          = local.tags
  }

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    enable_k3s_agent     = var.enable_k3s_agent
    extra_k3s_agent_args = var.extra_k3s_agent_args
    extra_tailscale_args = var.extra_tailscale_args
    k3s_server_url       = var.k3s_server_url
    k3s_token            = var.k3s_token
    tailscale_auth_key   = var.tailscale_auth_key
    tailscale_hostname   = var.tailscale_hostname
  }))

  tags = local.tags
}

resource "aws_autoscaling_group" "instance" {
  name                = local.name
  min_size            = 1
  desired_capacity    = 1
  max_size            = 1
  health_check_type   = "EC2"
  vpc_zone_identifier = [aws_subnet.default.id]

  launch_template {
    id      = aws_launch_template.instance.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = local.name
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = local.tags.Project
    propagate_at_launch = true
  }

  tag {
    key                 = "ManagedBy"
    value               = local.tags.ManagedBy
    propagate_at_launch = true
  }
}
