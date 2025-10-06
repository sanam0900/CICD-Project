provider "aws" {
  region = var.region
}

resource "aws_security_group" "db_sg" {
  name        = "app-db-${var.environment}"
  description = "Security group for app database in ${var.environment}"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432  # PostgreSQL 
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.k8s_vpc_cidr]  # Allow traffic from Kubernetes VPC
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "app-db-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Environment = var.environment
  }
}

resource "aws_db_instance" "db" {
  identifier             = "app-db-${var.environment}"
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = var.environment != "prod"  
  multi_az               = var.multi_az

  tags = {
    Environment = var.environment
  }
}