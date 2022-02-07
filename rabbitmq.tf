module "rabbitmq" {
  source            = "./module/ec2-db"
  AMI               = data.aws_ami.ami_ec2.id
  INSTANCE_TYPE     = var.RABBITMQ_INSTANCE_TYPE
  ENV               = var.ENV
  PRIVATE_SUBNET_ID = data.terraform_remote_state.vpc.outputs.private_subnet[0] /////[0] choosing 0 is means pick any one subnet in private group.since it is private subnet
  VPC_ID            = data.terraform_remote_state.vpc.outputs.VPC_ID
  CIDR_PRIVATE      = data.terraform_remote_state.vpc.outputs.PRIVATE_CIDR
  ALL_CIDR          = concat(data.terraform_remote_state.vpc.outputs.PRIVATE_CIDR, tolist([data.terraform_remote_state.vpc.outputs.DEFAULT_VPC_CIDR])) //// this is for ssh connection for both vpcs. Here  the expression is used to provide both the CIDR values to create ingress rules using both CIDR
  PRIVATE_HOSTEDZONE_ID           = data.terraform_remote_state.vpc.outputs.PRIVATE_HOSTEDZONE_ID
  SSH_USERNAME      = jsondecode(data.aws_secretsmanager_secret_version.secret-ssh.secret_string)["SSH_USERNAME"]
  SSH_PASSWORD      = jsondecode(data.aws_secretsmanager_secret_version.secret-ssh.secret_string)["SSH_PASSWD"]
  DB_COMPONENT      = "rabbitmq"
  APP_PORT          = 5672
}

