resource "aws_key_pair" "johweb_keypair" {
	key_name = "johweb_keypair"
	public_key = "${var.THE_PUB_KEY}"
}

resource "aws_instance" "johweb-ec2-pub1" {
	ami = "${var.WEBSRV_AMI_ID}"
	instance_type = "t2.micro"      
	subnet_id = aws_subnet.johweb-pub-1.id
	key_name = "johweb_keypair"
	vpc_security_group_ids = [aws_security_group.johweb-pub1-proxyserver-SG.id]
	iam_instance_profile = "johweb-ec2-pub1"
	tags = {
		Name = "johweb-ec2-pub1",
		server_type = "web_server"
	}
}


output "johweb-PublicIP" {
	value = aws_instance.johweb-ec2-pub1.public_ip
}

resource "aws_instance" "johweb-bastion-pub1" {
	ami = "${var.WEBSRV_AMI_ID}"
	instance_type = "t2.nano"
	subnet_id = aws_subnet.johweb-pub-1.id
	key_name = "johweb_keypair"
	vpc_security_group_ids = [aws_security_group.johweb-pub1-proxyserver-SG.id]
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
	vpc_security_group_ids = [aws_security_group.johweb-pub1-bastion-SG.id]
	tags = {
                Name = "johweb-proxy-pub1",
		server_type = "web_server"
        }
}

output "bastion-PublicIP" {
        value = aws_instance.johweb-bastion-pub1.public_ip
}

######

