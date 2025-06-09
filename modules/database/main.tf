resource "aws_db_subnet_group" "this" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name_prefix}-subnet-group"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier             = var.name_prefix
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = var.security_group_ids

  parameter_group_name   = var.parameter_group_name
  skip_final_snapshot   = var.skip_final_snapshot
  backup_retention_period = var.backup_retention_period

  publicly_accessible    = false
  multi_az               = false # Set to true for production
  storage_encrypted      = true

  tags = merge(
    var.tags,
    {
      Name = var.name_prefix
    }
  )
}