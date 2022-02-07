
///DNS record updatation for mongodb/rabbitmq
resource "aws_route53_record" "private_DB_dns" {
  zone_id = var.PRIVATE_HOSTEDZONE_ID
  name    = "${var.DB_COMPONENT}-${var.ENV}.roboshop.internal"
  type    = "A"
  ttl     = "300"
  records = [aws_spot_instance_request.DB.private_ip]
}