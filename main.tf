terraform {
  required_providers {
    arvan = {
      source = "terraform.arvancloud.ir/arvancloud/iaas"
    }
  }
}

provider "arvan" {
  api_key = "apikey 5a067cb3-b904-50ee-98b3-df0d5e184764"
}

variable "region" {
  type        = string
  description = "The chosen region for resources"
  default     = "ir-thr-fr1"
}

variable "chosen_distro_name" {
  type        = string
  description = " The chosen distro name for image"
  default     = "ubuntu"
}

variable "chosen_name" {
  type        = string
  description = "The chosen release for image"
  default     = "20.04"
}

variable "chosen_network_name" {
  type        = string
  description = "The chosen name of network"
  default     = "public201" //public202
}

variable "chosen_plan_id" {
  type        = string
  description = "The chosen ID of plan"
  default     = "eco-3-1-0"
}

data "arvan_images" "terraform_image" {
  region     = var.region
  image_type = "distributions" // or one of: arvan, private
}

data "arvan_plans" "plan_list" {
  region = var.region
}
data "arvan_abraks" "instance_list" {
  region = var.region
}
data "arvan_ssh_keys" "keys"{
  region = var.region
}

#output "keys" {
#  value = data.arvan_ssh_keys.keys
#}

#output "id" {
#  value = [for plan in data.arvan_plans.plan_list.plans : {
#    id : plan.id,
#    name : plan.name,
#    ram : plan.memory,
#    price_per_hour : plan.price_per_hour,
#    }
#    if plan.generation == "ECO"
#  ]
#}

locals {
  chosen_image = try(
    [for image in data.arvan_images.terraform_image.distributions : image
    if image.distro_name == var.chosen_distro_name && image.name == var.chosen_name],
    []
  )

  selected_plan = [for plan in data.arvan_plans.plan_list.plans : plan if plan.id == var.chosen_plan_id][0]
}

resource "arvan_security_group" "terraform_security_group" {
  region      = var.region
  description = "Terraform-created security group"
  name        = "tf_security_group"
  rules = [
    {
      direction = "ingress"
      protocol  = "icmp"
    },
    {
      direction = "ingress"
      protocol  = "udp"
    },
    {
      direction = "ingress"
      protocol  = "tcp"
    },
    {
      direction = "egress"
      protocol  = ""
    }
  ]
}

resource "arvan_volume" "terraform_volume" {
  region      = var.region
  description = "Example volume created by Terraform"
  name        = "tf_volume"
  size        = 9
}

data "arvan_networks" "terraform_network" {
  region = var.region
}

locals {
  network_list = tolist(data.arvan_networks.terraform_network.networks)
  chosen_network = try(
    [for network in local.network_list : network
    if network.name == var.chosen_network_name],
    []
  )
}

resource "arvan_network" "terraform_private_network" {
  region      = var.region
  description = "Terraform-created private network"
  name        = "tf_private_network"
  dhcp_range = {
    start = "10.255.255.19"
    end   = "10.255.255.150"
  }
  dns_servers    = ["185.55.226.26", "185.55.225.25", "178.22.122.100"]
  enable_dhcp    = true
  enable_gateway = true
  cidr           = "10.255.255.0/24"
  gateway_ip     = "10.255.255.1"
}

resource "arvan_abrak" "built_by_terraform" {
  depends_on = [arvan_volume.terraform_volume, arvan_network.terraform_private_network, arvan_security_group.terraform_security_group]
  timeouts {
    create = "1h30m"
    update = "2h"
    delete = "20m"
    read   = "10m"
  }
  region    = var.region
  name      = "tf_abrak"
  count     = 1
  image_id  = local.chosen_image[0].id
  flavor_id = local.selected_plan.id
  disk_size = 25
  networks = [
    {
      network_id = local.chosen_network[0].network_id
    },
    {
      network_id = arvan_network.terraform_private_network.network_id
    }
  ]
  security_groups = [arvan_security_group.terraform_security_group.id]
  volumes         = [arvan_volume.terraform_volume.id]
  ssh_key_name = "laptop"


  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/home/behnam/.ssh/laptop")
    host        = [for network in self.networks : network if network.is_public == true][0].ip
  }

  provisioner "file" {
    source      = "try-install-docker.sh"  # Path to your local script
    destination = "/tmp/try-install-docker.sh"  # Path on the remote server

  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "export DEBIAN_FRONTEND=noninteractive",
      "sudo DEBIAN_FRONTEND=noninteractive apt-get -yq upgrade",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "sudo rm -f /etc/resolv.conf",
      "sudo touch /etc/resolv.conf",
      "sudo chmod 777 /etc/resolv.conf",
      "sudo echo 'nameserver 10.202.10.202' >> /etc/resolv.conf",
      "sudo echo 'nameserver 10.202.10.102' >> /etc/resolv.conf",
      "chmod +x /tmp/try-install-docker.sh",  
      "curl -fsSL https://raw.githubusercontent.com/behnambm/behnambm/main/get-docker.sh -o /tmp/install-docker.sh",
      "sudo sh /tmp/try-install-docker.sh",
      "sudo usermod -aG docker $USER",
    ]
  }
}

output "instances" {
  value = arvan_abrak.built_by_terraform
}


