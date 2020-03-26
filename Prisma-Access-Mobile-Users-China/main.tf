# Copyright (c) 2018, Palo Alto Networks
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

# Configure the Alicloud Provider for R1 region
provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.r1-region}"
  alias      = "r1"
}

# Configure the Alicloud Provider for R2 region
provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.r2-region}"
  alias      = "r2"
}


# Get Ubuntu image info
data "alicloud_images" "ubuntu_image" {
  provider = "alicloud.r1"
  name_regex  = "^ubuntu_16_04_x64"
  owners      = "system"
}

# Get R1 region zones
data "alicloud_zones" "r1-zone" {
  provider = "alicloud.r1"
  available_instance_type = "ecs.sn1ne.large"
  available_disk_category = "cloud_efficiency"
}


# Get R2 region zones
data "alicloud_zones" "r2-zone" {
  provider = "alicloud.r2"
  available_instance_type = "ecs.sn1ne.large"
  available_disk_category = "cloud_efficiency"
}
####################################################
# Create VPC, VSwitch, EIP and Security Group for R2
####################################################
# Create VPC For R2
resource "alicloud_vpc" "R2_vpc" {
  provider = "alicloud.r2"  
  name        = "R2-VPC"
  cidr_block  = "${var.r2-vpc-cidr}"
  description = "VPC for Linux instance outside of China"
}

# Create VSwitch  For R2
resource "alicloud_vswitch" "R2-vswitch" {
  provider = "alicloud.r2"  
  name              = "R2-VSwitch"
  vpc_id            = "${alicloud_vpc.R2_vpc.id}"
  cidr_block        = "${var.r2-vswitch-cidr}"
  availability_zone = "${data.alicloud_zones.r2-zone.zones.0.id}"
  description       = "VSwitch for R2"
  depends_on = ["alicloud_vpc.R2_vpc" ]
}

# Create Security Group For R2
resource "alicloud_security_group" "R2-SG" {
  provider = "alicloud.r2"  
  name        = "R2-Security-Group"
  vpc_id      = "${alicloud_vpc.R2_vpc.id}"
  description = "Security Group for R2"
}

