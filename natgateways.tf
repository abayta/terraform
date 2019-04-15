resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.ip-nat-gw.id}"
  subnet_id     = "${aws_subnet.public1.id}"
}
