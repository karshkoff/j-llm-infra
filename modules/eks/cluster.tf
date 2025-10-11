# Cluster

resource "aws_eks_cluster" "main" {
  name    = var.cluster_name
  version = var.cluster_version

  role_arn = aws_iam_role.cluster_role.arn

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  vpc_config {
    subnet_ids = var.private_subnet_ids
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = var.tags
}

# Node Group

resource "aws_eks_node_group" "main" {
  node_group_name = "${var.cluster_name}-node-group"
  cluster_name    = aws_eks_cluster.main.name
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  capacity_type = "SPOT"
  # instance_types = ["g5g.xlarge"]
  instance_types = ["t3.small"]

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node-AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = var.tags
}
