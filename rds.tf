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
  vpc_security_group_ids = [aws_db_subnet_group.mysqlsubnet.id]
}

resource "aws_db_subnet_group" "mysqlsubnet" {
  name       = "main"
  subnet_ids = [data.terraform_remote_state.vpc.outputs.private_subnet]

  tags = {
    Name = "mysql_${var.ENV}-user"
  }
}

resource "aws_security_group" "mysql" {
  name        = "mysql-sg-${var.ENV}"
  description = "smysqlsg-${var.ENV}"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description = "APP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = concat(data.terraform_remote_state.vpc.outputs.PRIVATE_CIDR,tolist([data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR]))
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "mysql-sg-${var.ENV}"
  }
}

resource "null_resource" "mysql-schema" {
  provisioner "local-exec" {
    command = <<-EOF
sudo yum install mariadb -y
curl -s -L -o /tmp/mysql.zip "https://github.com/roboshop-devops-project/mysql/archive/main.zip"
cd /tmp
unzip -o mysql.zip
cd mysql-main
mysql -h ${aws_db_instance.mysql.address} -u${nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.secret-ssh.secret_string)["SSH_USERNAME"])} -p${nonsensitive(jsondecode(data.aws_secretsmanager_secret_version.secret-ssh.secret_string)["SSH_PASSWD"])} <shipping.sql
EOF
  }
}

resource "aws_route53_record" "mysql" {
  zone_id = data.terraform_remote_state.vpc.outputs.PRIVATE_HOSTED_ZONE_ID
  name    = "mysql-${var.ENV}.roboshop.internal"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_db_instance.mysql.address]
}
