# All Regions are in this file for ease of making configuration changes.
#

# Identify peer region. For some odd reason this was required versus 
# input of "us-east-1".

data "aws_region" "tokyo" {
    provider = aws.tokyo
  
}

#=====================================================================#
# This is the Transit Gateway for the Tokyo Region.

resource "aws_ec2_transit_gateway" "Tokyo-Region-TGW" {
    auto_accept_shared_attachments = "enable"
   #default_route_table_association = "enable"
   #default_route_table_propagation = "enable"
    dns_support = "enable"
    description = "tokyo Regional transit gateway"
    provider = aws.tokyo

    tags = {
      Name = "Tokyo Regional TGW"
    }
}

#=====================================================================#
# Transit Gateway Attachment
# Attach Tokyo Security Zone VPC to Tokyo Regional Transit Gateway.
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-Cyber-Tokyo-TGA" {
    subnet_ids = [aws_subnet.private-cyber-ap-northeast-1d.id]
    transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id
    vpc_id = aws_vpc.VPC-Cyber-Tokyo.id
    provider = aws.tokyo
    
    tags = {
      Name = "VPC-Cyber-Tokyo-TGA"
    }
}

#=====================================================================#
# Transit Gateway Attachment
# Attach Database VPC to Tokyo Regional Transit Gateway.

resource "aws_ec2_transit_gateway_vpc_attachment" "DB-VPC-TGA01" {
    subnet_ids = [aws_subnet.private-db-ap-northeast-1a.id, aws_subnet.private-db-northeast-1c.id]
    transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id
    vpc_id = aws_vpc.VPC-DB.id
    provider = aws.tokyo
    
    tags = {
      Name = "DB-VPC-TGA01"
    }
}

#=====================================================================#
# Transit Gateway Attachment
# Attach Tokyo VPC A to Tokyo Regional Transit Gateway.

resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-A-Tokyo-TGA01" {
    subnet_ids = [aws_subnet.private-ap-northeast-1a.id, aws_subnet.private-ap-northeast-1c.id]
    transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id
    vpc_id = aws_vpc.VPC-A-Tokyo-Test.id
    provider = aws.tokyo
    
    tags = {
      Name = "VPC-A-Tokyo-TGA01"
    }
}

#=====================================================================#
# Transit Gateway New York VPC
# This is the New York Transit Gateway.

resource "aws_ec2_transit_gateway" "VPC-B-NewYork-Test-TGW01" {
    auto_accept_shared_attachments = "enable"
   #default_route_table_association = "enable"
   #default_route_table_propagation = "enable"
    dns_support = "enable"
    description = "New York Transit Gateway"
    provider = aws.newyork

    tags = {
      Name = "VPC-B-NewYork-Test-TGW01"
    }
}

# Transit Gateway Attachment
# Connect VPC-B-NewYork to Transit Gateway. This is a VPC attachment type.
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-B-NewYork-US-EAST-1A-TGA01" {
    subnet_ids = [aws_subnet.private-us-east-1a.id, aws_subnet.private-us-east-1b.id]
    transit_gateway_id = aws_ec2_transit_gateway.VPC-B-NewYork-Test-TGW01.id
    vpc_id = aws_vpc.VPC-B-NewYork-Test.id
    provider = aws.newyork
    
    tags = {
      Name = "VPC-B-NY-US-EAST-1A-TGA01"
    }
}


# Create a transit gateway peering attachment to the  Tokyo Security VPC.

resource "aws_ec2_transit_gateway_peering_attachment" "NY-to-CYBER-Tokyo" {
    # This is New York VPC intitiating peer connection to Cyber Tokyo.
    # peer_account_id = aws_ec2_transit_gateway.VPC-B-NewYork-Test-TGW01.owner_id

    # Region of EC2 Transit Gateway that we want to peer with. So in this instance
    # we are initiating a peer connection to the Tokyo CYBER Virtual Private Cloud.
    peer_region = data.aws_region.tokyo.name

    # Identifier of EC2 Transit Gateway that we want to peer with.
    peer_transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id

    # Identifier of the EC2 Transit Gateway of the initiator of the peering connection.
    transit_gateway_id = aws_ec2_transit_gateway.VPC-B-NewYork-Test-TGW01.id
    

    tags = {
      Name = "TGW Peering Requestor from NewYork"
    }
}

# We want Tokyo Regional Transit Gateway to accept peer request from New York VPC.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Accept-NY-Peer" {
    provider = aws.tokyo

    transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.NY-to-CYBER-Tokyo.id
   
    tags = {
      Name = "NewYork-Ingress"
      Side = "Accepter"
    }
  
}

