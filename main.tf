module "network" {
  source                     = "./modules/network"
  vpc_cidr                   = "10.0.0.0/16"
  secondary_vpc_cidr         = ["10.1.0.0/24", "10.3.0.0/24"]
  vpc_name                   = "demo-vpc"
  igw_name                   = "demo-vpc-gw"
  public_subnet_cidr_blocks  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
  private_subnet_cidr_blocks = ["10.0.5.0/24", "10.0.6.0/24"]
  availability_zones         = ["ap-south-1a", "ap-south-1b"]
  public_subnet_name_prefix  = "public-subnet"
  private_subnet_name_prefix = "private-subnet"
  public_rt_name             = "public-rt"
  private_rt_name            = "private-rt"
}


module "security_group_alb" {
  source              = "./modules/securitygroup"
  security_group_name = "alb-sg"
  inbound_port        = [80]
  vpc_id              = module.network.vpc_id
  sg_ingress          = ["0.0.0.0/0"]
}

module "security_group_ec2" {
  source              = "./modules/securitygroup"
  security_group_name = "ec2-sg"
  inbound_port        = [22, 80]
  vpc_id              = module.network.vpc_id
  sg_ingress          = ["0.0.0.0/0"]
}


module "alb_frontend" {
  source                = "./modules/alb"
  alb_name              = "Frontend-ALB"
  alb_sg_id             = module.security_group_alb.security_group_id
  alb_subnet_ids        = [module.network.public_subnet_ids[2], module.network.public_subnet_ids[3]]
  targetgroup_name      = "Frontend-TG"
  vpc_id                = module.network.vpc_id
  alb_internal          = false
  healthy_threshold     = 2
  unhealthy_threshold   = 5
  health_check_interval = 30
  health_check_path     = "/"
  health_check_timeout  = 10
}

module "asg" {
  source               = "./modules/ec2"
  template_name        = "asgtemplate"
  ami                  = "ami-03f4878755434977f"
  key_name             = "newkeytf"
  instance_type        = "t2.micro"
  ec2_sg_id            = module.security_group_ec2.security_group_id
  private_subnet_ids    = [module.network.private_subnet_ids[0], module.network.private_subnet_ids[1]]
  asg_name             = "stageasg"
  min_size             = 2
  max_size             = 4
  desired_capacity     = 2
  alb_target_group_arn = module.alb_frontend.alb_target_group_arn
}


resource "aws_route53_zone" "private_zone" {
  name               = "test.example.com"
  vpc {
    vpc_id = module.network.vpc_id
  }
  
}
resource "aws_route53_record" "alias" {
  zone_id            = aws_route53_zone.private_zone.zone_id
  name               = "subdomain.test.example.com"
  type               = "A"
  alias {
    name             = module.alb_frontend.elb_dns_name
    zone_id          = module.alb_frontend.elb_zone_id
    evaluate_target_health = true
  }
}