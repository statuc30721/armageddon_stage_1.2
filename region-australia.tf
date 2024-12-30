# VPC
resource "aws_vpc" "VPC-E-Australia-Test" {
    provider = aws.australia
  cidr_block = "10.24.0.0/16"

  tags = {
    Name = "VPC-E-Australia-Test"
    Service = "application1"
    Owner = "Frodo"
    Planet = "Arda"
  }
}

#------------------------------------------------------#
# SUBNETS
#
#  Australia VPC Public IP space.
resource "aws_subnet" "public-ap-southeast-2a" {
    vpc_id                  = aws_vpc.VPC-E-Australia-Test.id
    cidr_block              = "10.24.1.0/24"
    availability_zone       = "ap-southeast-2a"
    map_public_ip_on_launch = true
    provider = aws.australia

    tags = {
    Name    = "public-ap-southeast-2a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
    }
}




resource "aws_subnet" "public-ap-southeast-2b" {
  vpc_id                  = aws_vpc.VPC-E-Australia-Test.id
  cidr_block              = "10.24.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true
  provider = aws.australia

  tags = {
    Name    = "public-ap-southeast-2b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

# Australia Private IP space.

resource "aws_subnet" "private-ap-southeast-2a" {
  vpc_id                  = aws_vpc.VPC-E-Australia-Test.id
  cidr_block              = "10.24.11.0/24"
  availability_zone       = "ap-southeast-2a"
  provider = aws.australia
  
  tags = {
    Name    = "private-ap-southeast-2a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "private-ap-southeast-2b" {
  vpc_id                  = aws_vpc.VPC-E-Australia-Test.id
  cidr_block              = "10.24.12.0/24"
  availability_zone       = "ap-southeast-2b"
  provider = aws.australia

  tags = {
    Name    = "private-ap-southeast-2b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

#-----------------------------------------------#
# Internet Gateway

resource "aws_internet_gateway" "igw_AUS" {
  vpc_id = aws_vpc.VPC-E-Australia-Test.id
  provider = aws.australia


  tags = {
    Name    = "application1_AUS_IGW"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}


#----------------------------------------------------#
# NAT

resource "aws_eip" "eip_Australia" {
  vpc = true
  provider = aws.australia

  tags = {
    Name = "eip_Australia"
  }
}
resource "aws_nat_gateway" "nat_Australia" {
  allocation_id = aws_eip.eip_Australia.id
  subnet_id     = aws_subnet.public-ap-southeast-2a.id
  provider = aws.australia

  tags = {
    Name = "nat_Australia"
  }

  depends_on = [aws_internet_gateway.igw_AUS]
}


#-----------------------------------------------#
#
# Public Network

resource "aws_route_table" "public_Australia" {
  vpc_id = aws_vpc.VPC-E-Australia-Test.id
  provider = aws.australia

  route   {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw_AUS.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }
  
    tags = {
    Name = "public_Australia"
  }
}

#-----------------------------------------------#
#
# These are for the public subnets.

resource "aws_route_table_association" "public-ap-southeast-2a" {
  subnet_id      = aws_subnet.public-ap-southeast-2a.id
  route_table_id = aws_route_table.public_Australia.id
  provider = aws.australia
}

resource "aws_route_table_association" "public-ap-southeast-2b" {
  subnet_id      = aws_subnet.public-ap-southeast-2b.id
  route_table_id = aws_route_table.public_Australia.id
  provider = aws.australia
}

#-----------------------------------------------#
# Private Network



resource "aws_route_table" "private_Australia" {
  vpc_id = aws_vpc.VPC-E-Australia-Test.id
  provider = aws.australia
  
  route  {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat_Australia.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }

# This route is to pass traffic to Tokyo Security Zone VPC.
route  {
      cidr_block                 = "10.0.0.0/8"
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = aws_ec2_transit_gateway.VPC-E-AUS-TGW01.id
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }

  tags = {
    Name = "private_Australia"
  }
}


# These are for the private subnets.

resource "aws_route_table_association" "private-ap-southeast-2a" {
  subnet_id      = aws_subnet.private-ap-southeast-2a.id
  route_table_id = aws_route_table.private_Australia.id
  provider = aws.australia
}

resource "aws_route_table_association" "private-ap-southeast-2b" {
  subnet_id      = aws_subnet.private-ap-southeast-2b.id
  route_table_id = aws_route_table.private_Australia.id
  provider = aws.australia
}

#------------------------------------------------------------#
# Security group for Load Balancer

resource "aws_security_group" "ASG01-SG01-AUS-LB01" {
    name = "ASG01-SG01-AUS-LB01"
    description = "Allow HTTP inbound traffic to Load Balancer."
    vpc_id = aws_vpc.VPC-E-Australia-Test.id
    provider = aws.australia

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
        Name = "ASG01-SG01-AUS-LB01"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security Group for Automatic Scaling Group
resource "aws_security_group" "ASG01-SG02-AUS-TG80" {
    name = "ASG01-SG02-AUS-TG80"
    description = "allow traffic to ASG"
    vpc_id = aws_vpc.VPC-E-Australia-Test.id
    provider = aws.australia


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
        Name = "ASG01-SG02-AUS-TG80"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security group for EC2 Virtual Machines
resource "aws_security_group" "ASG01-SG03-AUS-servers" {
    name = "ASG01-SG03-AUS-servers"
    description = "Allow SSH and HTTP traffic to production servers"
    vpc_id = aws_vpc.VPC-E-Australia-Test.id
    provider = aws.australia

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
        Name = "ASG01-SG03-AUS-servers"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


#----------------------------------------------#
# Target Groups

resource "aws_lb_target_group" "ASG01_AUS_TG01" {
  name     = "ASG01-Australia-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC-E-Australia-Test.id
  target_type = "instance"
  provider = aws.australia

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
    Name    = "ASG01-AUS-TG01"
    Service = "ASG"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}


#------------------------------------------------#
# Load Balancer

resource "aws_lb" "ASG01-AUS-LB01" {
  name               = "ASG01-Australia-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ASG01-SG01-AUS-LB01.id]
  subnets            = [
    aws_subnet.public-ap-southeast-2a.id,
    aws_subnet.public-ap-southeast-2b.id
  ]

  provider = aws.australia

  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "ASG01-AUS-LB01"
    Service = "App1"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}

resource "aws_lb_listener" "http_AUS" {
  load_balancer_arn = aws_lb.ASG01-AUS-LB01.arn
  port              = 80
  protocol          = "HTTP"

  provider = aws.australia

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ASG01_AUS_TG01.arn
  }
}



#----------------------------------------------------------------#
# Autoscaling Group

resource "aws_autoscaling_group" "ASG01_AUS" {
  name_prefix           = "ASG01-Australia-auto-scaling-group"
  min_size              = 1
  max_size              = 5
  desired_capacity      = 2
  vpc_zone_identifier   = [
    aws_subnet.private-ap-southeast-2a.id,
    aws_subnet.private-ap-southeast-2b.id
  ]

  provider = aws.australia
  
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.ASG01_AUS_TG01.arn]

  launch_template {
    id      = aws_launch_template.app1_Australia_LT.id
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
    value               = "app1-AUS-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "app1_AUS_scaling_policy" {
  name                   = "app1-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.ASG01_AUS.name

  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  provider = aws.australia
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

# Enabling instance scale-in protection
resource "aws_autoscaling_attachment" "ASG01_AUS_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ASG01_AUS.name
  alb_target_group_arn   = aws_lb_target_group.ASG01_AUS_TG01.arn
  provider = aws.australia
}
