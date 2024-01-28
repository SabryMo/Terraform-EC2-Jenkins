provider "aws" {
  region  = var.aws_region
  # access_key = ""        //you can hard-coding credintial here, but isn't recommended and risky. 
  # secret_key = ""


}

//AWS EC2 Instance
resource "aws_instance" "my-ec2" {
  ami = "ami-0022f774911c1d690"
  instance_type = var.ec2_instance_type
  availability_zone = "us-east-1a"
  key_name = "my-key" //Create Key pair and write down the name here

  

  network_interface { //We will create later (my_network_int)
     device_index         = 0
     network_interface_id = aws_network_interface.my_network_int.id
   }
  tags = {
    Name = "jenkins-server"
  }

  user_data = <<-EOF
          #!/bin/bash -xe
          sudo yum update -y
          sudo yum install wget
          sudo amazon-linux-extras install java-openjdk11
          sudo amazon-linux-extras install epel -y
          sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
          sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
          sudo yum install jenkins -y
          sudo service jenkins start
          # sudo exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
          # sudo printf "\n\nJenkins initial Admin Password\n"
          # sudo cat /var/lib/jenkins/secrets/initialAdminPassword
          EOF
}

//AWS VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "dev-vpc"
  }
}

//AWS Subnet
resource "aws_subnet" "my_subnet" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    "Name" = "dev-subnet"
  }
}

//Aws Internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "dev-gw"
  }
}

//AWS Route Table
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "dev-rt"
  }
}

//Association between a route table and a subnet
resource "aws_route_table_association" "a_rt_subnet" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_rt.id
}

//AWS Security Group
resource "aws_security_group" "my_sg" {
  name        = "allow_my_webapp"
  description = "Allow webapp inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description      = "HTTPS Access"
    from_port        = 8080  //jenkins web port 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] //Allow access from any where
    ipv6_cidr_blocks = ["::/0"]
  }

  #   ingress {
  #   description      = "HTTP Access"
  #   from_port        = 80
  #   to_port          = 80
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

    ingress {
    description      = "SSH Access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] 
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1" // -1 means All/Any protocols
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "dev-sg"
  }
}

// AWS Network Interface
resource "aws_network_interface" "my_network_int" {
  subnet_id       = aws_subnet.my_subnet.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.my_sg.id]

  tags = {
    Name = "my-network-interface"
  }
/*
  attachment {
    instance     = aws_instance.my-ec2.id
    device_index = 1
  }
*/
}

//Public IP
resource "aws_eip" "lb" {
  instance = aws_instance.my-ec2.id
  vpc      = true
}
