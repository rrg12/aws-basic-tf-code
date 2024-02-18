locals {
    user_data = <<-EOT
    #!/bin/bash
    sudo apt update -y
    apt install httpd -y
    echo 'Hello Terrform' >> /var/www/html
    systemctl start httpd
    systemctl enable httpd
    sudo apt install -y xfsprogs
    sudo mkfs.xfs /dev/sda1
    sudo mkdir /mnt/logs
    sudo mount /dev/xvdf /mnt/logs
    echo "/dev/xvdf /mnt/logs xfs defaults 0 0" | sudo tee -a /etc/fstab
    sudo mv /var/log/* /mnt/logs/
    sudo ln -s /mnt/logs /var/log
  EOT
}


resource "aws_launch_template" "instances_configuration" {
  name_prefix            = var.template_name
  image_id               = var.ami
  key_name               = var.key_name
  instance_type          = var.instance_type
  user_data              = base64encode(local.user_data)
  vpc_security_group_ids = [var.ec2_sg_id]

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      encrypted   = true
    }
    
  }

   block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = 8
      encrypted   = true
    }
    
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = var.template_name
  }

}

resource "aws_autoscaling_group" "asg" {
  name                      = var.asg_name
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  health_check_grace_period = 150
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.private_subnet_ids
  launch_template {
    id      = aws_launch_template.instances_configuration.id
    version = "$Latest"
  }

}

resource "aws_autoscaling_policy" "avg_cpu_policy_greater" {
  name                   = "avg-cpu-policy-greater"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.id

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }

}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = var.alb_target_group_arn
}


