
  #### Please ensure you have already configured AWS CLI to deploy infrastructure to your account
  
  ###Please replace or update values against these in main.tf in root directory or by using .tfvars
  
  vpc_cidr                   = "Please enter primary VPC CIDR"
  secondary_vpc_cidr         = Please enter primary VPC CIDR
  vpc_name                   = "Please nter VPC name"
  igw_name                   = "Please enter IGW name"
  public_subnet_cidr_blocks  = [Please mention public subnet cidr]
  private_subnet_cidr_blocks = [Please mention private subnet cidr]
  availability_zones         = [Please mention availability zone]
  public_subnet_name_prefix  = "Please mention public subnet prefix"
  private_subnet_name_prefix = "Please mention private subnet prefix"
  public_rt_name             = "Public Route table name"
  private_rt_name            = "Private Route table name
  security_group_name        = "Pleas mention alb security group name"
  inbound_port               = [Please mention Inboubnd port number]
  sg_ingress                 = [Please mention source ip]
  security_group_name        = "Please mention ec2-sg name"
  inbound_port               = [Please mention port number]
  sg_ingress                 = [Please mention ingress]
  alb_name                   = "Please mention ALB Name"
  alb_internal               = ALB Type internal/external
  healthy_threshold          = Healthy threshold 
  unhealthy_threshold        = Unhealthy threshold
  health_check_interval      = Health check interval
  health_check_path          = Please mention health check path
  health_check_timeout       = Please mention health check timeout
  template_name              = "Please mention template name"
  ami                        = "Please mention ami name"
  key_name                   = "Please mention keypair name"
  instance_type              = "Please mention instance type"
  asg_name                   = "please mention autoscaling group name"
  min_size                   = Mention autoscaling min size
  max_size                   = Mention autoscaling max size
  desired_capacity           = Mention desired capacity
