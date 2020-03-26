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

# Create R2
resource "alicloud_instance" "R2" {
  provider = "alicloud.r2"  
  image_id              = "${data.alicloud_images.ubuntu_image.images.0.id}"
  instance_type         = "${var.linux_instance_type}"
  system_disk_size      = 40
  system_disk_category  = "cloud_efficiency"
  security_groups       = ["${alicloud_security_group.R2-SG.id}"]
  instance_name         = "${var.r2-name}"
  vswitch_id            = "${alicloud_vswitch.R2-vswitch.id}"
  private_ip            = "${var.r2-ip}"
  host_name             = "${var.r2-name}"
  key_name              = "${var.r2-key}"
  description           = "Router instance for GPCS outside of China"
  security_enhancement_strategy = "Active"


#  internet_charge_type  = "PayByBandwidth"
  internet_max_bandwidth_out = 1      # non-zero value will cause Public IP to be assigned to the instance

  instance_charge_type  = "PostPaid"
#  instance_charge_type  = "PrePaid"
#  period_unit           = "Month"
#  period                = 1


user_data = <<EOF
#! /bin/sh
sudo su
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
/sbin/sysctl -p
echo "#! /bin/sh" > /root/iptables-rule.sh
echo "iptables -t filter -A FORWARD -i eth0 -j ACCEPT" >> /root/iptables-rule.sh
echo "iptables -t filter -A FORWARD -o eth0 -j ACCEPT" >> /root/iptables-rule.sh
echo "iptables -t nat -A PREROUTING -s ${var.r1-trust-ip}/32 -i eth0 -p udp -m udp --dport 500 -j DNAT --to-destination ${var.prisma-access-remote-ip}" >> /root/iptables-rule.sh
echo "iptables -t nat -A PREROUTING -s ${var.r1-trust-ip}/32 -i eth0 -p udp -m udp --dport 4500 -j DNAT --to-destination ${var.prisma-access-remote-ip}" >> /root/iptables-rule.sh
echo "iptables -t nat -A POSTROUTING -d ${var.prisma-access-remote-ip}/32 -o eth0 -p udp -m udp --dport 500 -j SNAT --to-source ${var.r2-ip}" >> /root/iptables-rule.sh
echo "iptables -t nat -A POSTROUTING -d ${var.prisma-access-remote-ip}/32 -o eth0 -p udp -m udp --dport 4500 -j SNAT --to-source ${var.r2-ip}" >> /root/iptables-rule.sh
/bin/sh /root/iptables-rule.sh
/sbin/iptables-save
EOF

}

