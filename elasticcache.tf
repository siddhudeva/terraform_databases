resource "aws_elasticache_cluster" "redis" {
  cluster_id = "redis-${var.ENV}"
  engine = "redis"
  node_type = "cache.t3.micro"
  num_cache_nodes = 1
  engine_version = "6.x"
  port = 6379
  subnet_group_name = aws_elasticache_subnet_group.subnet-group.name
  security_group_ids = [aws_security_group.redis.id]
}

resource "aws_elasticache_subnet_group" "subnet-group" {
  name       = "redis-${var.ENV}"
  subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet
}

resource "aws_security_group" "redis" {
  name = "SG_REDIS_${var.ENV}"
  description = "SG_REDIS_${var.ENV}"
  vpc_id = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description = "APP"
    from_port = 6379
    to_port   = 6379
    protocol  = "tcp"
    cidr_blocks = data.terraform_remote_state.vpc.outputs.PRIVATE_CIDR
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name = "sg_redis_${var.ENV}"
  }
}

output "test1" {
  value = aws_elasticache_cluster.redis
}

resource "aws_route53_record" "redis" {
  zone_id = data.terraform_remote_state.vpc.outputs.PRIVATE_HOSTEDZONE_ID
  name    = "redis-${var.ENV}.roboshop.internal"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_elasticache_cluster.redis.cache_nodes[0].address]
}