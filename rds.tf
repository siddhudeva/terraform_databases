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
