
data "terraform_remote_state" "datacenter" {
  backend = "remote"

  config = {
    organization = var.tfc_organization
    workspaces = {
      name = var.tfc_workspace
    }
  }
}

module "boundary" {
  source            = "../../modules/boundary-deployment"
  vpc_id            = data.terraform_remote_state.datacenter.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.datacenter.outputs.public_subnet_ids
  name              = "boundary-dc"
  tags              = local.tags
}