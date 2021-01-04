##############################################################################
# SSH key for creating VSI
##############################################################################

resource ibm_is_ssh_key ssh_key {
  name           = "${var.unique_id}-ssh-key"
  public_key     = var.ssh_public_key
  resource_group = data.ibm_resource_group.group.id
}

##############################################################################


##############################################################################
# Image Data Block
##############################################################################

data ibm_is_image image {
  name = var.image
}

##############################################################################


##############################################################################
# Provision VSI Template for group in first subnet in list
##############################################################################

resource ibm_is_instance_template vsi_template {
  name           = "${var.unique_id}-vsi-template"
  image          = data.ibm_is_image.image.id
  profile        = var.machine_type
  resource_group = data.ibm_resource_group.group.id

  
  primary_network_interface {
    subnet          = var.subnet_ids[0]
    security_groups = [
      ibm_is_security_group.security_group.id
    ]
  }  

  user_data  = <<BASH
#!/bin/bash
sleep 2m
sudo yum -y install epel-release
sudo yum -y install stress
sleep 2m
# Stress VSI
stress-ng --cpu 0 --hdd 2 --io 2 --vm 2 --vm-bytes 1G −−sctp 4 −−netdev 3 --timeout 15m --metrics-brief
# Install NGINX
sudo yum -y install nginx
# Start NGINX
sudo systemctl start nginx
  BASH
                 
  vpc        = data.ibm_is_vpc.vpc.id
  zone       = element(
      data.ibm_is_subnet.subnet.*.zone,
      index(
        var.subnet_ids,
        var.subnet_ids[0]
      )
  )
  
  keys       = [ ibm_is_ssh_key.ssh_key.id ]
}


##############################################################################


##############################################################################
# Create instance group
##############################################################################

resource ibm_is_instance_group instance_group {
  name               = "${var.unique_id}-instance-group"
  instance_template  = ibm_is_instance_template.vsi_template.id
  instance_count     = var.min_instances
  subnets            = data.ibm_is_subnet.subnet.*.id
  resource_group     = data.ibm_resource_group.group.id
  load_balancer      = ibm_is_lb.lb.id
  load_balancer_pool = element(split("/", ibm_is_lb_pool.pool.id),1) # Get pool ID
  application_port   = var.application_port

  //User can configure timeouts
  timeouts {
    create = "15m"
    delete = "15m"
    update = "10m"
  }
}

##############################################################################


##############################################################################
# Instance Group Manager
##############################################################################

resource ibm_is_instance_group_manager instance_group_manager {
  name                 = "${var.unique_id}-group-manager"
  aggregation_window   = var.aggregation_window
  instance_group       = ibm_is_instance_group.instance_group.id
  cooldown             = var.cooldown
  manager_type         = var.manager_type
  enable_manager       = var.enable_manager
  max_membership_count = var.max_instances
  min_membership_count = var.min_instances
}

##############################################################################


##############################################################################
# Instance Group Manager Policies
##############################################################################

resource ibm_is_instance_group_manager_policy policy {
  count                  = length(var.group_manager_policies)
  instance_group         = ibm_is_instance_group.instance_group.id
  instance_group_manager = ibm_is_instance_group_manager.instance_group_manager.manager_id
  metric_type            = var.group_manager_policies[count.index].metric_type
  metric_value           = var.group_manager_policies[count.index].metric_value
  policy_type            = "target"
  name                   = "${var.unique_id}-policy-${count.index + 1}-${var.group_manager_policies[count.index].metric_type}"
}

##############################################################################