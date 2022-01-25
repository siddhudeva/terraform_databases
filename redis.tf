resource "aws_elasticache_cluster" "Redisdb" {
  cluster_id           = "Redis-${var.ENV}"
  engine               = "redis"
  node_type            = "cache t3.micro"
  num_cache_nodes      = 1
  engine_version       = "6.2"
  port                 = 6379
  security_group_names = aws_elasticache_subnet_group.subnet-redis.name
  security_group_ids   = [aws_security_group.redis-sg-private.id]
}
resource "aws_elasticache_subnet_group" "subnet-redis" {
  name       = "${var.ENV}-cache-subnet"
  subnet_ids = data.terraform_remote_state.vpc.outputs.PRIVATE_CIDR
}

resource "aws_security_group" "redis-sg-private" {
  name        = "redis-sg-private"
  description = "redis-sg-private"
  vpc_id      = data.terraform_remote_state.vpc.outputs.VPC_ID

  ingress {
    description      = "APP"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = ["data.terraform_remote_state.vpc.outputs.PRIVATE_CIDR"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.ENV}-redis_sg"
  }
}
