resource "aws_db_security_group" "mysql" {
  name = "mysql-${var.ENV}"

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
