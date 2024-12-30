# VPC
resource "aws_vpc" "VPC-G-California-Test" {
    provider = aws.california
    cidr_block = "10.26.0.0/16"

  tags = {
    Name = "VPC-G-California-Test"
    Service = "application1"
    Owner = "Frodo"
    Planet = "Arda"
  }
}


#------------------------------------------------------#
# Subnets

# California Public IP Space.

resource "aws_subnet" "public-us-west-1a" {
  vpc_id                  = aws_vpc.VPC-G-California-Test.id
  cidr_block              = "10.26.1.0/24"
  availability_zone       = "us-west-1a"
  map_public_ip_on_launch = true
  provider = aws.california

  tags = {
    Name    = "public-us-west-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "public-us-west-1b" {
  vpc_id                  = aws_vpc.VPC-G-California-Test.id
  cidr_block              = "10.26.2.0/24"
  availability_zone       = "us-west-1b"
  map_public_ip_on_launch = true
  provider = aws.california

  tags = {
    Name    = "public-us-west-1b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

# California Private IP space.

resource "aws_subnet" "private-us-west-1a" {
  vpc_id                  = aws_vpc.VPC-G-California-Test.id
  cidr_block              = "10.26.11.0/24"
  availability_zone       = "us-west-1a"
  provider = aws.california


  tags = {
    Name    = "private-us-west-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "private-us-west-1b" {
  vpc_id                  = aws_vpc.VPC-G-California-Test.id
  cidr_block              = "10.26.12.0/24"
  availability_zone       = "us-west-1b"
  provider = aws.california


  tags = {
    Name    = "private-us-west-1b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw_CALI" {
  vpc_id = aws_vpc.VPC-G-California-Test.id
  provider = aws.california


  tags = {
    Name    = "application1_CALI_IGW"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}


#---------------------------------------------------#
# NAT
resource "aws_eip" "eip_California" {
  vpc = true
  provider = aws.california

  tags = {
    Name = "eip_California"
  }
}


resource "aws_nat_gateway" "nat_California" {
  allocation_id = aws_eip.eip_California.id
  subnet_id     = aws_subnet.public-us-west-1a.id
  provider = aws.california

  tags = {
    Name = "nat_California"
  }

  depends_on = [aws_internet_gateway.igw_CALI]
}



# Routes
#
# Public Network

resource "aws_route_table" "public_California" {
  vpc_id = aws_vpc.VPC-G-California-Test.id
  provider = aws.california

  route   {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw_CALI.id
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
    Name = "public_California"
  }
}

#-----------------------------------------------#
#
# These are for the public subnets.

resource "aws_route_table_association" "public-us-west-1a" {
  subnet_id      = aws_subnet.public-us-west-1a.id
  route_table_id = aws_route_table.public_California.id
  provider = aws.california
}

resource "aws_route_table_association" "public-us-west-1b" {
  subnet_id      = aws_subnet.public-us-west-1b.id
  route_table_id = aws_route_table.public_California.id
  provider = aws.california
}

#-----------------------------------------------#
# Private Network



resource "aws_route_table" "private_California" {
  vpc_id = aws_vpc.VPC-G-California-Test.id
  provider = aws.california
  
  
  route  {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat_California.id
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
      transit_gateway_id         = aws_ec2_transit_gateway.VPC-G-California-TGW01.id
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }

  tags = {
    Name = "private_California"
  }
}


# These are for the private subnets.

resource "aws_route_table_association" "private-us-west-1a" {
  subnet_id      = aws_subnet.private-us-west-1a.id
  route_table_id = aws_route_table.private_California.id
  provider = aws.california
}

resource "aws_route_table_association" "private-us-west-1b" {
  subnet_id      = aws_subnet.private-us-west-1b.id
  route_table_id = aws_route_table.private_California.id
  provider = aws.california
}


#--------------------------------------------------#
# Security group for Load Balancer

resource "aws_security_group" "ASG01-SG01-CALI-LB01" {
    name = "ASG01-SG01-CALI-LB01"
    description = "Allow HTTP inbound traffic to Load Balancer."
    vpc_id = aws_vpc.VPC-G-California-Test.id
    provider = aws.california

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
        Name = "ASG01-SG01-CALI-LB01"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security Group for Automatic Scaling Group
resource "aws_security_group" "ASG01-SG02-CALI-TG80" {
    name = "ASG01-SG02-CALI-TG80"
    description = "allow traffic to ASG"
    vpc_id = aws_vpc.VPC-G-California-Test.id
    provider = aws.california


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
        Name = "ASG01-SG02-CALI-TG80"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security group for EC2 Virtual Machines
resource "aws_security_group" "ASG01-SG03-CALI-servers" {
    name = "ASG01-SG03-CALI-servers"
    description = "Allow SSH and HTTP traffic to production servers"
    vpc_id = aws_vpc.VPC-G-California-Test.id
    provider = aws.california

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
        Name = "ASG01-SG03-CALI-servers"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


#----------------------------------------------#
# Target Groups

resource "aws_lb_target_group" "ASG01_CALI_TG01" {
  name     = "ASG01-California-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC-G-California-Test.id
  target_type = "instance"
  provider = aws.california

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
    Name    = "ASG01-CALI-TG01"
    Service = "ASG"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}

#------------------------------------------------#
# Load Balancer

resource "aws_lb" "ASG01-CALI-LB01" {
  name               = "ASG01-California-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ASG01-SG01-CALI-LB01.id]
  subnets            = [
    aws_subnet.public-us-west-1a.id,
    aws_subnet.public-us-west-1b.id
  ]

  provider = aws.california

  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "ASG01-CALI-LB01"
    Service = "App1"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}

resource "aws_lb_listener" "http_CALI" {
  load_balancer_arn = aws_lb.ASG01-CALI-LB01.arn
  port              = 80
  protocol          = "HTTP"

  provider = aws.california

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ASG01_CALI_TG01.arn
  }
}

#-------------------------------------------------------------------#
# Auto Scaling Group

resource "aws_autoscaling_group" "ASG01_CALI" {
  name_prefix           = "ASG01-California-auto-scaling-group"
  min_size              = 1
  max_size              = 5
  desired_capacity      = 2
  vpc_zone_identifier   = [
    aws_subnet.private-us-west-1a.id,
    aws_subnet.private-us-west-1b.id
  ]

  provider = aws.california
  
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.ASG01_CALI_TG01.arn]

  launch_template {
    id      = aws_launch_template.app1_California_LT.id
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
    value               = "app1-CALI-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "app1_CALI_scaling_policy" {
  name                   = "app1-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.ASG01_CALI.name

  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  provider = aws.california

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

# Enabling instance scale-in protection
resource "aws_autoscaling_attachment" "ASG01_CALI_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ASG01_CALI.name
  alb_target_group_arn   = aws_lb_target_group.ASG01_CALI_TG01.arn
  provider = aws.california
}