# Create STATIC route from  New York VPC to Tokyo CYBER VPC.

resource "aws_ec2_transit_gateway_route" "NewYork-TokyoCYBER" {
    provider = aws.newyork
    destination_cidr_block         = "10.19.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-NY-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.VPC-B-NewYork-Test-TGW01.association_default_route_table_id
}

# Create STATIC route from  Tokyo Regional to New York VPC.

resource "aws_ec2_transit_gateway_route" "TokyoCYBER-NewYork" {
    provider = aws.tokyo
    destination_cidr_block         = "10.21.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-NY-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.association_default_route_table_id
}


#=====================================================================#
# Transit Gateway London VPC

resource "aws_ec2_transit_gateway" "VPC-C-London-Test-TGW01" {
    auto_accept_shared_attachments = "enable"
   #default_route_table_association = "enable"
   #default_route_table_propagation = "enable"
    dns_support = "enable"
    description = "London VPC transit gatewayW"
    provider = aws.london

    tags = {
      Name = "VPC-C-London-Test-TGW01"
    }
}

# Transit Gateway Attachment
# Attach transit gateway to the VPC.
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-C-London-TGA01" {
    subnet_ids = [aws_subnet.private-eu-west-2a.id,aws_subnet.private-eu-west-2b.id]
    transit_gateway_id = aws_ec2_transit_gateway.VPC-C-London-Test-TGW01.id
    vpc_id = aws_vpc.VPC-C-London-Test.id
    provider = aws.london
    
    tags = {
      Name = "VPC-C-London-TGA01"
    }
}

# Create a transit gateway peering attachment to Cyber Tokyo VPC.



resource "aws_ec2_transit_gateway_peering_attachment" "LON-to-CYBER-Tokyo" {

    peer_region = data.aws_region.tokyo.name

    # Identifier of EC2 Transit Gateway that we want to peer with.
    peer_transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id

    # Identifier of the EC2 Transit Gateway of the initiator of the peering connection.
    transit_gateway_id = aws_ec2_transit_gateway.VPC-C-London-Test-TGW01.id
    
    provider = aws.london

    tags = {
      Name = "TGW Peering Requestor from London"
    }
}

# We want Tokyo CYBER Transit Gateway to accept peer request from London VPC.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Accept-LON-Peer" {
    provider = aws.tokyo

    transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.LON-to-CYBER-Tokyo.id
   

    tags = {
      Name = "London-Ingress"
      Side = "Accepter"
    }
  
}

# Create STATIC route from  London VPC to Tokyo CYBER VPC.

resource "aws_ec2_transit_gateway_route" "London-TokyoCYBER" {
    provider = aws.london
    destination_cidr_block         = "10.19.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-LON-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.VPC-C-London-Test-TGW01.association_default_route_table_id
}

# Create STATIC route from  Tokyo Regional to New York VPC.

resource "aws_ec2_transit_gateway_route" "TokyoCYBER-London" {
    provider = aws.tokyo
    destination_cidr_block         = "10.22.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-LON-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.association_default_route_table_id
}



#=====================================================================#
# Transit Gateway Sao Paulo VPC

resource "aws_ec2_transit_gateway" "VPC-D-SaoPaulo-TGW01" {
    auto_accept_shared_attachments = "enable"
   #default_route_table_association = "enable"
   #default_route_table_propagation = "enable"
    dns_support = "enable"
    description = "Sao Paulo VPC transit gatewayW"
    provider = aws.saopaulo

    tags = {
      Name = "VPC-D-SaoPaulo-TGW01"
    }
}

# Transit Gateway Attachment
# Attach transit gateway to the VPC.
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-D-SaoPaulo-TGA01" {
    subnet_ids = [aws_subnet.private-sa-east-1a.id,aws_subnet.private-sa-east-1c.id]
    transit_gateway_id = aws_ec2_transit_gateway.VPC-D-SaoPaulo-TGW01.id
    vpc_id = aws_vpc.VPC-D-SaoPaolo-Test.id
    provider = aws.saopaulo
    
    tags = {
      Name = "VPC-D-SaoPaulo-TGA01"
    }
}

# Create a transit gateway peering attachment to Cyber Tokyo VPC.


