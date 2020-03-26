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

#The following are required.  Insert the Alibaba Access Key and Secret Key below
#################################################################################

variable "access_key" {
    default = "Insert Alibaba Access key here"
}
variable "secret_key" {
    default = "Insert Alibaba Secret key here"
}
# The following variables are the key names that are created.  If these names are changed,
# be sure to change the key names in the variables.tf of infastructure deployment Terraform.
##################################################################################
variable "r1-key-name" {
    default = "kyeu-alicloud-shenzhen-key"
}
variable "r2-key-name" {
    default = "kyeu-alicloud-tokyo-key"
}
#The folowing variables define the Alibaba Regions that the keys will be created in.
#################################################################################
variable "r1-region" {
   default = "cn-shenzhen"
}
variable "r2-region" {
    default = "ap-northeast-1"
}
#Provider information
provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.r1-region}"
  alias      = "r1"
}
provider "alicloud" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.r2-region}"
  alias      = "r2"
}
resource "alicloud_key_pair" "alicloud_key_r1" {
    provider = "alicloud.r1"
    key_name = "${var.r1-key-name}"
    key_file = "${var.r1-key-name}"
}
resource "alicloud_key_pair" "alicloud_key_r2" {
    provider = "alicloud.r2"
    key_name = "${var.r2-key-name}"
    key_file = "${var.r2-key-name}"
}
output "key_name_r1" {
  value = "${alicloud_key_pair.alicloud_key_r1.key_name}"
}
output "key_fingerprint_r1" {
  value = "${alicloud_key_pair.alicloud_key_r1.finger_print}"
}
output "key_name_r2" {
  value = "${alicloud_key_pair.alicloud_key_r2.key_name}"
}
output "key_fingerprint_r2" {
  value = "${alicloud_key_pair.alicloud_key_r2.finger_print}"
}
