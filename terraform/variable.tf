
variable "terraform_version" {
  description = "To get the version of terraform"
  default = {
    "v1" = "1.8.5"  # Version must be specified as a string.
  }
}

variable "provider_aws_version" {
  description = "this variable is to provide aws provider plugin version"
  default     = ">= 5.0.0" #  Version must be specified as a string.
  /* default = {
    "v5" = ">= 5.0.0"    # version = var.provider_aws_version.v5 Version must be specified as a string.
    "v4" = ">= 4.0.0"
 */
}

variable "provider_aws_source" {
  description = "this variable is to provide aws provider plug in source"
  default = {   #   Source must be specified as a string.
    "official" = "hashicorp/aws" # Official AWS provider source
    "custom" = "example.com/custom/provider" #Using a Custom Provider Source
    "local" = "local/local_provider" #Using a Local Provider Plugin

  }
}

variable "aws_region" {
  description = "this variable is used to provide aws regions"
  default = {
    "North-America" = "us-east-1"
    "South-America" = "sa-east-1"
    "Europe" = "us-central-1"
    "Asia" = "ap-northeast-1"
    "Africa" = "f-south-1"
  }
}

variable "aws_az" {
  description = "this variable is used to provide availablity zones"
  default = {
    "North-America" = "us-east-1a"
    "South-America" = "sa-east-1a"
    "Europe" = "us-central-1a"
    "Asia" = "ap-northeast-1a"
    "Africa" = "f-south-1a"
  }
}

variable "terraform_aws_profile" {
  description = "this variable is used to provide aws credentials profile"
  type = list(string)
  default = ["project", "east", "west"]
  /*   13:   profile = var.terraform_aws_profile.project
│     ├────────────────
│     │ var.terraform_aws_profile is a list of string
│
│ This value does not have any attributes. */
}

variable "ports_in" {
  description = "mention all the ports that can and should  be allowed for inbound"
  default = [80, 8080, 22, 443, 7761, 9000, 465]
}

variable "ports_out" {
  description = "mention all the ports that can and should  be allowed for outbound"
  default = [80, 8080, 22, 443, 7761, 9000, 465]
}

variable "ami_ids" {
  description = "List of Free Tier eligible AMI IDs"
  type = map(string)
  default = {
    "Amazon_Linux" = "ami-012967cc5a8c9f891"
    "RHEL" = "ami-0583d8c7a9c35822c"
    "SUSE" = "ami-0cd60fd97301e4b49"
    "Ubuntu" = "ami-005fc0f236362e99f "
    "Windows" = "ami-05e9c8b8d9ad7b4e1"
  }
}

variable "instance_type" {
  description = "this variable is used for provideing machine type"
  default = "t2.micro"
}

variable "instance_names" {
  description = "List of names for the EC2 instances"
  default     = {
    "jenkins-master" = "jenkins-master"
    "jenkins-slave" = "jenkins-slave"
    "sonar" = "sonar"
    "ansible-controller" = "ansible-controller"
    "k8s-master" = "k8s-master"
    "k8s-slave" = "k8s-slave"
    "k8s-slave1" = "k8s-slave1"
  }
}
