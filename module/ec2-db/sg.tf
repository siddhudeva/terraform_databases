

/// Security group for mongodb/rabbitmqdb
resource "aws_security_group" "DB" {
  name        = "${var.DB_COMPONENT}-sg-${var.ENV}"
  description = "${var.DB_COMPONENT}-sg-${var.ENV}"
  vpc_id      = var.VPC_ID

  ingress {
    description = "DB"
    from_port   = var.APP_PORT
    to_port     = var.APP_PORT
    protocol    = "tcp"
    cidr_blocks = var.CIDR_PRIVATE
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ALL_CIDR
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
    /// as we know all outbound rules are open to internet
    tags = {
      Name = "${var.DB_COMPONENT}-sg-public"
    }
  }
}