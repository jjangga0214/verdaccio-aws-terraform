resource "random_string" "pure" {
  length  = 24
  special = false
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = "true"

  tags = {
    Name  = "verdaccio-vpc-${random_string.pure.result}"
    Owner = "verdaccio"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name  = "verdaccio-igw"
    Owner = "verdaccio"
  }
}

# Define the route table
resource "aws_route_table" "rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    # ipv6_cidr_block can only used to egress only internet gateway.
    # refer: https://github.com/hashicorp/terraform/issues/13363
    # ipv6_cidr_block = "::/0"
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name  = "verdaccio-rt"
    Owner = "verdaccio"
  }

}

resource "aws_subnet" "subnet" {
  vpc_id     = "${aws_vpc.vpc.id}"
  cidr_block = "10.0.0.0/24"

  availability_zone       = var.aws_az
  map_public_ip_on_launch = "true"

  tags = {
    Name  = "verdaccio-subnet"
    Owner = "verdaccio"
  }

}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "rt_subnet_association" {
  subnet_id      = "${aws_subnet.subnet.id}"
  route_table_id = "${aws_route_table.rt.id}"
}

resource "aws_security_group" "allow_basic" {
  name        = "verdaccio-sg-allow-basic"
  description = "Allow icmp, ssh inbound and unlimited outbound traffic"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    # ref: https://github.com/hashicorp/terraform/issues/1313
    from_port        = 8
    to_port          = 0
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    # every ports, all protocol is allowed to all destination cidr
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "verdaccio-sg-allow-basic"
    Owner = "verdaccio"
  }
}

resource "aws_security_group" "allow_verdaccio" {
  name        = "verdaccio-sg-allow-verdaccio"
  description = "Allow verdaccio inbound"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = var.port
    to_port          = var.port
    protocol         = var.protocol
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name  = "verdaccio-sg-allow-verdaccio"
    Owner = "verdaccio"
  }

}
