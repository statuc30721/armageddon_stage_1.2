# Tokyo Security VPC

resource "aws_vpc" "VPC-Cyber-Tokyo" {
    
    provider = aws.tokyo
    cidr_block = "10.19.0.0/16"

  tags = {
    Name = "VPC-Cyber-Tokyo"
    Service = "cybersecurity"
    Owner = "Frodo"
    Planet = "Arda"
  }
}




# Tokyo Private IP space.
# Tokyo Syslog server requires "2" Availaibility Zones.
# So we will use ap-northeast-1c and ap-northeast-1d for Tokyo Cyber VPC.


resource "aws_subnet" "private-cyber-ap-northeast-1c" {
  vpc_id                  = aws_vpc.VPC-Cyber-Tokyo.id
  cidr_block              = "10.19.11.0/24"
  availability_zone       = "ap-northeast-1c"
  provider = aws.tokyo
  
  tags = {
    Name    = "private-cyber-ap-northeast-1c"
    Service = "cybersecurity"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}
resource "aws_subnet" "private-cyber-ap-northeast-1d" {
  vpc_id                  = aws_vpc.VPC-Cyber-Tokyo.id
  cidr_block              = "10.19.12.0/24"
  availability_zone       = "ap-northeast-1d"
  provider = aws.tokyo
  
  tags = {
    Name    = "private-cyber-ap-northeast-1d"
    Service = "cybersecurity"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}



#--------------------------------------------------------#
# Internet Gateway (IGW)

resource "aws_internet_gateway" "igw_CYBER_TYO" {
  vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
  provider = aws.tokyo


  tags = {
    Name    = "CYBER_TYO_IGW"
    Service = "cybersecurity"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}



#----------------------------------------------------#
# Subnets
#




#-----------------------------------------------#
# Private Network

resource "aws_route_table" "private_CYBER_Tokyo" {
  vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
  provider = aws.tokyo


  
  route  {
      cidr_block                 = "10.0.0.0/8"
      nat_gateway_id             = "" 
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      #instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = aws_ec2_transit_gateway.Tokyo-Region-TGW.id
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }

  tags = {
    Name = "private_CYBER_Tokyo"
  }
}


# These are for the private subnets.

resource "aws_route_table_association" "private-cyber-ap-northeast-1c" {
  subnet_id      = aws_subnet.private-cyber-ap-northeast-1c.id
  route_table_id = aws_route_table.private_CYBER_Tokyo.id
  provider = aws.tokyo
}

resource "aws_route_table_association" "private-cyber-ap-northeast-1d" {
  subnet_id      = aws_subnet.private-cyber-ap-northeast-1d.id
  route_table_id = aws_route_table.private_CYBER_Tokyo.id
  provider = aws.tokyo
}


#---------------------------------------------------------------------#
# Security Groups
#

# Bastion Server Security Group
# Not created at this phase.

# Security Group for Tokyo Syslog Server"
#

resource "aws_security_group" "SG01-CYBER-TYO-SYSLOG" {
    name = "SG01-TYO-SYSLOG"
    description = "Allow SSH and SYSLOG traffic to security servers."
    vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
    provider = aws.tokyo

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.19.0.0/16","10.20.0.0/16"]
    }

    ingress {
        description = "SYSLOG"
        from_port = 514
        to_port = 514
        protocol = "UDP"
        cidr_blocks = ["10.0.0.0/8"]
    }


    # This is here to allow TESTING connection to the SYSLOG server
    # until it is deployed. We use a basic EC2 virtual machine.
    ingress {
        description = "TCP_TESTING"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "SG01-CYBER-TYO-SYSLOG"
        Service = "syslog"
        Owner = "Frodo"
        Planet = "Arda"
    }
}



# Security group for Network Load Balancer
#
resource "aws_security_group" "SG02-TYO-CYBER-NLB01" {
    name = "SG02-TYO-CYBER-NLB01"
    description = "Allow HTTP inbound traffic to Load Balancer."
    vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
    provider = aws.tokyo

    ingress {
        description = "UDP_SYSLOG"
        from_port = 514
        to_port = 514
        protocol = "udp"
        cidr_blocks = ["10.0.0.0/8"]
    }
    # This is here to allow TESTING connection to the SYSLOG server
    # until it is deployed. We use a basic EC2 virtual machine.
    ingress {
        description = "TCP_TESTING"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
       egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "SG02-TYO-CYBER-NLB01"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


#------------------------------------------------------#
# Create a Target Group for Network Load Balancer
/*
resource "aws_lb_target_group" "CYBER_TYO_TG01"{
  name     = "CYBER-TYO-TG01"
  port     = 514
  protocol = "UDP"
  vpc_id   = aws_vpc.VPC-Cyber-Tokyo.id
  target_type = "instance"
  provider = aws.tokyo
  
}
*/


 resource "aws_lb_target_group" "CYBER_TYO_TG02" {
  name     = "CYBER-TYO-TG02"
  port     = 80
  protocol = "TCP_UDP"
  vpc_id   = aws_vpc.VPC-Cyber-Tokyo.id
  target_type = "instance"
  provider = aws.tokyo

 health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP" # Need to change this to TCP when using actual NLB with syslog server.
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name    = "CYBER-TYO-TG02"
    Service = "ASG"
    Owner   = "Frodo"
    Project = "System Logging Service"
  }
}

#----------------------------------------------------------------#
# Create Network Load Balancer

resource "aws_lb" "CYBER-TYO-NLB01" {
  name               = "CYBER-Tokyo-Network-LB"
  internal           = true
  load_balancer_type = "network"
  security_groups    = [aws_security_group.SG02-TYO-CYBER-NLB01.id]
  subnets            = [
    aws_subnet.private-cyber-ap-northeast-1c.id,
    aws_subnet.private-cyber-ap-northeast-1d.id
  ]

  provider = aws.tokyo

  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "CYBER-Tokyo-Network-LB"
    Service = "App1"
    Owner   = "Frodo"
    Project = "Syslog Network Service"
  }
}
# Add Listener to Load Balancer
resource "aws_lb_listener" "CYBER_TYO_SYSLOG" {
  load_balancer_arn = aws_lb.CYBER-TYO-NLB01.arn
  port              = 80
  protocol          = "TCP_UDP"

  provider = aws.tokyo

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.CYBER_TYO_TG02.arn
  }
}


#----------------------------------------------------------------#
#
# ASG

resource "aws_autoscaling_group" "TYO_CYBER_ASG" {
  name_prefix           = "Tokyo-CYBER-auto-scaling-group"
  min_size              = 1
  max_size              = 5
  desired_capacity      = 2
  vpc_zone_identifier   = [
    aws_subnet.private-cyber-ap-northeast-1c.id,
    aws_subnet.private-cyber-ap-northeast-1d.id
  ]
  
  provider = aws.tokyo

  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.CYBER_TYO_TG02.arn]


  launch_template {
    id      = aws_launch_template.SYSLOG_Tokyo_LT.id
    version = "$Latest"
  }

  


  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupTotalInstances"]

  # Instance protection for launching
  initial_lifecycle_hook {
    name                  = "instance-protection-launch"
    lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
    default_result        = "CONTINUE"
    heartbeat_timeout     = 60
    notification_metadata = "{\"key\":\"value\"}"
  }

  # Instance protection for terminating
  initial_lifecycle_hook {
    name                  = "scale-in-protection"
    lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
    default_result        = "CONTINUE"
    heartbeat_timeout     = 300
  }

  tag {
    key                 = "Name"
    value               = "SYSLOG-TYO-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "TYO_CYBER_scaling_policy" {
  name                   = "syslog-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.TYO_CYBER_ASG.name

  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  provider = aws.tokyo

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

# Enabling instance scale-in protection
resource "aws_autoscaling_attachment" "TYO_CYBER_attachment" {
  autoscaling_group_name = aws_autoscaling_group.TYO_CYBER_ASG.name
  alb_target_group_arn   = aws_lb_target_group.CYBER_TYO_TG02.arn
  provider = aws.tokyo
}