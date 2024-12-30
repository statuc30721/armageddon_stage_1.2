# VPC

resource "aws_vpc" "VPC-A-Tokyo-Test" {
    
    provider = aws.tokyo
    cidr_block = "10.20.0.0/16"

  tags = {
    Name = "VPC-A-Tokyo-Test"
    Service = "application1"
    Owner = "Frodo"
    Planet = "Arda"
  }
}


#------------------------------------------------------------#
#  Tokyo VPC Public IP space.
resource "aws_subnet" "public-ap-northeast-1a" {
    vpc_id                  = aws_vpc.VPC-A-Tokyo-Test.id
    cidr_block              = "10.20.1.0/24"
    availability_zone       = "ap-northeast-1a"
    map_public_ip_on_launch = true
    provider = aws.tokyo

    tags = {
    Name    = "public-ap-northeast-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
    }
}




resource "aws_subnet" "public-ap-northeast-1c" {
  vpc_id                  = aws_vpc.VPC-A-Tokyo-Test.id
  cidr_block              = "10.20.2.0/24"
  availability_zone       = "ap-northeast-1c"
  map_public_ip_on_launch = true
  provider = aws.tokyo

  tags = {
    Name    = "public-ap-northeast-1c"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

# Tokyo Private IP space.

resource "aws_subnet" "private-ap-northeast-1a" {
  vpc_id                  = aws_vpc.VPC-A-Tokyo-Test.id
  cidr_block              = "10.20.11.0/24"
  availability_zone       = "ap-northeast-1a"
  provider = aws.tokyo
  
  tags = {
    Name    = "private-ap-northeast-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "private-ap-northeast-1c" {
  vpc_id                  = aws_vpc.VPC-A-Tokyo-Test.id
  cidr_block              = "10.20.12.0/24"
  availability_zone       = "ap-northeast-1c"
  provider = aws.tokyo

  tags = {
    Name    = "private-ap-northeast-1c"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

#--------------------------------------------------------#
# IGW

resource "aws_internet_gateway" "igw_TYO" {
  vpc_id = aws_vpc.VPC-A-Tokyo-Test.id
  provider = aws.tokyo


  tags = {
    Name    = "application1_TYO_IGW"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

# Tokyo NAT
resource "aws_eip" "eip_TYO" {
  vpc = true
  provider = aws.tokyo

  tags = {
    Name = "eip_TYO"
  }
}

resource "aws_nat_gateway" "nat_TYO" {
  allocation_id = aws_eip.eip_TYO.id
  subnet_id     = aws_subnet.public-ap-northeast-1a.id
  provider = aws.tokyo

  tags = {
    Name = "nat_TYO"
  }

  depends_on = [aws_internet_gateway.igw_TYO]
}


#----------------------------------------------------#
# Subnets
#
# Public Network

resource "aws_route_table" "public_Tokyo" {
  vpc_id = aws_vpc.VPC-A-Tokyo-Test.id
  provider = aws.tokyo

  route   {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw_TYO.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      #instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  
    tags = {
    Name = "public_tokyo"
  }
}

#-----------------------------------------------#
#
# These are for the public subnets.

resource "aws_route_table_association" "public-ap-northeast-1a" {
  subnet_id      = aws_subnet.public-ap-northeast-1a.id
  route_table_id = aws_route_table.public_Tokyo.id
  provider = aws.tokyo
}

resource "aws_route_table_association" "public-ap-northeast-1c" {
  subnet_id      = aws_subnet.public-ap-northeast-1c.id
  route_table_id = aws_route_table.public_Tokyo.id
  provider = aws.tokyo
}

#-----------------------------------------------#
# Private Network


resource "aws_route_table" "private_Tokyo" {
  vpc_id = aws_vpc.VPC-A-Tokyo-Test.id
  provider = aws.tokyo
  
  
  route  {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat_TYO.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      #instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = "" 
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }

# This route is to pass traffic to Tokyo Security Zone VPC.
route  {
      cidr_block                 = "10.19.0.0/16"
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
    Name = "private_Tokyo"
  }
}


# These are for the private subnets.

resource "aws_route_table_association" "private-ap-northeast-1a" {
  subnet_id      = aws_subnet.private-ap-northeast-1a.id
  route_table_id = aws_route_table.private_Tokyo.id
  provider = aws.tokyo
}

resource "aws_route_table_association" "private-ap-northeast-1c" {
  subnet_id      = aws_subnet.private-ap-northeast-1c.id
  route_table_id = aws_route_table.private_Tokyo.id
  provider = aws.tokyo
}


#---------------------------------------------------------------------#
# Security Groups
#
# Security group for Load Balancer
#
resource "aws_security_group" "ASG01-SG01-TYO-LB01" {
    name = "ASG01-SG01-TYO-LB01"
    description = "Allow HTTP inbound traffic to Load Balancer."
    vpc_id = aws_vpc.VPC-A-Tokyo-Test.id
    provider = aws.tokyo

    ingress {
        description = "HTTP"
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
        Name = "ASG01-SG01-TYO-LB01"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security Group for Automatic Scaling Group
resource "aws_security_group" "ASG01-SG02-TYO-TG80" {
    name = "ASG01-SG02-TYO-TG80"
    description = "allow traffic to ASG"
    vpc_id = aws_vpc.VPC-A-Tokyo-Test.id
    provider = aws.tokyo


    ingress {
        description = "HTTP"
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
        Name = "ASG01-SG02-TYO-TG80"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security group for EC2 Virtual Machines
resource "aws_security_group" "ASG01-SG03-TYO-servers" {
    name = "ASG01-SG03-TYO-servers"
    description = "Allow SSH and HTTP traffic to production servers"
    vpc_id = aws_vpc.VPC-A-Tokyo-Test.id
    provider = aws.tokyo

    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
    }

    ingress {
        description = "HTTP"
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
        Name = "ASG01-SG03-TYO-servers"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}



#------------------------------------------------------#
# Target Groups

resource "aws_lb_target_group" "ASG01_TYO_TG01" {
  name     = "ASG01-Tokyo-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC-A-Tokyo-Test.id
  target_type = "instance"
  provider = aws.tokyo

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name    = "ASG01-Tokyo-TG01"
    Service = "ASG"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}

#----------------------------------------------------------------#
# Load Balancer

resource "aws_lb" "ASG01-TYO-LB01" {
  name               = "ASG01-Tokyo-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ASG01-SG01-TYO-LB01.id]
  subnets            = [
    aws_subnet.public-ap-northeast-1a.id,
    aws_subnet.public-ap-northeast-1c.id
  ]

  provider = aws.tokyo

  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "ASG01-TYO-LB01"
    Service = "App1"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}

resource "aws_lb_listener" "http_TYO" {
  load_balancer_arn = aws_lb.ASG01-TYO-LB01.arn
  port              = 80
  protocol          = "HTTP"

  provider = aws.tokyo

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ASG01_TYO_TG01.arn
  }
}

#----------------------------------------------------------------#
#
# ASG

resource "aws_autoscaling_group" "ASG01_TYO" {
  name_prefix           = "ASG01-Tokyo-auto-scaling-group"
  min_size              = 1
  max_size              = 5
  desired_capacity      = 2
  vpc_zone_identifier   = [
    aws_subnet.private-ap-northeast-1a.id,
    aws_subnet.private-ap-northeast-1c.id
  ]
  
  provider = aws.tokyo

  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.ASG01_TYO_TG01.arn]

  launch_template {
    id      = aws_launch_template.app1_Tokyo_LT.id
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
    value               = "app1-TYO-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "app1_TYO_scaling_policy" {
  name                   = "app1-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.ASG01_TYO.name

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
resource "aws_autoscaling_attachment" "ASG01_TYO_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ASG01_TYO.name
  alb_target_group_arn   = aws_lb_target_group.ASG01_TYO_TG01.arn
  provider = aws.tokyo
}
