provider "aws" {
  access_key = ""
  secret_key = ""
  region     = "${var.region}"
}

# Internet VPC
resource "aws_vpc" "testAws" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "false"
    enable_classiclink = "false"
    tags {
        Name = "Noborrar"
    }
}


# Subnets
resource "aws_subnet" "testAws-public-1" {
    vpc_id = "${aws_vpc.testAws.id}"
    cidr_block = "10.0.0.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-central-1a"

    tags {
        Name = "testAws-public-1"
    }
}
resource "aws_subnet" "testAws-public-2" {
    vpc_id = "${aws_vpc.testAws.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "eu-central-1b"

    tags {
        Name = "testAws-public-2"
    }
}

resource "aws_subnet" "testAws-private-1" {
    vpc_id = "${aws_vpc.testAws.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "eu-central-1a"

    tags {
        Name = "testAws-private-1"
    }
}
resource "aws_subnet" "testAws-private-2" {
    vpc_id = "${aws_vpc.testAws.id}"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "eu-central-1c"

    tags {
        Name = "testAws-private-2"
    }
}

# Internet GW
resource "aws_internet_gateway" "testAws-gw" {
    vpc_id = "${aws_vpc.testAws.id}"

    tags {
        Name = "TestAWSGateway"
    }
}

# route tables
resource "aws_route_table" "testAws-public" {
    vpc_id = "${aws_vpc.testAws.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.testAws-gw.id}"
    }

    tags {
        Name = "testAws-public-1"
    }
}

resource "aws_route_table" "testAws-private" {
    vpc_id = "${aws_vpc.testAws.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.testAws-gw.id}"
    }
    tags {
        Name = "testAws-private-1"
    }
}

# route associations public
resource "aws_route_table_association" "testAws-public-1-a" {
    subnet_id = "${aws_subnet.testAws-public-1.id}"
    route_table_id = "${aws_route_table.testAws-public.id}"
}
resource "aws_route_table_association" "testAws-public-2-a" {
    subnet_id = "${aws_subnet.testAws-public-2.id}"
    route_table_id = "${aws_route_table.testAws-public.id}"
}
resource "aws_route_table_association" "testAws-private-1-a" {
    subnet_id = "${aws_subnet.testAws-private-1.id}"
    route_table_id = "${aws_route_table.testAws-private.id}"
}
resource "aws_route_table_association" "testAws-private-1-b" {
    subnet_id = "${aws_subnet.testAws-private-2.id}"
    route_table_id = "${aws_route_table.testAws-private.id}"
}

# security groups
resource "aws_security_group" "webserver" {
  vpc_id = "${aws_vpc.testAws.id}"
  name = "webserver"
  description = "security group that allows http and ssh ingress and all egress"
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }  
tags {
    Name = "webserver"
  }
}

# instances

resource "aws_instance" "example" {
  ami           = "ami-c13952ae"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.testAws-private-1.id}"
  vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
  key_name = "${aws_key_pair.mykeypair.key_name}"
}

resource "aws_instance" "publiweb" {
  ami           = "ami-c13952ae"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.testAws-public-1.id}"
  vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
  key_name = "${aws_key_pair.mykeypair.key_name}"
}

# key
resource "aws_key_pair" "mykeypair" {
  key_name = "aba"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

