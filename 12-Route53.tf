
#
# Retrieve the DNS ZONE ID
data "aws_route53_zone" "main" {
    name    = "devlab405.click" # Domain name 
    private_zone = false
}

# Print to the console the DNS ZONE ID.
output "dns_zone" {
  value = data.aws_route53_zone.main
  
}

# Asia 
resource "aws_route53_record" "tokyo" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "app1.devlab405.click"
  type = "A"

  set_identifier = "ap-northeast-1"


# Sets geographical area to "default" for any query not 
# identified in any other region.

  geolocation_routing_policy {
    country = "*"
  }
 
 alias {
  name = aws_lb.ASG01-TYO-LB01.dns_name
  zone_id = aws_lb.ASG01-TYO-LB01.zone_id
  evaluate_target_health = true
   
 }
}


# East Coast USA Region

resource "aws_route53_record" "app1_NY" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "app1.devlab405.click"
  type = "A"

  set_identifier = "app1_NY"

# Sets gwographical area to North America.
  geolocation_routing_policy {
    continent = "NA"
  }

alias {
  name = aws_lb.ASG01-NY-LB01.dns_name
  zone_id = aws_lb.ASG01-NY-LB01.zone_id
  evaluate_target_health = true
   
 }
  
}



# Europe Region

resource "aws_route53_record" "app1_LON" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "app1.devlab405.click"
  type = "A"

  set_identifier = "europe-load-balancer"

# Sets geolocation to Europe.
  geolocation_routing_policy {
    continent = "EU"
  }

alias {
  name = aws_lb.ASG01-LON-LB01.dns_name
  zone_id = aws_lb.ASG01-LON-LB01.zone_id
  evaluate_target_health = true
   
 }
  
}



# South America Region
resource "aws_route53_record" "app1_SAO" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "app1.devlab405.click"
  type = "A"

  set_identifier = "app1_SAO"

# Sets geolocation to South America.
  geolocation_routing_policy {
    continent = "SA"
  }

alias {
  name = aws_lb.ASG01-SAO-LB01.dns_name
  zone_id = aws_lb.ASG01-SAO-LB01.zone_id
  evaluate_target_health = true
   
 }
  
}

# Australia Region
resource "aws_route53_record" "app1_AUS" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "app1.devlab405.click"
  type = "A"

  set_identifier = "app1_AUS"

# Sets geolocation to Australia.
  geolocation_routing_policy {
    country = "AU"
  }

alias {
  name = aws_lb.ASG01-AUS-LB01.dns_name
  zone_id = aws_lb.ASG01-AUS-LB01.zone_id
  evaluate_target_health = true
   
 }
  
}
# Hong Kong Region
resource "aws_route53_record" "app1_HK" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "app1.devlab405.click"
  type = "A"

  set_identifier = "app1_HK"

# Sets geolocation to Hong Kong.
  geolocation_routing_policy {
    country = "HK"
  }

alias {
  name = aws_lb.ASG01-HK-LB01.dns_name
  zone_id = aws_lb.ASG01-HK-LB01.zone_id
  evaluate_target_health = true
   
 }
  
}


# California Region
resource "aws_route53_record" "app1_CALI" {
  zone_id = data.aws_route53_zone.main.zone_id
  name = "app1.devlab405.click"
  type = "A"

  set_identifier = "app1_CALI"

# Sets geolocation to US West.
  geolocation_routing_policy {
    country = "US"
    subdivision = "CA"
  }

alias {
  name = aws_lb.ASG01-CALI-LB01.dns_name
  zone_id = aws_lb.ASG01-CALI-LB01.zone_id
  evaluate_target_health = true
   
 }
  
}