
# VPC

resource "aws_vpc" "VPC-B-NewYork-Test" {
    provider = aws.newyork
    cidr_block = "10.21.0.0/16"
  

  tags = {
    Name = "VPC-B-NewYork-Test"
    Service = "application1"
    Owner = "Frodo"
    Planet = "Arda"
  }
}


#------------------------------------------------------------#
# Subnets
# New York VPC Public IP space.

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                  = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block              = "10.21.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  provider = aws.newyork

  tags = {
    Name    = "public-us-east-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                  = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block              = "10.21.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  provider = aws.newyork

  tags = {
    Name    = "public-us-east-1b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

# New York Private IP space.

resource "aws_subnet" "private-us-east-1a" {
  vpc_id            = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block        = "10.21.11.0/24"
  availability_zone = "us-east-1a"
  provider = aws.newyork

  tags = {
    Name    = "private-us-east-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id            = aws_vpc.VPC-B-NewYork-Test.id
  cidr_block        = "10.21.12.0/24"
  availability_zone = "us-east-1b"
  provider = aws.newyork

  tags = {
    Name    = "private-us-east-1b"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

#---------------------------------------------------------#
# IGW

resource "aws_internet_gateway" "igw_NY" {
  vpc_id = aws_vpc.VPC-B-NewYork-Test.id

  tags = {
    Name    = "application_NY_IGW"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}


#-----------------------------------------------#
# NAT

resource "aws_eip" "eip_NY" {
  vpc = true
  provider = aws.newyork

  tags = {
    Name = "eip_NY"
  }
}


resource "aws_nat_gateway" "nat_NY" {
  allocation_id = aws_eip.eip_NY.id
  subnet_id     = aws_subnet.public-us-east-1a.id
  provider = aws.newyork

  tags = {
    Name = "nat_NY"
  }

  depends_on = [aws_internet_gateway.igw_NY]
}



#---------------------------------------------------------------#
# Routes

resource "aws_route_table" "private_NY" {
  vpc_id = aws_vpc.VPC-B-NewYork-Test.id
  
  route  {
      cidr_block                 = "10.19.0.0/16"
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      # instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = aws_ec2_transit_gateway.VPC-B-NewYork-Test-TGW01.id
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    }


  route  {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.nat_NY.id
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

  tags = {
    Name = "private_NY"
  }

}

resource "aws_route_table" "public_NY" {
  vpc_id = aws_vpc.VPC-B-NewYork-Test.id

  route   {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.igw_NY.id
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
    Name = "public_NY"
  }
}

#-----------------------------------------------#
#
# These are for the private subnets.

resource "aws_route_table_association" "private-us-east-1a" {
  subnet_id      = aws_subnet.private-us-east-1a.id
  route_table_id = aws_route_table.private_NY.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id      = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private_NY.id
}

#-----------------------------------------------#
#
# These are for the public subnets.

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id      = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public_NY.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id      = aws_subnet.public-us-east-1b.id
  route_table_id = aws_route_table.public_NY.id
}



#----------------------------------------------------#
# Security Groups

# Security group for Load Balancer

resource "aws_security_group" "ASG01-SG01-NY-LB01" {
    name = "ASG01-SG01-NY-LB01"
    description = "Allow HTTP inbound traffic to Load Balancer."
    vpc_id = aws_vpc.VPC-B-NewYork-Test.id
    provider = aws.newyork

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
        Name = "ASG01-SG01-NY-LB01"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security Group for Automatic Scaling Group
resource "aws_security_group" "ASG01-SG02-NY-TG80" {
    name = "ASG01-SG02-NY-TG80"
    description = "allow traffic to ASG"
    vpc_id = aws_vpc.VPC-B-NewYork-Test.id
    provider = aws.newyork

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
        Name = "ASG01-SG02-NY-TG80"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


# Security group for EC2 Virtual Machines
resource "aws_security_group" "ASG01-SG03-NY-servers" {
    name = "ASG01-SG03-NY-servers"
    description = "Allow SSH and HTTP traffic to production servers"
    vpc_id = aws_vpc.VPC-B-NewYork-Test.id
    provider = aws.newyork

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
        Name = "ASG01-SG03-NY-servers"
        Service = "application1"
        Owner = "Frodo"
        Planet = "Arda"
    }
}


#----------------------------------------------#
# Target Groups

resource "aws_lb_target_group" "ASG01_NY_TG01" {
  name     = "ASG01-NewYork-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC-B-NewYork-Test.id
  target_type = "instance"
  provider = aws.newyork

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
    Name    = "ASG01-NY-TG01"
    Service = "ASG01-NY"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}

#------------------------------------------------------------------#
# Load Balancer

resource "aws_lb" "ASG01-NY-LB01" {
  name               = "ASG01-NewYork-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ASG01-SG01-NY-LB01.id]
  subnets            = [
    aws_subnet.public-us-east-1a.id,
    aws_subnet.public-us-east-1b.id
  ]
  enable_deletion_protection = false
#Lots of death and suffering here, make sure it's false

  tags = {
    Name    = "ASG01-NY-LB01"
    Service = "App1"
    Owner   = "Frodo"
    Project = "Web Service"
  }
}

resource "aws_lb_listener" "http_NY" {
  load_balancer_arn = aws_lb.ASG01-NY-LB01.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ASG01_NY_TG01.arn
  }
}



#-------------------------------------------------------------------#
# ASG

resource "aws_autoscaling_group" "ASG01_NY" {
  name_prefix           = "ASG01-NewYork-auto-scaling-group"
  min_size              = 1
  max_size              = 5
  desired_capacity      = 2
  vpc_zone_identifier   = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
  ]

  provider = aws.newyork
  
  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete               = true
  target_group_arns          = [aws_lb_target_group.ASG01_NY_TG01.arn]

  launch_template {
    id      = aws_launch_template.app1_NewYork_LT.id
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
    value               = "app1-NY-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "Production"
    propagate_at_launch = true
  }
}


# Auto Scaling Policy
resource "aws_autoscaling_policy" "app1_NY_scaling_policy" {
  name                   = "app1-cpu-target"
  autoscaling_group_name = aws_autoscaling_group.ASG01_NY.name

  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = 120

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 75.0
  }
}

# Enabling instance scale-in protection
resource "aws_autoscaling_attachment" "ASG01_NY_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ASG01_NY.name
  alb_target_group_arn   = aws_lb_target_group.ASG01_NY_TG01.arn
}








