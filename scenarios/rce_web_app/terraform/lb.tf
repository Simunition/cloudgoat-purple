#Security Groups
resource "aws_security_group" "cg-lb-http-security-group" {
  name = "cg-lb-http-${local.cgid_suffix}"
  description = "CloudGoat ${var.cgid} Security Group for Application Load Balancer over HTTP"
  vpc_id = "${var.vpc_id}"
  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = var.cg_whitelist
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
    Name = "cg-lb-http-${local.cgid_suffix}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
#Application Load Balancer
resource "aws_lb" "cg-lb" {
  name = "cg-lb-${local.cgid_suffix}"
  internal = false
  load_balancer_type = "application"
  ip_address_type = "ipv4"
  access_logs {
      bucket = "${aws_s3_bucket.cg-logs-s3-bucket.bucket}"
      prefix = "cg-lb-logs"
      enabled = true
  }
  security_groups = [
      "${aws_security_group.cg-lb-http-security-group.id}"
  ]
  subnets = [
      "${var.public_subnet_1}",
      "${var.public_subnet_2}"
  ]
  tags = {
      Name = "cg-lb-${var.cgid}"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}
#Target Group
resource "aws_lb_target_group" "cg-target-group" {
  # Note: the name cannot be more than 32 characters
  name = "cg-tg-${local.cgid_suffix}"
  port = 9000
  protocol = "HTTP"
  vpc_id = "${var.vpc_id}"
  target_type = "instance"
  tags = {
    Name = "cg-target-group-${local.cgid_suffix}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
#Target Group Attachment
resource "aws_lb_target_group_attachment" "cg-target-group-attachment" {
  target_group_arn = "${aws_lb_target_group.cg-target-group.arn}"
  target_id = "${aws_instance.cg-ubuntu-ec2.id}"
  port = 9000
}
#Load Balancer Listener
resource "aws_lb_listener" "cg-lb-listener" {
  load_balancer_arn = "${aws_lb.cg-lb.arn}"
  port = 80
  default_action {
      type = "forward"
      target_group_arn = "${aws_lb_target_group.cg-target-group.arn}"
  }
}