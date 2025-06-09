data "template_file" "user_data" {
  template = file("${path.module}/user_data.sh")
  vars = {
    db_host     = var.db_host
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  }
}

resource "aws_instance" "this" {
  count                  = var.instance_count
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = element(var.subnet_ids, count.index)
  vpc_security_group_ids = var.security_group_ids
#   key_name               = var.key_name
  user_data              = data.template_file.user_data.rendered

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-${count.index + 1}"
    }
  )

  root_block_device {
    volume_size = 8
    volume_type = "gp2"
  }
}

resource "aws_eip" "this" {
  count    = var.instance_count
  instance = aws_instance.this[count.index].id
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-eip-${count.index + 1}"
    }
  )
}