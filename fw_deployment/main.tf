variable fwimage {}
variable instancetype {}
variable alicloud_security_groupR1-MGMT-SG {}
variable r1name {}
variable "R1-mgmt-vswitchid" {}
variable "alicloud_eipR1-MGMT-EIPid" {}
variable "r1-mgmtip" {}
variable "R1-data-trust-vswitchid" {}
variable "R1-TRUST-SGid" {}
variable "r1-trustip" {}
variable "R1-data-untrust-vswitchid" {}
variable "R1-UNTRUST-SGid" {}
variable "r1-untrustip" {}



# Create VM-series firewall 

data "alicloud_images" "images_VM-series" {
  provider = "alicloud.r1"
  owners = "self"
  name_regex = "^${var.fwimage}"
  #name_regex = "^VM-Series-1"
}

resource "alicloud_instance" "R1" {
  provider              = "alicloud.r1"
  image_id              = "${data.alicloud_images.images_VM-series.images.0.id}"
  instance_type         = "${var.instancetype}"
  system_disk_size      = 80
  system_disk_category  = "cloud_efficiency"
  security_groups       = ["${var.alicloud_security_groupR1-MGMT-SG}"]
  instance_name         = "${var.r1name}"
  vswitch_id            = "${var.R1-mgmt-vswitchid}"
  private_ip               = "${var.r1-mgmtip}"
  host_name             = "${var.r1name}"
  #key_name              = "${var.r1-key}"
  description           = "VM-series instance for Prisma Access in China"
  security_enhancement_strategy = "Active"


#  internet_charge_type  = "PayByBandwidth"
  internet_max_bandwidth_out = 0    # No Public IP assigned since we are attaching EIP

  instance_charge_type  = "PostPaid"
#  instance_charge_type  = "PrePaid"
#  period_unit           = "Month"
#  period                = 1
# depends_on = ["alicloud_vpc.R1_vpc" ]
}


# Attach EIP# 1 to R1 Mgmt
resource "alicloud_eip_association" "R1-EIP-Association" {
  provider      = "alicloud.r1"
  allocation_id = "${var.alicloud_eipR1-MGMT-EIPid}"
  instance_id   = "${alicloud_instance.R1.id}"
  #depends_on = ["alicloud_eip.R1-MGMT-EIP" , "alicloud_vswitch.R1-mgmt-vswitch" ]
}

# TerraForm does not support allocation of EIP to an ENI
 #resource "alicloud_eip_association" "R1-Untrust-EIP-Association" {
  #provider      = "alicloud.r1"
  #allocation_id = "${alicloud_eip.R1-UNTRUST-EIP.id}"
  #instance_id   = "${alicloud_instance.R1.id}"
  #private_ip_address = "${var.r1-untrust-ip}" 
  #depends_on = ["alicloud_eip.R1-UNTRUST-EIP", "alicloud_eips.all_eips" ]
#}

# Attach ENI to R1
resource "alicloud_network_interface" "untrust-interface" {
  provider      = "alicloud.r1"
  name = "VM-series-untrust-interface"
  vswitch_id = "${var.R1-data-untrust-vswitchid}"
  security_groups = [ "${var.R1-UNTRUST-SGid}" ]
  private_ip = "${var.r1-untrustip}" 
  #depends_on = ["alicloud_vpc.R1_vpc" ]
}

resource "alicloud_network_interface_attachment" "attach-untrust" {
  provider      = "alicloud.r1"
  instance_id = "${alicloud_instance.R1.id}"
  network_interface_id = "${alicloud_network_interface.untrust-interface.id}"
  #depends_on = ["alicloud_vpc.R1_vpc"  ]
}
resource "alicloud_network_interface" "trust-interface" {
  provider      = "alicloud.r1"
  name = "VM-series-trust-interface"
  vswitch_id = "${var.R1-data-trust-vswitchid}"
  security_groups = [ "${var.R1-TRUST-SGid}" ]
  private_ip = "${var.r1-trustip}" 
  depends_on = ["alicloud_network_interface_attachment.attach-untrust"]
}

resource "alicloud_network_interface_attachment" "attach-trust" {
  provider      = "alicloud.r1"
  instance_id = "${alicloud_instance.R1.id}"
  network_interface_id = "${alicloud_network_interface.trust-interface.id}"
  depends_on = ["alicloud_network_interface_attachment.attach-untrust"]

}



data "alicloud_eips" "untrust_eip" {
  provider              = "alicloud.r1"
  ids   = ["${var.alicloud_eipR1-MGMT-EIPid}"]
  #depends_on = ["alicloud_vpc.R1_vpc" ]
}


data "alicloud_eips" "all_eips" {
provider = "alicloud.r1"
depends_on = ["alicloud_eip_association.R1-EIP-Association"]
}

resource "null_resource" "dependency_setter" {

  depends_on = [
    "alicloud_network_interface_attachment.attach-untrust",
    "alicloud_network_interface.untrust-interface",
    "alicloud_network_interface_attachment.attach-trust",
    "alicloud_network_interface.trust-interface",
    "alicloud_eip_association.R1-EIP-Association",
    "alicloud_instance.R1"
  ]
}

output completion {
  value = "${null_resource.dependency_setter.id}"
}
