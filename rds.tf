resource "aws_db_instance" "mysql" {
  identifier             = "mysql_${var.ENV}-user"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = "mysqluser"
  username               = jsondecode(data.aws_secretsmanager_secret_version.secret-ssh.secret_string)["RDS_USER"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.secret-ssh.secret_string)["RDS_PASS"]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.mysqlsubnet.name
  vpc_security_group_ids = [aws_db_security_group.mysql.id]
}
resource "aws_db_subnet_group" "mysqlsubnet" {
  name       = "main"
  subnet_ids = [data.terraform_remote_state.vpc.outputs.private_subnet]

  tags = {
    Name = "mysql_${var.ENV}-user"
  }
}
resource "aws_db_security_group" "mysql" {
  name = "mysql-${var.ENV}" - sg

  ingress {
    description = "MysqlDB"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = concat(data.terraform_remote_state.vpc.outputs.PRIVATE_CIDR, tolist([data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR]))
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /// as we know all outbound rules are open to internet
  tags = {
    Name = "${var.ENV}-sg-Mysql"
  }
}
