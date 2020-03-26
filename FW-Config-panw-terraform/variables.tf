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
####################################
variable "access_key" {
    default = "LTAIzclqjaUrQz0J"
}

variable "secret_key" {
    default = "BRQ5TB6paNWxY7I1HOZwQzNytFRoLs"
}

variable "r1-region" {
    default = "cn-shenzhen"
}

provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.r1-region}"
  alias      = "r1"
}

#Get the MGMT IP for the PANW Provider
####################################
data "alicloud_eips" "all_eips" {
provider = "alicloud.r1"
}

#Information for the PANW Provider
####################################
#variable fwip {
#    default = "8.129.35.95"
#}
variable fwusername {
    default = "admin"}
variable fwpassword {
    default = "admin"
}

# Configure the panos provider
##################################
provider "panos" {
    hostname = "${data.alicloud_eips.all_eips.eips.1.ip_address}"
    username = "${var.fwusername}"
    password = "${var.fwpassword}"
}
variable tunnel1-ip {
    default = "192.168.200.1/24"
}

#ike gateway IKE-SC-GW peer-address
###################################
variable "IKE-SC-GW-peer-address" {
    default = "137.83.224.245"     
}
variable "IKE-Gateway-Japan-peer-address" {
    default = "192.168.10.10"     
}
variable "ike-gateway-pre_shared_key" {
    default = "12345678"
}

#Route to Japan Variables
###################################
variable "Route-To-Japan-destination" {
    default = "192.168.10.0/24"     
}

variable "Route-To-Japan-nexthop" {
    default = "10.10.20.253"
}
#AD Route Variable
############################
variable "Route-to-SC-DNS-AD-destination" {
    default = "10.0.2.0/24"
}

