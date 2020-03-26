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
    default = "Insert-Access-Key"
}

variable "secret_key" {
    default = "Insert-Secret-Key"
}

# Prisma Access Service IP - This is defined in Prisma Access
#################################################################################
variable "prisma-access-remote-ip" {
    default = "Insert-Prisma_Access-Service-IP-Address"
}
#This is the Variables for the R1 region, which is the region the VM-Series is deployed in.
#################################################################################
variable "vm-series_instance_type" {
    default = "ecs.sn2ne.xlarge"     # network enhanced
}

variable "r1-image-name" {
    default = "VM-Series-1"
}

variable "r1-vpc-cidr" {
    default = "10.10.0.0/16"
}

variable "r1-mgmt-vswitch-cidr" {
    default = "10.10.10.0/24"
}

variable "r1-trust-vswitch-cidr" {
    default = "10.10.20.0/24"
}

variable "r1-untrust-vswitch-cidr" {
    default = "10.10.30.0/24"
}

variable "r1-mgmt-ip" {
    default = "10.10.10.10"
}

variable "r1-trust-ip" {
    default = "10.10.20.10"
}

variable "r1-untrust-ip" {
    default = "10.10.30.10"
}

variable "r1-untrust-router-ip" {
    default = "10.10.30.253"
}

variable "r1-trust-router-ip" {
    default = "10.10.20.253"
}


variable "r1-name" {
    default = "VM-Series-R1"
}

variable "r1-region" {
    default = "cn-shenzhen"
}

variable "r1-key" {
    default = "kyeu-alicloud-shenzhen-key"
}


#This is the begining of the Region 2 Variables
########################################################
variable "linux_instance_type" {
    default = "ecs.sn1ne.large"     # network enhanced
}
variable "r2-vpc-cidr" {
    default = "192.168.0.0/16"
}

variable "r2-vswitch-cidr" {
    default = "192.168.10.0/24"
}

variable "r2-ip" {
    default = "192.168.10.10"
}

variable "r2-name" {
    default = "R2"
}

variable "r2-region" {
    default = "ap-northeast-1"
}

variable "r2-key" {
    default = "kyeu-alicloud-tokyo-key"
}


