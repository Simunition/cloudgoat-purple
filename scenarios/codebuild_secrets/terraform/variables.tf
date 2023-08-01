#Required: AWS Profile
variable "profile" {

}
#Required: AWS Region
variable "region" {
  default = "us-east-1"
}
#Required: CGID Variable for unique naming
variable "cgid" {

}
#Example: RDS PostgreSQL Instance Credentials
variable "rds-username" {
  default = "cgadmin"
}
variable "rds-password" {
  default = "wagrrrrwwgahhhhwwwrrggawwwwwwrr"
}
variable "rds-database-name" {
  default = "securedb"
}
#SSH Public Key
variable "ssh-public-key-for-ec2" {
  default = "../cloudgoat.pub"
}
#Required: User's Public IP Address(es)
variable "cg_whitelist" {
  default = "../whitelist.txt"
}
#Stack Name
variable "stack-name" {
  default = "CloudGoat"
}
#Scenario Name
variable "scenario-name" {
  default = "codebuild-secrets"
}

locals {
  # Ensure the bucket suffix doesn't contain invalid characters
  # "Bucket names can consist only of lowercase letters, numbers, dots (.), and hyphens (-)."
  # (per https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)
  cgid_suffix = replace(var.cgid, "/[^a-z0-9-.]/", "-")
}

variable "vpc_id" {
  default = "vpc-02e26305f3cb78095"
}

variable "public_subnet_1" {
  default = "subnet-01db5dd6a0375742c"
}

variable "public_subnet_2" {
  default = "subnet-016a0f9e6be40659c"
}

variable "private_subnet_1" {
  default = "subnet-0fc338cadf4e2c7bb"
}

variable "private_subnet_2" {
  default = "subnet-0e7a277a7a539f4dd"
}

variable "cloudwatch_logging_policy_arn" {
  default = "arn:aws:iam::438826078296:policy/PublishCloudWatchLogs"
}