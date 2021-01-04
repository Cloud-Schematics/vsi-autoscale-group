##############################################################################
# IBM Cloud Provider
##############################################################################

provider ibm {
  ibmcloud_api_key      = var.ibmcloud_api_key
  region                = var.ibm_region
  generation            = 2
  ibmcloud_timeout      = 60
}

##############################################################################


##############################################################################
# VPC Data Block
##############################################################################

data ibm_is_vpc vpc {
    name = var.vpc_name
}

##############################################################################


##############################################################################
# data ibm_resource_group
##############################################################################

data ibm_resource_group group {
  name = var.resource_group
}

##############################################################################

##############################################################################
# Create Subnets
##############################################################################

data ibm_is_subnet subnet {
  count      = length(var.subnet_ids)
  identifier = var.subnet_ids[count.index]
}

##############################################################################