locals {
  repo     = "aws-workshop"
  sufix    = "rmc-2023"
  dev_name = "${local.repo}-dev-${local.sufix}"
  prd_name = "${local.repo}-prd-${local.sufix}"
}
