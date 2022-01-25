resource "aws_spot_instance_request" "DB" {
  ami                  = var.AMI
  instance_type        = var.INSTANCE_TYPE
  wait_for_fulfillment = "true"
  tags = {
    Name = "${var.DB_COMPONENT}-${var.ENV}"
  }
  vpc_security_group_ids = [aws_security_group.DB.id]
  subnet_id              = var.PRIVATE_SUBNET_ID
}
