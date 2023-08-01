#Security Group
resource "aws_security_group" "cg-rds-security-group" {
  name = "cg-rds-psql-${var.cgid}"
  description = "CloudGoat ${var.cgid} Security Group for PostgreSQL RDS Instance"
  vpc_id = "${aws_vpc.cg-vpc.id}"
  ingress {
      from_port = 5432
      to_port = 5432
      protocol = "tcp"
      cidr_blocks = [
          "10.2.0.0/16",
          "34.107.0.0/16"
      ]
  }
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [
          "0.0.0.0/0"
      ]
  }
  tags = {
    Name = "cg-rds-psql-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
#RDS Subnet Group
resource "aws_db_subnet_group" "cg-rds-subnet-group" {
  name = "cloud-goat-rds-subnet-group-${var.cgid}"
  subnet_ids = [
      "${var.private_subnet_1}",
      "${var.private_subnet_2}"
  ]
  description = "CloudGoat ${var.cgid} Subnet Group"
  tags = {
    Name = "cloud-goat-rds-subnet-group-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
#RDS PostgreSQL Instance
resource "aws_db_instance" "cg-psql-rds" {
  identifier = "cg-rds-instance-${local.cgid_suffix}"
  engine = "postgres"
  engine_version = "12"
  port = "5432"
  instance_class = "db.t2.micro"
  db_subnet_group_name = "${aws_db_subnet_group.cg-rds-subnet-group.id}"
  multi_az = false
  username = "${var.rds-username}"
  password = "${var.rds-password}"
  publicly_accessible = false
  vpc_security_group_ids = [
    "${aws_security_group.cg-rds-security-group.id}"
  ]
  storage_type = "gp2"
  allocated_storage = 20
  db_name = "cloudgoat"
  apply_immediately = true
  skip_final_snapshot = true

  tags = {
      Name = "cg-rds-instance-${var.cgid}"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
