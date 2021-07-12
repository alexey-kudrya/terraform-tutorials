provider "aws" {
    region = "us-east-2"
}

resource "aws_instance" "minikube" {
  ami           = "ami-00399ec92321828f5"
  instance_type = "t3.small"

  security_groups = [aws_security_group.minikube.name]

  key_name      = var.key_name

  ebs_block_device {
    device_name             = "/dev/sdg"
    volume_size             = 20
    volume_type             = "gp2"
    delete_on_termination   = true
  }

  user_data = "${file("install_minikube.sh")}"

  tags = {
    Name = "ubuntu-minikube"
  }
}

resource "aws_security_group" "minikube" {
  name = "minikube"
  description = "minikube rule"

  ingress {
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    description = "SSH"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

}