# creates Consul autoscaling group for clients
resource "aws_autoscaling_group" "consul_servers" {
  #count             = length(var.zones)
  name                      = aws_launch_configuration.consul_servers.name
  launch_configuration      = aws_launch_configuration.consul_servers.name
  #availability_zones        = data.aws_availability_zones.available.names[count.index]
  #availability_zones        = var.zones[count.index]
  #availability_zones        = var.zones[count.index]
  min_size                  = var.consul_servers
  max_size                  = var.consul_servers
  desired_capacity          = var.consul_servers
  wait_for_capacity_timeout = "480s"
  health_check_grace_period = 15
  health_check_type         = "EC2"
  vpc_zone_identifier       = data.aws_subnet_ids.default.ids
  #vpc_zone_identifier       = data.aws_vpc.consul_vpc.id
  tag {
    key                 = "Name"
    value               = "${var.main_project_tag}-server"
    propagate_at_launch = true
  }
  tag {
    key                 = "Project"
    value               = var.main_project_tag
    propagate_at_launch = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

# provides a resource for a new autoscaling group launch configuration
resource "aws_launch_configuration" "consul_servers" {
  name            = "${var.main_project_tag}-consul-server"
  image_id        = var.ami_id
  instance_type   = "t3.micro"
  key_name        = var.ec2_key_pair_name
  security_groups = [aws_security_group.consul_server.id]
  user_data = base64encode(templatefile("${path.module}/scripts/server.sh", {
    # for injecting variables
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

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.consul_servers.id
  alb_target_group_arn   = aws_lb_target_group.alb_targets.arn
}
