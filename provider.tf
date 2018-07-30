provider "aws" {
  access_key = "${var.accesKey}"
  secret_key = "${var.secretKey}"
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
    availability_zone = "${lookup(var.aza, var.region)}"

    tags {
        Name = "testAws-public-1"
    }
}
resource "aws_subnet" "testAws-public-2" {
    vpc_id = "${aws_vpc.testAws.id}"
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone = "${lookup(var.azb, var.region)}"

    tags {
        Name = "testAws-public-2"
    }
}

resource "aws_subnet" "testAws-private-1" {
    vpc_id = "${aws_vpc.testAws.id}"
    cidr_block = "10.0.2.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "${lookup(var.aza, var.region)}"

    tags {
        Name = "testAws-private-1"
    }
}
resource "aws_subnet" "testAws-private-2" {
    vpc_id = "${aws_vpc.testAws.id}"
    cidr_block = "10.0.3.0/24"
    map_public_ip_on_launch = "false"
    availability_zone = "${lookup(var.azc, var.region)}"

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

resource "aws_instance" "publicweb1" {
  ami           = "${lookup(var.images, var.region)}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.testAws-public-1.id}"
  vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
  key_name = "${aws_key_pair.mykeypair.key_name}"
  tags {
    Name = "webserver1"
  }
}

resource "aws_instance" "publiweb2" {
  ami           = "${lookup(var.images, var.region)}"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.testAws-public-2.id}"
  vpc_security_group_ids = ["${aws_security_group.webserver.id}"]
  key_name = "${aws_key_pair.mykeypair.key_name}"

  tags {
    Name = "webserver2"
  }
}

# key
resource "aws_key_pair" "mykeypair" {
  key_name = "corekey2"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_lb" "webserver" {
  name = "Alb1"
  internal = false
  load_balancer_type = "application"
  security_groups = ["${aws_security_group.webserver.id}"]
  subnets = ["${aws_subnet.testAws-public-1.id}" , "${aws_subnet.testAws-public-2.id}"]
}

resource "aws_lb_target_group" "webserver" {
  name = "target_group"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_vpc.testAws.id}"
}

resource "aws_lb_listener" "webserver" {
  load_balancer_arn = "${aws_lb.webserver.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = "${aws_lb_target_group.webserver.arn}"
    type = "forward"
  }
}

resource "aws_lb_target_group_attachment" "webserver1" {
  target_group_arn = "${aws_lb_target_group.webserver.arn}"
  target_id = "${aws_instance.publicweb1.id}"
  port = 80
}

resource "aws_lb_target_group_attachment" "webserver2" {
  target_group_arn = "${aws_lb_target_group.webserver.arn}"
  target_id = "${aws_instance.publiweb2.id}"
  port = 80
}
