resource "aws_key_pair" "johweb_keypair" {
	key_name = "johweb_keypair"
	public_key = "${var.THE_PUB_KEY}"
}

resource "aws_instance" "johweb-ec2-priv1" {
	ami = "${var.WEBSRV_AMI_ID}"
	instance_type = "t2.micro"      
	subnet_id = aws_subnet.johweb-priv-1.id
	key_name = "johweb_keypair"
	vpc_security_group_ids = [aws_security_group.johweb-priv1-webserver-SG.id]
	iam_instance_profile = "johweb-ec2-pub1"   # need to change name of IAM role in future
	tags = {
		Name = "johweb-ec2-priv1",
		server_type = "web_server"
	}
}


output "johweb-PublicIP" {
	value = aws_instance.johweb-ec2-priv1.private_ip
}

#resource "aws_instance" "johweb-bastion-pub1" {
#	ami = "${var.WEBSRV_AMI_ID}"
#	instance_type = "t2.nano"
#	subnet_id = aws_subnet.johweb-pub-1.id
#	key_name = "johweb_keypair"
#	vpc_security_group_ids = [aws_security_group.johweb-pub1-bastion-SG.id]
#	tags = {
#		Name = "johweb-bastion-pub1",
#	server_type = "bastion_host"
#	}
# }

# Network Interface Created for Bastion Host, so we can disbale source destionation check for fck-nat
resource "aws_network_interface" "johweb-bastion-networkinterface" { 
  subnet_id       = aws_subnet.johweb-pub-1.id
  security_groups = [aws_security_group.johweb-pub1-bastion-SG.id]

  # disabling source destination check
  source_dest_check = false
}

resource "aws_instance" "johweb-bastion-pub1" {
        ami = "${var.BASTION_AMI_ID}"
        instance_type = "t2.nano"
        #subnet_id = aws_subnet.johweb-pub-1.id
        key_name = "johweb_keypair"
        #vpc_security_group_ids = [aws_security_group.johweb-pub1-bastion-SG.id]

	network_interface {
		network_interface_id = aws_network_interface.johweb-bastion-networkinterface.id
		device_index         = 0
	  } 
	
        tags = {
                Name = "johweb-bastion-pub1",
                server_type = "bastion_host"
        }
}

resource "aws_instance" "johweb-proxy-pub1" {
	ami = "${var.WEBSRV_AMI_ID}"
	instance_type = "t2.nano"
	subnet_id = aws_subnet.johweb-pub-1.id
	key_name = "johweb_keypair"
	vpc_security_group_ids = [aws_security_group.johweb-pub1-proxyserver-SG.id]
	tags = {
                Name = "johweb-proxy-pub1",
		server_type = "web_server"
        }
}

output "bastion-PublicIP" {
        value = aws_instance.johweb-bastion-pub1.public_ip
}

######
