resource "aws_spot_instance_request" "DB" {
  ami                  = var.AMI
  instance_type        = var.INSTANCE_TYPE
  tags = {
    Name = "${var.DB_COMPONENT}-${var.ENV}"
  }
  subnet_id              = var.PRIVATE_SUBNET_ID
  wait_for_fulfillment = "true"
  vpc_security_group_ids = [aws_security_group.sg-db.id]
}
resource "aws_ec2_tag" "spot-ec2" {
  resource_id = aws_spot_instance_request.DB.spot_instance_id
  key         = "Name"
  value       = "${var.DB_COMPONENT}-${var.ENV}-db"
}
