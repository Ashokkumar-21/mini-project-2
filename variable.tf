variable "aws_region" {
    description = "AWs Region"
    type = string
    default = "ap-south-1"
}

variable "key_name" {
    description = "EC2 Keypair"
    type = string
    default = "vmamzkey01"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "mini2-cluster"
}

variable "eks_instance_type" {
  type    = string
  default = "t2.micro"
}

variable "ec2_ami" {
  type    = string
  default = "ami-0f918f7e67a3323f0"
}

variable "eks_node_count" {
  type    = number
  default = 1
}