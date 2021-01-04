##############################################################################
# Load Balancer
##############################################################################

resource ibm_is_lb lb {
    name           = "${var.unique_id}-lb"
    subnets        = data.ibm_is_subnet.subnet.*.id
    type           = var.lb_type
    resource_group = data.ibm_resource_group.group.id
}

##############################################################################


##############################################################################
# Load Balancer Pool
##############################################################################

resource ibm_is_lb_pool pool {
    lb             = ibm_is_lb.lb.id
    name           = "${var.unique_id}-lb-pool"
    algorithm      = var.algorithm
    protocol       = var.protocol
    health_delay   = var.health_delay
    health_retries = var.health_retries
    health_timeout = var.health_timeout
    health_type    = var.health_type
}

##############################################################################


##############################################################################
# Load Balancer Listener
# Awaits attachment of instance group to the load balancer pool
##############################################################################

resource ibm_is_lb_listener listener {
    lb                    = ibm_is_lb.lb.id
    default_pool          = ibm_is_lb_pool.pool.id
    port                  = var.application_port
    protocol              = var.listener_protocol
    certificate_instance  = var.certificate_instance != "" ? var.certificate_instance : null
    connection_limit      = var.connection_limit > 0 ? var.connection_limit : null
    depends_on            = [ ibm_is_instance_group_manager.instance_group_manager ]
}

##############################################################################