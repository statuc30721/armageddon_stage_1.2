
# Retrieve the latest Amazon Linux AMI.

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name = "architecture"
    values = ["x86_64"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]

  }
}

output "aws-ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}





#---------------------------------------------------------#
# Tokyo Region

resource "aws_launch_template" "app1_Tokyo_LT" {
    name_prefix = "app1_Tokyo_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    image_id = "ami-023ff3d4ab11b2525"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ASG01-SG03-TYO-servers.id]
    key_name = "linux_appserver_key"
    provider = aws.tokyo

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "app1_TYO_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}

# SYSLOG server in Tokyo Region

resource "aws_launch_template" "SYSLOG_Tokyo_LT" {
    name_prefix = "SYSLOG_Tokyo_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    # image_id = "ami-023ff3d4ab11b2525"
    #image_id = "ami-0feb2a784522625ae"
    image_id = "ami-0daf917272499a192"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.SG01-CYBER-TYO-SYSLOG.id]
    key_name = "linux_appserver_key"
    provider = aws.tokyo

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script-syslog.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "SYSLOG_TYO_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}

#-----------------------------------------------------#
# New York Region

resource "aws_launch_template" "app1_NewYork_LT" {
    name_prefix = "app1_NY_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    image_id = "ami-0453ec754f44f9a4a"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ASG01-SG03-NY-servers.id]
    key_name = "linux_appserver_key"
    provider = aws.newyork

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "app1_NY_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}


#--------------------------------------------#
# London Region
resource "aws_launch_template" "app1_London_LT" {
    name_prefix = "app1_LON_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    image_id = "ami-0c76bd4bd302b30ec"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ASG01-SG03-LONDON-servers.id]
    key_name = "linux_appserver_key"
    provider = aws.london

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "app1_LON_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}


#---------------------------------------------------------------------#
# Sao Paulo Region
resource "aws_launch_template" "app1_SaoPaulo_LT" {
    name_prefix = "app1_SAO_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    image_id = "ami-0c820c196a818d66a"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ASG01-SG03-SAO-servers.id]
    key_name = "linux_appserver_key"
    provider = aws.saopaulo

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "app1_SAO_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}


#-----------------------------------------------------#
# Australia
resource "aws_launch_template" "app1_Australia_LT" {
    name_prefix = "app1_AUS_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    image_id = "ami-0146fc9ad419e2cfd"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ASG01-SG03-AUS-servers.id]
    key_name = "linux_appserver_key"
    provider = aws.australia

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "app1_AUS_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}


#-----------------------------------------------------#
# Hong Kong Region
resource "aws_launch_template" "app1_HongKong_LT" {
    name_prefix = "app1_HK_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    image_id = "ami-06f707739f2271995"
    # Hong Kong does not have the t2.micro in that region as of 6 December 2024.
    instance_type = "t3.micro"
    vpc_security_group_ids = [aws_security_group.ASG01-SG03-HongKong-servers.id]
    key_name = "linux_appserver_key"
    provider = aws.hongkong

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "app1_HK_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}


#-------------------------------------------------------#
# California Region

resource "aws_launch_template" "app1_California_LT" {
    name_prefix = "app1_CALI_LT"
    #image_id = data.aws_ami.latest-amazon-linux-image.id
    image_id = "ami-038bba9a164eb3dc1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.ASG01-SG03-CALI-servers.id]
    key_name = "linux_appserver_key"
    provider = aws.california

# Install software on the Amazon EC2 Instance.
# This calls a local script which runs on each EC2 VM instance.

user_data = base64encode(file("./entry-script.sh"))
    
    tag_specifications {
        resource_type = "instance"
        tags = {
          Name = "app1_CALI_LT"
          Service = "application1"
          Owner = "Frodo"
          Planet = "Arda"     
          }
        }
    
    lifecycle {
        create_before_destroy = true
    }
}

