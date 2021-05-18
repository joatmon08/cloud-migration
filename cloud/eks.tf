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
  version          = "16.0.0"
  cluster_name     = var.datacenter
  cluster_version  = "1.18"
  subnets          = module.vpc.private_subnets
  write_kubeconfig = false
  manage_aws_auth  = false

  tags = local.tags

  vpc_id = module.vpc.vpc_id

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  node_groups = {
    application = {
      desired_capacity = 3
      max_capacity     = 3
      min_capacity     = 3

      instance_type = "t2.small"
      k8s_labels    = local.tags
    }
  }
}

## Need to run: kubectl set env daemonset -n kube-system aws-node AWS_VPC_K8S_CNI_EXTERNALSNAT=true
## See https://docs.aws.amazon.com/eks/latest/userguide/external-snat.html