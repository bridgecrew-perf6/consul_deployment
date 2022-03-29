# creates Consul autoscaling group for clients
resource "aws_autoscaling_group" "consul_clients" {
  #count             = length(var.zones)
  name                      = aws_launch_configuration.consul_clients.name
  launch_configuration      = aws_launch_configuration.consul_clients.name
  #availability_zones        = data.aws_availability_zones.available.names[count.index]
  #availability_zones        = var.zones[count.index]
  min_size                  = var.consul_clients
  max_size                  = var.consul_clients
  desired_capacity          = var.consul_clients
  wait_for_capacity_timeout = "480s"
  health_check_grace_period = 15
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.aws_subnet_ids.default.ids
  #vpc_zone_identifier       = data.aws_vpc.consul_vpc.id
   tag {
    key                 = "Name"
    value               = "${var.main_project_tag}-client"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.main_project_tag
    propagate_at_launch = true
  }

  depends_on = [aws_autoscaling_group.consul_servers]

  lifecycle {
    create_before_destroy = true
  }
}

# provides a resource for a new autoscaling group launch configuration
resource "aws_launch_configuration" "consul_clients" {
  name            = "${var.main_project_tag}-consul-clients"
  image_id        = var.ami_id
  instance_type   = "t3.small"
  key_name        = var.ec2_key_pair_name
  security_groups = [aws_security_group.consul_client.id]
  user_data = base64encode(templatefile("${path.module}/scripts/client.sh", {
    PROJECT_TAG = "Project"
    PROJECT_VALUE = var.main_project_tag
  }))
  #associate_public_ip_address = var.public_ip
  iam_instance_profile = aws_iam_instance_profile.consul_instance_profile.name
  root_block_device {
    volume_size = 10
  }

  lifecycle {
    create_before_destroy = true
  }
}
