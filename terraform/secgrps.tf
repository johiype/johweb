resource "aws_security_group" "johweb-pub1-bastion-SG" {
        name = "johweb-pub1-bastion-SG"
        vpc_id = aws_vpc.johweb.id
        description = "Port 22 open for SSH access from internet"

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }

        ingress {
                from_port = 0
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }

	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = [aws_vpc.johweb.cidr_block]
	}
}

resource "aws_security_group" "johweb-pub1-proxyserver-SG" {
	name = "johweb-pub1-proxyserver-SG"
	vpc_id = aws_vpc.johweb.id
	description = "Port 80 access to proxy server in the pub1 subnet, currently also used by main web server. Will change this soon ......"
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
      }

	ingress {
		from_port = 0
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
      }

        ingress {
                from_port = 0
                to_port = 22           
                protocol = "tcp"
                security_groups = [aws_security_group.johweb-pub1-bastion-SG.id]
      }

	ingress {
                from_port = 0
                to_port = 8080
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
      }


                tags = {
                        Name = "johweb-pub1-SG"
        }
}

resource "aws_security_group" "johweb-priv1-webserver-SG" {
        name = "johweb-priv1-webserver-SG"
        vpc_id = aws_vpc.johweb.id
        description = "Accept requests from Proxy Server and Bastion Host"

        egress {
                from_port = 0
                to_port = 0
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
      }

        ingress {
                from_port = 0
                to_port = 0
                protocol = "-1"
		cidr_blocks = [aws_subnet.johweb-pub-1.cidr_block]
                # security_groups = [aws_security_group.johweb-pub1-proxyserver-SG.id]
      }

	#ingress {
	#	from_port = 0
	#	to_port = 22
	#	protocol = "tcp"
	#	security_groups = [aws_security_group.johweb-pub1-bastion-SG.id]
	#}

	 tags = {
                        Name = "johweb-priv1-webserver-SG"
        }
}
