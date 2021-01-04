##############################################################################
# Account Variables
##############################################################################

variable ibmcloud_api_key {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string
}

variable ibm_region {
  description = "IBM Cloud region where all resources will be deployed"
  type        = string
}

variable resource_group {
  description = "Name of resource group to create VPC"
  type        = string
  default     = "asset-development"
}

variable unique_id {
  description = "The IBM Cloud platform API key needed to deploy IAM enabled resources"
  type        = string
  default     = "asset-module-vsi"
}

##############################################################################


##############################################################################
# VPC Variables
##############################################################################

variable vpc_name {
  description = "Name of VPC"
  type        = string
}

variable subnet_ids {
  description = " A list of subnet ids where the VSI will be deployed"
  type        = list
}


##############################################################################


##############################################################################
# VSI Variables
##############################################################################

variable image {
  description = "Image name used for VSI. Run 'ibmcloud is images' to find available images in a region"
  type        = string
  default     = "ibm-centos-7-6-minimal-amd64-2"
}

variable ssh_public_key {
  description = "ssh public key to use for vsi"
  type        = string
}

variable machine_type {
  description = "VSI machine type. Run 'ibmcloud is instance-profiles' to get a list of regional profiles"
  type        =  string
  default     = "bx2-8x32"
}

variable application_port {
  description = "The port number of the application running in the server member."
  default     = 80
}

variable security_group_rules {
  description = "List of security group rules to be added to VSI security group. Can optionally include TCP, UDP, and ICMP blocks."
  default     = {
    allow_all_inbound = {
      source    = "0.0.0.0/0"
      direction = "inbound"
    },
    allow_all_outbound = {
      source    = "0.0.0.0/0"
      direction = "outbound"
    }
  }
}
##############################################################################


##############################################################################
# Instance Group Manager Variables
##############################################################################

variable enable_manager {
  description = "Enable or disable the instance group manager. Default value is true"
  type        = bool
  default     = true
}

variable min_instances {
  description = "Minimum of VSI instances for autoscaling group"
  type        = number
  default     = 3
}

variable max_instances {
  description = "Maximum number of instances in autoscaling group"
  type        = number
  default     = 9
}

variable aggregation_window {
  description = "The time window in seconds to aggregate metrics prior to evaluation."
  type        = number
  default     = 120
}

variable cooldown {
  description = "The duration of time in seconds to pause further scale actions after scaling has taken place."
  type        = number
  default     = 300
}

variable manager_type {
  description = "The type of instance group manager. Default value is autoscale."
  type        = string
  default     = "autoscale"
}

variable group_manager_policies {
  description = "A list of policies for your instance group manager"
  type        = list(
    object(
      {
        metric_type  = string # The type of metric to evaluate. The possible values for metric types are cpu, memory, network_in, and network_out.
        metric_value = number # The metric value to evaluate.
      }
    )
  )
  default = [
    {
      metric_type  = "cpu"
      metric_value = 10
    },
    {
      metric_type  = "memory"
      metric_value = 10
    }
  ]
}

##############################################################################


##############################################################################
# Load Balancer Variables
##############################################################################

variable lb_type {
    description = "Load Balancer type, can be public or private"
    type        = string
    default     = "public"
}

variable algorithm {
    description = "The load balancing algorithm. Supported values are round_robin, or least_connections"
    type        = string
    default     = "round_robin"
}

variable protocol {
    description = "The pool protocol. Supported values are http, and tcp."
    type        = string    
    default     = "http"
}

variable health_delay {
    description = "The health check interval in seconds. Interval must be greater than timeout value."
    type        = number
    default     = 10
}

variable health_retries {
    description = "The health check max retries."
    type        = number
    default     = 10
}

variable health_timeout {
    description = "The health check timeout in seconds."
    type        = number
    default     = 5 
}

variable health_type {
    description = "The pool protocol. Supported values are http, and tcp."
    type        = string
    default     = "http"
}

##############################################################################


##############################################################################
# Listener Variables
##############################################################################

variable listener_protocol {
    description = "The listener protocol. Supported values are http, tcp, and https"
    type        = string
    default     = "http"
}

variable certificate_instance {
    description = "Optional, the CRN of a certificate instance to use with the load balancer."
    type        = string
    default     = ""
}

variable connection_limit {
    description = "Optional, connection limit for the listener. Valid range 1 to 15000."
    type        = number
    default     = 0
}

##############################################################################