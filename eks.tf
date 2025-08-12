resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids         = [aws_subnet.private.id, aws_subnet.public.id]
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_attach
  ]
}

# Security group for EKS control plane communication
resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-eks-cluster-sg"
  description = "EKS cluster security group"
  vpc_id      = aws_vpc.main.id

  # Allow worker nodes to communicate with control plane
  ingress {
    description      = "Worker nodes to EKS Control Plane"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_security_group.eks_node_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.cluster_name}-eks-cluster-sg" }
}

# EKS Node Group
resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-ng"
  node_role_arn   = aws_iam_role.eks_node.arn

  # Use both subnets so nodes can join without NAT trouble
  subnet_ids = [aws_subnet.public.id]

  scaling_config {
    desired_size = var.eks_node_count
    max_size     = var.eks_node_count + 1
    min_size     = 1
  }

  instance_types = ["t2.micro"]

  remote_access {
    ec2_ssh_key               = var.key_name
    source_security_group_ids = [aws_security_group.ec2_sg.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_attach,
    aws_iam_role_policy_attachment.eks_cni_attach,
    aws_iam_role_policy_attachment.ecr_readonly
  ]
}

data "aws_eks_cluster" "cluster" {
  name = aws_eks_cluster.eks.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.eks.name
}