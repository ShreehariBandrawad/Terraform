# creating vpc

resource "aws_vpc" "velocity-non-prod" {

  cidr_block = "10.10.0.0/16"

  tags = {
    Name = "velocity-non-prod"
  }
}

# creating subnets

resource "aws_subnet" "devops-subnet" {
  vpc_id     = "${aws_vpc.velocity-non-prod.id}"
  cidr_block = "10.10.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "devops-subnet"
  }

}

resource "aws_subnet" "dev-subnet" {
  vpc_id     = "${aws_vpc.velocity-non-prod.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "dev-subnet"
  }

}

resource "aws_subnet" "qa-subnet" {
  vpc_id     = "${aws_vpc.velocity-non-prod.id}"
  cidr_block = "10.10.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "qa-sunet"
  }

}


# creating internet-gateway

resource "aws_internet_gateway" "velocity-non-prod-igw" {
  vpc_id = "${aws_vpc.velocity-non-prod.id}"

  tags = {
    Name = "velocity-non-prod-igw"
  }

}

# creating route-table

resource "aws_route_table" "velocity-non-prod-public-RT" {
  vpc_id = "${aws_vpc.velocity-non-prod.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.velocity-non-prod-igw.id}"
  }

   tags = {
    Name = "velocity-non-prod-public-RT"
  }

}

# route-table association

resource "aws_route_table_association" "devops-subnet" {
  subnet_id      = "${aws_subnet.devops-subnet.id}"
  route_table_id = "${aws_route_table.velocity-non-prod-public-RT.id}"
}

resource "aws_route_table_association" "dev-subnet" {
  subnet_id      = "${aws_subnet.dev-subnet.id}"
  route_table_id = "${aws_route_table.velocity-non-prod-public-RT.id}"
}

resource "aws_route_table_association" "qa-subnet" {
  subnet_id      = "${aws_subnet.qa-subnet.id}"
  route_table_id = "${aws_route_table.velocity-non-prod-public-RT.id}"


}

#creating Security group

resource "aws_security_group" "velocity-non-prod-sg" {
  name        = "velocity-non-prod-sg"
  description = "Allow SSH and HTTP APP PORT"
  vpc_id      = "${aws_vpc.velocity-non-prod.id}"

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
  # APP PORT (8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
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

  tags = {
    Name = "velocity-non-prod-sg"
  }

}
#creating Instances

resource "aws_instance" "devops-JM" {
  ami           = "ami-098e39bafa7e7303d"
  instance_type = "t2.micro"
  key_name   = "Northkey"
  subnet_id     = "${aws_subnet.devops-subnet.id}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.velocity-non-prod-sg.id
  ]

  tags = {
    Name = "devops-JM"
  }

}

resource "aws_instance" "dev-1-Env" {
  ami           = "ami-098e39bafa7e7303d"
  instance_type = "t2.micro"
  key_name   = "Northkey"
  subnet_id     = "${aws_subnet.dev-subnet.id}"
   associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.velocity-non-prod-sg.id
  ]

   tags = {
    Name = "dev-1-Env"
  }

}

resource "aws_instance" "qa-1-Env" {
  ami           = "ami-098e39bafa7e7303d"
  instance_type = "t2.micro"
  key_name   = "Northkey"
  subnet_id     = "${aws_subnet.qa-subnet.id}"
   associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.velocity-non-prod-sg.id
  ]

   tags = {
    Name = "qa-1-Env"
  }

}

