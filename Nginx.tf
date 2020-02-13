##################################################################################
# Variables
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {
    default = "Terraform.pem"
}
variable "key_name" {
  default = "Terraform"
}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}


##################################################################################
# RESOURCES
##################################################################################
#security group for aws
resource "aws_security_group" "nginx_sg" {
  name          = "nginx_sg"
  description   = "security group for nginx from terraform"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami           = "ami-07ebfd5b3428b6f4d"
  instance_type = "t2.micro"
  key_name        = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.nginx_sg.id}"]
  associate_public_ip_address = "true"

  connection {
    user        = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host = "${aws_instance.nginx.public_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install nginx -y",
      "sudo service nginx start"
     ]
  }
}
##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
    value = "http://${aws_instance.nginx.public_dns}:80"
}

output "aws_instance_public_ip"{
    value = "${aws_instance.nginx.private_ip}"
}
