# Databse VPC
# The database assets will only reside in the priovate subnet IP space.

resource "aws_vpc" "VPC-DB" {
    
    provider = aws.tokyo
    cidr_block = "10.18.0.0/16"

  tags = {
    Name = "VPC-DB"
    Service = "application1"
    Owner = "Frodo"
    Planet = "Arda"
  }
}





# Tokyo Private IP space.

resource "aws_subnet" "private-db-ap-northeast-1a" {
  vpc_id                  = aws_vpc.VPC-DB.id
  cidr_block              = "10.18.51.0/24"
  availability_zone       = "ap-northeast-1a"
  provider = aws.tokyo
  
  tags = {
    Name    = "private-db-ap-northeast-1a"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

resource "aws_subnet" "private-db-northeast-1c" {
  vpc_id                  = aws_vpc.VPC-DB.id
  cidr_block              = "10.18.52.0/24"
  availability_zone       = "ap-northeast-1c"
  provider = aws.tokyo

  tags = {
    Name    = "private-db-northeast-1c"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}

#--------------------------------------------------------#
# IGW

resource "aws_internet_gateway" "DB_VPC_TYO_IGW" {

  vpc_id = aws_vpc.VPC-DB.id
  provider = aws.tokyo


  tags = {
    Name    = "DB_VPC_TYO_IGW"
    Service = "application1"
    Owner   = "Frodo"
    Planet  = "Arda"
  }
}




#----------------------------------------------------#
# Subnets
#

#-----------------------------------------------#
# Private Network


resource "aws_route_table" "private_DB_VPC_Tokyo" {
  vpc_id = aws_vpc.VPC-DB.id
  provider = aws.tokyo
  


#-----------------------------------------------#
# Added Transit Gateway to allow database to be reached from other Virtual Private
# Clouds.

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
    Name = "private_DB_VPC_Tokyo"
  }
}


# These are for the private subnets.

resource "aws_route_table_association" "private-db-ap-northeast-1a" {
  subnet_id      = aws_subnet.private-db-ap-northeast-1a.id
  route_table_id = aws_route_table.private_DB_VPC_Tokyo.id
  provider = aws.tokyo
}

resource "aws_route_table_association" "private-db-northeast-1c" {
  subnet_id      = aws_subnet.private-db-northeast-1c.id
  route_table_id = aws_route_table.private_DB_VPC_Tokyo.id
  provider = aws.tokyo
}


#---------------------------------------------------------------------#
# Security Groups
#
#
resource "aws_security_group" "Aurora-DB-SG01" {
    name = "Aurora-DB-SG01"
    description = "Allow inbound raffic to database server."
    vpc_id = aws_vpc.VPC-DB.id
    provider = aws.tokyo

    ingress {
        description = "MYSQL/Aurora"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["10.0.0.0/8"]
    }
       egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
  }

    tags = {
        Name = "Aurora-DB-SG01"
        Service = "Aurora Datbase Service"
        Owner = "Frodo"
        Planet = "Arda"
    }
}

#---------------------------------------------------------------------#
# Database Instance

resource "aws_rds_cluster" "pii_db_cluster" {
  cluster_identifier = "pii-db-cluster"
  engine = "aurora-mysql"

  # Set availability zones
  # availability_zones = ["ap-northeast-1a", "ap-northeast-1c"]

  # Set database name.
  database_name = "pii_database"

  # The username and passwords should be set in a variable file and updated 
  # by the appropriate database manager.
  master_username = "admin"
  master_password = "badpassword123"

  # Create a random password. 
  # create_random_password = true

  # Set the backup retention period to 0 days to avoid snapshot creation. 
  # We delete them anyway during destruction.
  backup_retention_period = 1 

  # Set VPC security group.

  vpc_security_group_ids = [aws_security_group.Aurora-DB-SG01.id]

  # Set database subnet group name.
  db_subnet_group_name = aws_db_subnet_group.db_vpc_subnet_group.name

  # Set storage encryption to false for this deployment.
  storage_encrypted = false

  # Apply changes immediately. Use with caution as this can impact applications
  # that may be writing to the database server.
  apply_immediately = true

  # Delete autopmated backups. Seeing error message when running 
  # terraform validate   Error: Unsupported argument
  #  on tokyo-DB-VPC.tf line 305, in resource "aws_rds_cluster" "pii_db_cluster":
  # 305:   delete_automated_backups = true
  #
  # An argument named "delete_automated_backups" is not expected here.

  # Need to investigate if this is caused by my terraform or a missing setting.
  # delete_automated_backups = true

  # Dont protect this development database from being deleted.
  deletion_protection = false

  # Set deletion of skip final snapshot creation when the database is being destroyed.
  skip_final_snapshot = true

  # Set provider here since we have multiple regions in main configuration.
  provider = aws.tokyo

  # 
  
  tags = {
    Environment = "development"
    Service = "MySQL Database"
    Purpose = "AWS RDS learning"
  }
}


# Create our database cluster instance.
resource "aws_rds_cluster_instance" "pii_db_cluster_instance" {
  count = 1
  cluster_identifier = aws_rds_cluster.pii_db_cluster.cluster_identifier
  apply_immediately = true
  # identifier = "pii-db-cluster-instance-${count.index}"
  instance_class = "db.r5.large"
  engine = "aurora-mysql"
  db_subnet_group_name = aws_db_subnet_group.db_vpc_subnet_group.name
  provider = aws.tokyo
  publicly_accessible = false

}


resource "aws_db_subnet_group" "db_vpc_subnet_group" {
    name = "db-vpc-subnet-group"
    subnet_ids = [aws_subnet.private-db-ap-northeast-1a.id, aws_subnet.private-db-northeast-1c.id]
    provider = aws.tokyo

    tags = {
        Name = "Aurora DB VPC Subnet Group"
    }
  
}