variable "vault-name" {
  default = "dynamic-aws-creds-vault-fdio-csit-jenkins"
}

variable "region" {
  description = "AWS Region."
  type        = string
  default     = "eu-central-1"
}

variable "resource_prefix" {
  description = "Resources name prefix."
  type        = string
  default     = "csit-2n-aws-c5n"
}

variable "testbed_name" {
  description = "Testbed name."
  type        = string
  default     = "testbed1"
}

# Variables for Private Key
variable "private_key_algorithm" {
  description = "The name of the algorithm to use for the key."
  type        = string
  default     = "ED25519"
}

# Variables for Placement Group
variable "placement_group_strategy" {
  description = "The placement strategy. Can be cluster, partition or spread."
  type        = string
  default     = "cluster"
}

# Variables for Instance
variable "tg_ami" {
  description = "AMI to use for the instance."
  type        = string
  default     = "ami-07430bfa17fd4e597"
}

variable "tg_associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC."
  type        = bool
  default     = true
}

variable "tg_instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance."
  type        = string
  default     = "terminate"
}

variable "tg_instance_type" {
  description = "The instance type to use for the instance."
  type        = string
  default     = "c5n.4xlarge"
}

variable "tg_private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
  default     = "192.168.0.10"
}

variable "tg_source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance."
  type        = bool
  default     = false
}

variable "sut1_ami" {
  description = "AMI to use for the instance."
  type        = string
  default     = "ami-0a890555652963ec2"
}

variable "sut1_associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC."
  type        = bool
  default     = true
}

variable "sut1_instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance."
  type        = string
  default     = "terminate"
}

variable "sut1_instance_type" {
  description = "The instance type to use for the instance."
  type        = string
  default     = "c5n.4xlarge"
}

variable "sut1_private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
  default     = "192.168.0.11"
}

variable "sut1_source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance."
  type        = bool
  default     = false
}

variable "sut2_ami" {
  description = "AMI to use for the instance."
  type        = string
  default     = "ami-07898402cb1fd6561"
}

variable "sut2_associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC."
  type        = bool
  default     = true
}

variable "sut2_instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance."
  type        = string
  default     = "terminate"
}

variable "sut2_instance_type" {
  description = "The instance type to use for the instance."
  type        = string
  default     = "c5n.4xlarge"
}

variable "sut2_private_ip" {
  description = "Private IP address to associate with the instance in a VPC."
  type        = string
  default     = "192.168.0.12"
}

variable "sut2_source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance."
  type        = bool
  default     = false
}

# Variables for Network Interface
variable "tg_if1_private_ip" {
  description = "List of private IPs to assign to the ENI without regard to order."
  type        = string
  default     = "192.168.10.254"
}

variable "tg_if2_private_ip" {
  description = "List of private IPs to assign to the ENI without regard to order."
  type        = string
  default     = "192.168.20.254"
}

variable "destination_cidr_block_tg_if1" {
  description = "The destination CIDR block."
  type        = string
  default     = "10.0.0.0/24"
}

variable "destination_cidr_block_tg_if2" {
  description = "The destination CIDR block."
  type        = string
  default     = "20.0.0.0/24"
}

variable "sut1_if1_private_ip" {
  description = "List of private IPs to assign to the ENI without regard to order."
  type        = string
  default     = "192.168.10.11"
}

variable "sut1_if2_private_ip" {
  description = "List of private IPs to assign to the ENI without regard to order."
  type        = string
  default     = "200.0.0.101"
}

variable "sut2_if1_private_ip" {
  description = "List of private IPs to assign to the ENI without regard to order."
  type        = string
  default     = "200.0.0.102"
}

variable "sut2_if2_private_ip" {
  description = "List of private IPs to assign to the ENI without regard to order."
  type        = string
  default     = "192.168.20.11"
}

# Variables for Null Resource
variable "first_run_commands" {
  description = "List of private IPs to assign to the ENI without regard to order."
  type        = list(string)
  default = [
    "sudo sed -i 's/^PasswordAuthentication/#PasswordAuthentication/' /etc/ssh/sshd_config",
    "sudo systemctl restart sshd",
    "sudo useradd --create-home -s /bin/bash provisionuser",
    "echo 'provisionuser:Csit1234' | sudo chpasswd",
    "echo 'provisionuser ALL = (ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers",
    "sudo useradd --create-home -s /bin/bash testuser",
    "echo 'testuser:Csit1234' | sudo chpasswd",
    "echo 'testuser ALL = (ALL) NOPASSWD: ALL' | sudo tee -a /etc/sudoers"
  ]
}

# Variables for Null Resource
variable "ansible_topology_path" {
  description = "Ansible topology path."
  type        = string
  default     = "../../fdio.infra.ansible/cloud_topology.yaml"
}
