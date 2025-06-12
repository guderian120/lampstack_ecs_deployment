data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  vars = {
    db_host     = var.db_host
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  }
}

resource "aws_launch_template" "this" {
  name_prefix   = var.name_prefix
  image_id      = var.ami_id
  instance_type = var.instance_type
#   key_name      = var.key_name

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = var.security_group_ids
  }

  user_data = base64encode(data.template_file.user_data.rendered)

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.tags,
      {
        Name = "${var.name_prefix}-instance"
      }
    )
  }
}

resource "aws_autoscaling_group" "this" {
  name_prefix          = "${var.name_prefix}-asg-"
  vpc_zone_identifier = var.vpc_zone_identifier
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity

  target_group_arns = var.target_group_arns

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.name_prefix}-asg"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}