resource "aws_ec2_transit_gateway_peering_attachment" "SAO-to-CYBER-Tokyo" {

    peer_region = data.aws_region.tokyo.name

    # Identifier of EC2 Transit Gateway that we want to peer with.
    peer_transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id

    # Identifier of the EC2 Transit Gateway of the initiator of the peering connection.
    transit_gateway_id = aws_ec2_transit_gateway.VPC-D-SaoPaulo-TGW01.id
    
    provider = aws.saopaulo

    tags = {
      Name = "TGW Peering Requestor from Sao Paulo"
    }
}

# We want Tokyo CYBER Transit Gateway to accept peer request from Sao Paulo VPC.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Accept-SAO-Peer" {
    provider = aws.tokyo

    transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.SAO-to-CYBER-Tokyo.id
   

    tags = {
      Name = "SaoPaulo-Ingress"
      Side = "Accepter"
    }
  
}

# Create STATIC route from  Sao Paulo VPC to Tokyo CYBER VPC.

resource "aws_ec2_transit_gateway_route" "SaoPaulo-TokyoCYBER" {
    provider = aws.saopaulo
    destination_cidr_block         = "10.19.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-SAO-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.VPC-D-SaoPaulo-TGW01.association_default_route_table_id
}

# Create STATIC route from  Tokyo Regional to Sao Paulo VPC.

resource "aws_ec2_transit_gateway_route" "TokyoCYBER-SaoPaulo" {
    provider = aws.tokyo
    destination_cidr_block         = "10.23.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-SAO-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.association_default_route_table_id
}


#=====================================================================#
# Transit Gateway Australia VPC

resource "aws_ec2_transit_gateway" "VPC-E-AUS-TGW01" {
    auto_accept_shared_attachments = "enable"
   #default_route_table_association = "enable"
   #default_route_table_propagation = "enable"
    dns_support = "enable"
    description = "Australia VPC transit gatewayW"
    provider = aws.australia

    tags = {
      Name = "VPC-D-AUS-TGW01"
    }
}

# Transit Gateway Attachment
# Attach transit gateway to the VPC.
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-E-AUS-TGA01" {
    subnet_ids = [aws_subnet.private-ap-southeast-2a.id, aws_subnet.private-ap-southeast-2b.id]
    transit_gateway_id = aws_ec2_transit_gateway.VPC-E-AUS-TGW01.id
    vpc_id = aws_vpc.VPC-E-Australia-Test.id
    provider = aws.australia
    
    tags = {
      Name = "VPC-E-AUS-TGA01"
    }
}

# Create a transit gateway peering attachment to Cyber Tokyo VPC.


resource "aws_ec2_transit_gateway_peering_attachment" "AUS-to-CYBER-Tokyo" {

    peer_region = data.aws_region.tokyo.name

    # Identifier of EC2 Transit Gateway that we want to peer with.
    peer_transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id

    # Identifier of the EC2 Transit Gateway of the initiator of the peering connection.
    transit_gateway_id = aws_ec2_transit_gateway.VPC-E-AUS-TGW01.id
    
    provider = aws.australia

    tags = {
      Name = "TGW Peering Requestor from Australia"
    }
}

# We want Tokyo CYBER Transit Gateway to accept peer request from Australia VPC.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Accept-AUS-Peer" {
    provider = aws.tokyo

    transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.AUS-to-CYBER-Tokyo.id
   

    tags = {
      Name = "Australia-Ingress"
      Side = "Accepter"
    }
  
}

# Create STATIC route from  Australia VPC to Tokyo CYBER VPC.

resource "aws_ec2_transit_gateway_route" "Australia-TokyoCYBER" {
    provider = aws.australia
    destination_cidr_block         = "10.19.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-AUS-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.VPC-E-AUS-TGW01.association_default_route_table_id
}

# Create STATIC route from  Tokyo Regional to Australia VPC.

resource "aws_ec2_transit_gateway_route" "TokyoCYBER-Australia" {
    provider = aws.tokyo
    destination_cidr_block         = "10.24.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-AUS-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.association_default_route_table_id
}

#=====================================================================#
# Transit Gateway Hong Kong VPC

resource "aws_ec2_transit_gateway" "VPC-F-HongKong-TGW01" {
    auto_accept_shared_attachments = "enable"
   #default_route_table_association = "enable"
   #default_route_table_propagation = "enable"
    dns_support = "enable"
    description = "Hong Kong VPC transit gatewayW"
    provider = aws.hongkong

    tags = {
      Name = "VPC-F-HongKong-TGW01"
    }
}

