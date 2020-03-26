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

# Creating a CEN instance
resource "alicloud_cen_instance" "cen" {
    provider = "alicloud.r1"
    name = "prisma_access_cen"
    description = "CEN for Prisma Access connection between VPC in China and VPC outside of China"
}


# Attaching CEN instance to both VPCs
resource "alicloud_cen_instance_attachment" "cen-r1-attach" {
    provider = "alicloud.r1"
    instance_id = "${alicloud_cen_instance.cen.id}"
    child_instance_id = "${alicloud_vpc.R1_vpc.id}"
    child_instance_region_id = "${var.r1-region}"

    depends_on = ["alicloud_cen_instance.cen",
     "alicloud_vpc.R1_vpc","alicloud_eip.R1-MGMT-EIP" ,
     "module.fw_deployment" 
        ]
}


resource "alicloud_cen_instance_attachment" "cen-r2-attach" {
    provider = "alicloud.r1"
    instance_id = "${alicloud_cen_instance.cen.id}"
    child_instance_id = "${alicloud_vpc.R2_vpc.id}"
    child_instance_region_id = "${var.r2-region}"

    depends_on = ["alicloud_cen_instance.cen", "alicloud_vpc.R2_vpc" , "alicloud_vswitch.R2-vswitch" ]
}



