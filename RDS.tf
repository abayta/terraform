resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "db-subnet-group"
  subnet_ids = ["${aws_subnet.public1.id}",
                "${aws_subnet.public2.id}", 
                "${aws_subnet.public3.id}"]

  tags = {
    Name = "My DB subnet group"
  }
}