# Transit Gateway Attachment
# Attach transit gateway to the VPC.
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-F-HongKong-TGA01" {
    subnet_ids = [aws_subnet.private-ap-east-1a.id, aws_subnet.private-ap-east-1b.id]
    transit_gateway_id = aws_ec2_transit_gateway.VPC-F-HongKong-TGW01.id
    vpc_id = aws_vpc.VPC-F-HongKong-Test.id
    provider = aws.hongkong
    
    tags = {
      Name = "VPC-F-HongKong-TGA01"
    }
}

# Create a transit gateway peering attachment to Cyber Tokyo VPC.


resource "aws_ec2_transit_gateway_peering_attachment" "HK-to-CYBER-Tokyo" {

    peer_region = data.aws_region.tokyo.name

    # Identifier of EC2 Transit Gateway that we want to peer with.
    peer_transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id

    # Identifier of the EC2 Transit Gateway of the initiator of the peering connection.
    transit_gateway_id = aws_ec2_transit_gateway.VPC-F-HongKong-TGW01.id
    
    provider = aws.hongkong

    tags = {
      Name = "TGW Peering Requestor from Hong Kong"
    }
}

# We want Tokyo CYBER Transit Gateway to accept peer request from Hong Kong VPC.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Accept-HK-Peer" {
    provider = aws.tokyo

    transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.HK-to-CYBER-Tokyo.id
   

    tags = {
      Name = "HongKong-Ingress"
      Side = "Accepter"
    }
  
}

# Create STATIC route from  Hong Kong VPC to Tokyo CYBER VPC.

resource "aws_ec2_transit_gateway_route" "HongKong-TokyoCYBER" {
    provider = aws.hongkong
    destination_cidr_block         = "10.19.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-HK-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.VPC-F-HongKong-TGW01.association_default_route_table_id
}

# Create STATIC route from  Tokyo Regional to Hong Kong VPC.

resource "aws_ec2_transit_gateway_route" "TokyoCYBER-HongKong" {
    provider = aws.tokyo
    destination_cidr_block         = "10.25.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-HK-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.association_default_route_table_id
}

#=====================================================================#
# Transit Gateway California VPC

resource "aws_ec2_transit_gateway" "VPC-G-California-TGW01" {
    auto_accept_shared_attachments = "enable"
   #default_route_table_association = "enable"
   #default_route_table_propagation = "enable"
    dns_support = "enable"
    description = "California VPC transit gatewayW"
    provider = aws.california

    tags = {
      Name = "VPC-G-California-TGW01"
    }
}

# Transit Gateway Attachment
# Attach transit gateway to the VPC.
resource "aws_ec2_transit_gateway_vpc_attachment" "VPC-G-California-TGA01" {
    subnet_ids = [aws_subnet.private-us-west-1a.id, aws_subnet.private-us-west-1b.id]
    transit_gateway_id = aws_ec2_transit_gateway.VPC-G-California-TGW01.id
    vpc_id = aws_vpc.VPC-G-California-Test.id
    provider = aws.california
    
    tags = {
      Name = "VPC-G-California-TGA01"
    }
}

# Create a transit gateway peering attachment to Cyber Tokyo VPC.


resource "aws_ec2_transit_gateway_peering_attachment" "CALI-to-CYBER-Tokyo" {

    peer_region = data.aws_region.tokyo.name

    # Identifier of EC2 Transit Gateway that we want to peer with.
    peer_transit_gateway_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.id

    # Identifier of the EC2 Transit Gateway of the initiator of the peering connection.
    transit_gateway_id = aws_ec2_transit_gateway.VPC-G-California-TGW01.id
    
    provider = aws.california

    tags = {
      Name = "TGW Peering Requestor from California"
    }
}

# We want Tokyo CYBER Transit Gateway to accept peer request from California VPC.
resource "aws_ec2_transit_gateway_peering_attachment_accepter" "Accept-CALI-Peer" {
    provider = aws.tokyo

    transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.CALI-to-CYBER-Tokyo.id
   

    tags = {
      Name = "California-Ingress"
      Side = "Accepter"
    }
  
}

# Create STATIC route from  California VPC to Tokyo CYBER VPC.

resource "aws_ec2_transit_gateway_route" "California-TokyoCYBER" {
    provider = aws.california
    destination_cidr_block         = "10.19.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-CALI-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.VPC-G-California-TGW01.association_default_route_table_id
}

# Create STATIC route from  Tokyo Regional to California VPC.

resource "aws_ec2_transit_gateway_route" "TokyoCYBER-California" {
    provider = aws.tokyo
    destination_cidr_block         = "10.26.0.0/16"
    transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.Accept-CALI-Peer.id
    transit_gateway_route_table_id = aws_ec2_transit_gateway.Tokyo-Region-TGW.association_default_route_table_id
}
