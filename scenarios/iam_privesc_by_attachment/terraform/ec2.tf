#Security Groups
resource "aws_security_group" "cg-ec2-ssh-security-group" {
  name = "cg-ec2-ssh-${var.cgid}"
  description = "CloudGoat ${var.cgid} Security Group for EC2 Instance over SSH"
  vpc_id = "${var.vpc_id}"
  ingress {
      from_port = 22
      to_port = 22
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
    Name = "cg-ec2-ssh-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}
resource "aws_security_group" "cg-ec2-http-https-security-group" {
  name = "cg-ec2-http-${var.cgid}"
  description = "CloudGoat ${var.cgid} Security Group for EC2 Instance over HTTP"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = var.cg_whitelist
  }
  ingress {
      from_port = 443
      to_port = 443
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
    Name = "cg-ec2-http-${var.cgid}"
    Stack = "${var.stack-name}"
    Scenario = "${var.scenario-name}"
  }
}

#IAM Role
resource "aws_iam_role" "cg-ec2-Role" {
  name = "cg-ec2-Role-${var.cgid}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
      Name = "cg-ec2-Role-${var.cgid}"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}

#IAM Role Policy Attachments

resource "aws_iam_role_policy_attachment" "cg-ec2-Role-policy-attachment-ssm-core" {
  role = "${aws_iam_role.cg-ec2-Role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cg-ec2-Role-policy-attachment-ssm-patch" {
  role = "${aws_iam_role.cg-ec2-Role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}

resource "aws_iam_role_policy_attachment" "cg-ec2-Role-policy-attachment-custom-policy" {
  role = "${aws_iam_role.cg-ec2-Role.name}"
  policy_arn = "${var.cloudwatch_logging_policy_arn}" # Replace with your custom policy ARN
}

#IAM Instance Profile
resource "aws_iam_instance_profile" "cg-ec2-instance-profile" {
  name = "cg-ec2-instance-profile-${var.cgid}"
  role = "${aws_iam_role.cg-ec2-Role.name}"
}

#EC2 Instance
resource "aws_instance" "cg-super-critical-security-server" {
  ami = "ami-0a313d6098716f372"
  instance_type = "t2.micro"
  iam_instance_profile = "${aws_iam_instance_profile.cg-ec2-instance-profile.name}"
  subnet_id = "${var.private_subnet_1}"
  vpc_security_group_ids = [
      "${aws_security_group.cg-ec2-ssh-security-group.id}",
      "${aws_security_group.cg-ec2-http-https-security-group.id}"
  ]
  root_block_device {
      volume_type = "gp2"
      volume_size = 8
      delete_on_termination = true
  }
  volume_tags = {
      Name = "CloudGoat ${var.cgid} EC2 Instance Root Device"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
  tags = {
      Name = "CloudGoat ${var.cgid} super-critical-security-server EC2 Instance"
      Stack = "${var.stack-name}"
      Scenario = "${var.scenario-name}"
  }
}