variable "template_name" {
  description = "Launch template name"
}
variable "ami" {
  description = "EC2 ami"
}
variable "key_name" {
  description = "ssh key name"
}
variable "instance_type" {
  description = "EC2 instance type"
}
variable "ec2_sg_id" {
  description = "Database version"
}
variable "asg_name" {
  description = "Database endpoint"
}
variable "alb_target_group_arn" {
  description = "Target Group arn for form Application loadbalancer"
}
variable "min_size" {
  description = "min size"
}
variable "max_size" {
  description = "max size"
}
variable "desired_capacity" {
  description = "desired"
}
variable "private_subnet_ids" {
  type        = list(string)
  description = "List private subnet for ec2"
}
