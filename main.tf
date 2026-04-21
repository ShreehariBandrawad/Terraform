# creating vpc

resource "aws_vpc" "testvpc" {
  cidr_block = "10.0.0.0/16"
}

# creating subnets

resource "aws_subnet" "subnet-a" {
  vpc_id     = "${aws_vpc.testvpc.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"
}

resource "aws_subnet" "subnet-b" {
  vpc_id     = "${aws_vpc.testvpc.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"
}

# creating internet-gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.testvpc.id}"
}

# creating route-table

resource "aws_route_table" "Public-route-table" {
  vpc_id = "${aws_vpc.testvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

}

# route-table association

resource "aws_route_table_association" "a1" {
  subnet_id      = "${aws_subnet.subnet-a.id}"
  route_table_id = "${aws_route_table.Public-route-table.id}"
}

resource "aws_route_table_association" "a2" {
  subnet_id      = "${aws_subnet.subnet-b.id}"
  route_table_id = "${aws_route_table.Public-route-table.id}"

}

#creating Security group

resource "aws_security_group" "test_sg" {
  name        = "test-sg"
  description = "Allow SSH and HTTP"
  vpc_id      = "${aws_vpc.testvpc.id}"

  #SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }
  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }	
  }

#creating Instances

resource "aws_instance" "Instance-1" {
  ami           = "ami-0a1b6a02658659c2a"
  instance_type = "t2.micro"
  key_name   = "Linuxohiokey"
  subnet_id     = "${aws_subnet.subnet-a.id}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.test_sg.id
  ]

  tags = {
    Name = "Instance-1"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install httpd -y
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Welcome to Instance 1</h1>" > /var/www/html/index.html
              chmod 777 /var/www/html/index.html
              EOF
}

resource "aws_instance" "Instance-2" {
  ami           = "ami-0a1b6a02658659c2a"
  instance_type = "t2.micro"
  key_name   = "Linuxohiokey"
  subnet_id     = "${aws_subnet.subnet-b.id}"
   associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.test_sg.id
  ]

   tags = {
    Name = "Instance-2"
  }

}

