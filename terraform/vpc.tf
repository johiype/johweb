resource "aws_vpc" "johweb" {
	cidr_block = "10.0.0.0/16"
	instance_tenancy = "default"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	tags = {
		Name = "johweb-vpc"
	}
}

resource "aws_subnet" "johweb-pub-1" {
	vpc_id = aws_vpc.johweb.id
	cidr_block = "10.0.10.0/24"
	map_public_ip_on_launch = "true"
	availability_zone = var.ZONE1
	tags = {
		Name = "johweb-pubsubnet-1"
	}
}

resource "aws_subnet" "johweb-priv-1" {
	vpc_id = aws_vpc.johweb.id
	cidr_block = "10.0.20.0/24"
	availability_zone = var.ZONE1
	tags = {
		Name = "johweb-privsubnet-1"
	}
}

resource "aws_internet_gateway" "johweb-IGW" {
	vpc_id = aws_vpc.johweb.id
	tags = {
		Name = "johweb-IGW"
	}
}

resource "aws_route_table" "johweb-pub-RT" {
	vpc_id = aws_vpc.johweb.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.johweb-IGW.id
	}
	
	tags = {
		Name = "johweb-pub-RT"
	}
}

resource "aws_route_table_association" "johweb-RTA-pub-1" {
	subnet_id = aws_subnet.johweb-pub-1.id
	route_table_id = aws_route_table.johweb-pub-RT.id
}

# Private route table for private subnet 1
resource "aws_route_table" "johweb-priv-RT" {
  vpc_id = aws_vpc.johweb.id
  tags = {
    Name = "johweb-priv-RT"
  }
}

resource "aws_route_table_association" "johweb-RTA-priv-1" {
        subnet_id = aws_subnet.johweb-priv-1.id
        route_table_id = aws_route_table.johweb-priv-RT.id
}

resource "aws_route" "outbound-nat-route" {
  route_table_id         = aws_route_table.johweb-priv-RT.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.johweb-bastion-pub1.primary_network_interface_id
}
