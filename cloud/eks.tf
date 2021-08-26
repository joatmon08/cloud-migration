locals {
  cluster_name = var.datacenter
}

data "aws_eks_cluster" "cluster" {
  provider = aws.cloud
  name     = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  provider = aws.cloud
  name     = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  providers = {
    aws = aws.cloud
  }
  source           = "terraform-aws-modules/eks/aws"
  version          = "17.3.0"
  cluster_name     = var.datacenter
  cluster_version  = "1.19"
  subnets          = module.vpc.private_subnets

  vpc_id           = module.vpc.vpc_id
  write_kubeconfig = false

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    primary = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3

      instance_types            = ["t2.small"]
      k8s_labels                = local.tags
    }
  }
}