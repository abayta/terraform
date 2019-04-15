resource "aws_vpc" "hotelbeds-custom-vpc" {
    cidr_block = "10.0.0.0/16"
    instance_tenancy = "default"
    enable_dns_support = "true"
    enable_dns_hostnames = "true"   
    tags {
        Name = "HotelBeds-custom-vpc"
    }
}

# Internet GW
resource "aws_internet_gateway" "hotelbeds-igw" {
    vpc_id = "${aws_vpc.hotelbeds-custom-vpc.id}"

    tags {
        Name = "Hotelbeds-custom-igw"
    }
}