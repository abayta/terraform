resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.hotelbeds-custom-vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.hotelbeds-igw.id}"
    }

    tags {
        Name = "public"
    }
}

resource "aws_route_table" "private" {
    vpc_id = "${aws_vpc.hotelbeds-custom-vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat-gw.id}"
    }
    
    tags {
        Name = "private"
    }
}

# route associations public
resource "aws_route_table_association" "public1-a" {
    subnet_id = "${aws_subnet.public1.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public2-b" {
    subnet_id = "${aws_subnet.public2.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public3-c" {
    subnet_id = "${aws_subnet.public3.id}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private-1-a" {
    subnet_id = "${aws_subnet.private1.id}"
    route_table_id = "${aws_route_table.private.id}"
}
resource "aws_route_table_association" "private-1-b" {
    subnet_id = "${aws_subnet.private2.id}"
    route_table_id = "${aws_route_table.private.id}"
}