# Add rules to Security Group For R2
resource "alicloud_security_group_rule" "R2-allow_all_icmp" {
  provider = "alicloud.r2"  
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = "${alicloud_security_group.R2-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}


resource "alicloud_security_group_rule" "R2-allow_udp_500" {
  provider = "alicloud.r2"  
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "500/500"
  priority          = 1
  security_group_id = "${alicloud_security_group.R2-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "R2-allow_udp_4500" {
  provider = "alicloud.r2"  
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "4500/4500"
  priority          = 1
  security_group_id = "${alicloud_security_group.R2-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}


resource "alicloud_security_group_rule" "R2-allow_tcp_22" {
  provider = "alicloud.r2"  
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.R2-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}

####################################################
# Create VPC, VSwitch, EIP and Security Group for R1
####################################################


resource "alicloud_vpc" "R1_vpc" {
  provider = "alicloud.r1"
  name        = "R1-VPC"
  cidr_block  = "${var.r1-vpc-cidr}"
  description = "VPC for Linux instance in China"
}

# Create VSwitch For R1
####################################################
resource "alicloud_vswitch" "R1-mgmt-vswitch" {
  provider = "alicloud.r1"
  name              = "R1-Mgmt-VSwitch"
  vpc_id            = "${alicloud_vpc.R1_vpc.id}"
  cidr_block        = "${var.r1-mgmt-vswitch-cidr}"
  availability_zone = "${data.alicloud_zones.r1-zone.zones.0.id}"
  description       = "VSwitch for VM-series R1 Mgmt"
  depends_on = ["alicloud_vpc.R1_vpc" ]
}

# Create VSwitch For R1
####################################################
resource "alicloud_vswitch" "R1-data-trust-vswitch" {
  provider = "alicloud.r1"
  name              = "R1-Private-VSwitch"
  vpc_id            = "${alicloud_vpc.R1_vpc.id}"
  cidr_block        = "${var.r1-trust-vswitch-cidr}"
  availability_zone = "${data.alicloud_zones.r1-zone.zones.0.id}"
  description       = "VSwitch for VM-series R1 Trust interface"
  depends_on = ["alicloud_vpc.R1_vpc" ]
}

# Create VSwitch For R1
####################################################
resource "alicloud_vswitch" "R1-data-untrust-vswitch" {
  provider = "alicloud.r1"
  name              = "R1-Public-VSwitch"
  vpc_id            = "${alicloud_vpc.R1_vpc.id}"
  cidr_block        = "${var.r1-untrust-vswitch-cidr}"
  availability_zone = "${data.alicloud_zones.r1-zone.zones.0.id}"
  description       = "VSwitch for VM-series R1 Untrust interface"
  depends_on = ["alicloud_vpc.R1_vpc" ]
}

# Create EIP For R1
####################################################
resource "alicloud_eip" "R1-MGMT-EIP" {
  provider = "alicloud.r1"
  name                 = "R1-MGMT-EIP"
  description          = "Public IP assigned to R1 Mgmt"
  bandwidth            = "1"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip" "R1-UNTRUST-EIP" {
  provider = "alicloud.r1"
  name                 = "R1-UNTRUST-EIP"
  description          = "Public IP assigned to R1 Untrust interface"
  bandwidth            = "1"
  internet_charge_type = "PayByTraffic"

  depends_on = ["module.fw_deployment"]
}

# Create Security Group For R1
####################################################
resource "alicloud_security_group" "R1-MGMT-SG" {
  provider = "alicloud.r1"
  name        = "R1-Mgmt-Security-Group"
  vpc_id      = "${alicloud_vpc.R1_vpc.id}"
  description = "Security Group for R1"
}

resource "alicloud_security_group" "R1-TRUST-SG" {
  provider = "alicloud.r1"
  name        = "R1-Trust-Security-Group"
  vpc_id      = "${alicloud_vpc.R1_vpc.id}"
  description = "Security Group for R1 Trust"
}

resource "alicloud_security_group" "R1-UNTRUST-SG" {
  provider = "alicloud.r1"
  name        = "R1-Untrust-Security-Group"
  vpc_id      = "${alicloud_vpc.R1_vpc.id}"
  description = "Security Group for R1 Untrust"
}

# Add rules to Security Group For R1
####################################################
resource "alicloud_security_group_rule" "allow_all_icmp" {
  provider = "alicloud.r1"
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = "${alicloud_security_group.R1-MGMT-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_all_443" {
  provider = "alicloud.r1"
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  priority          = 1
  security_group_id = "${alicloud_security_group.R1-MGMT-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_udp_trust_500" {
  provider = "alicloud.r1"
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "500/500"
  priority          = 1
  security_group_id = "${alicloud_security_group.R1-TRUST-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_udp_trust_4500" {
  provider = "alicloud.r1"
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "4500/4500"
  priority          = 1
  security_group_id = "${alicloud_security_group.R1-TRUST-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_udp_untrust_500" {
  provider = "alicloud.r1"
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "500/500"
  priority          = 1
  security_group_id = "${alicloud_security_group.R1-UNTRUST-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_udp_untrust_4500" {
  provider = "alicloud.r1"
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "4500/4500"
  priority          = 1
  security_group_id = "${alicloud_security_group.R1-UNTRUST-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}


resource "alicloud_security_group_rule" "allow_tcp_22" {
  provider = "alicloud.r1"
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.R1-MGMT-SG.id}"
  cidr_ip           = "0.0.0.0/0"
}


####################################################################
#Calling the deployment modules for the VM-Series in R1
####################################################################

module "fw_deployment" {
  source                = "./modules/fw_deployment/"

  fwimage                           = "${var.r1-image-name}"
  instancetype                      = "${var.vm-series_instance_type}"
  alicloud_security_groupR1-MGMT-SG ="${alicloud_security_group.R1-MGMT-SG.id}"
  r1name                            ="${var.r1-name}"
  R1-mgmt-vswitchid                 = "${alicloud_vswitch.R1-mgmt-vswitch.id}"
  alicloud_eipR1-MGMT-EIPid         = "${alicloud_eip.R1-MGMT-EIP.id}"
  r1-mgmtip                         = "${var.r1-mgmt-ip}"
  R1-data-trust-vswitchid           = "${alicloud_vswitch.R1-data-trust-vswitch.id}"
  R1-TRUST-SGid                     = "${alicloud_security_group.R1-TRUST-SG.id}"
  r1-trustip                        = "${var.r1-trust-ip}"
  R1-data-untrust-vswitchid         = "${alicloud_vswitch.R1-data-untrust-vswitch.id}"
  R1-UNTRUST-SGid                   = "${alicloud_security_group.R1-UNTRUST-SG.id}"
  r1-untrustip                      = "${var.r1-untrust-ip}"
  


}
/*
####################################################################
#Calling the module to validate when the firewall is online
####################################################################
module "fw_check" {
  source            = "./modules/fw_check/"
  fwmgmtip          = "${alicloud_eip.R1-MGMT-EIP.ip_address}"

  fw_check_depends_on = ["module.fw_deployment.completion"]
  
}
*/


### This was calling the expect script to config the FW but it is not reliable with a larger set of commands.
#resource "null_resource" "run_fwconfig" {
  #provisioner "local-exec" {
  #  command = "expect ./configure-vm-series.expect ${alicloud_eip.R1-MGMT-EIP.ip_address} ${var.r1-untrust-ip} ${var.r1-trust-ip} ${var.r1-untrust-router-ip} ${var.r1-trust-vswitch-cidr} ${var.r1-trust-router-ip}" 
  #}
   #depends_on = ["module.fw_check"]

#}
# Create a null resource so that VM-series configuration script can be executed locally.

## THis will perform a firewall commit but is not needed unless the Expect script is used.
#resource "null_resource" "run_cmd" {
#  provisioner "local-exec" {
#    command = "expect ./fwcommit.expect ${alicloud_eip.R1-MGMT-EIP.ip_address} ${var.fwusername} ${var.fwpassword}}" 
#}
#   depends_on = ["null_resource.run_fwconfig"]

#}

output "VM-Series-MGMTIP" {
  value = "${alicloud_eip.R1-MGMT-EIP.ip_address}"  
}

output "VM-Series-UNTRUSTIP" {
  value = "${alicloud_eip.R1-UNTRUST-EIP.ip_address} *** Please manually attach this IP to Untrust ENI. ***\n\n"
}