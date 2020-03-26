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


# Add interfaces to the firewall
##################################

resource "panos_ethernet_interface" "e1" {
    name = "ethernet1/1"
    vsys = "vsys1"
    mode = "layer3"
    enable_dhcp = true
    create_dhcp_default_route = true
    dhcp_default_route_metric = 10
    comment = "Untrust Interface"
}

resource "panos_ethernet_interface" "e2" {
    name = "ethernet1/2"
    vsys = "vsys1"
    mode = "layer3"
    enable_dhcp = true
    comment = "Trust Interface"
}

resource "panos_tunnel_interface" "tunnel1" {
    name = "tunnel.1"
    static_ips = ["${var.tunnel1-ip}"]
    comment = "GlobalProtect Tunnel Interface"
}
resource "panos_tunnel_interface" "tunnel51" {
    name = "tunnel.51"
    comment = "Tunnel to Prisma Access Service Connection"
}

# Add a new zones to the firewall
##################################
resource "panos_zone" "Untrust" {
    name = "Untrust"
    mode = "layer3"
    interfaces = ["${panos_ethernet_interface.e1.name}" ]
}

resource "panos_zone" "Trust" {
    name = "Trust"
    mode = "layer3"
    interfaces = ["${panos_ethernet_interface.e2.name}" , "${panos_tunnel_interface.tunnel1.name}" , "${panos_tunnel_interface.tunnel51.name}"]
}

# Configure Virtual Router
##################################
resource "panos_virtual_router" "vr" {
    name = "vr"
    static_dist = 15
    interfaces = ["ethernet1/1", "ethernet1/2","tunnel.1","tunnel.51"]

    depends_on = [ "panos_ethernet_interface.e1","panos_ethernet_interface.e2","panos_tunnel_interface.tunnel51","panos_tunnel_interface.tunnel1"]
}
#Conifgure Static Routes
#########################
resource "panos_static_route_ipv4" "Route-To-Japan" {
    name = "Route-To-Japan"
    virtual_router = "${panos_virtual_router.vr.name}"
    destination = "${var.Route-To-Japan-destination}"
    next_hop = "${var.Route-To-Japan-nexthop}"
    interface = "${panos_ethernet_interface.e2.name}"
    depends_on = ["panos_virtual_router.vr"]
}
resource "panos_static_route_ipv4" "Route-to-SC-DNS-AD" {
    name = "Route-to-SC-DNS-AD"
    virtual_router = "${panos_virtual_router.vr.name}"
    destination = "${var.Route-to-SC-DNS-AD-destination}"
    interface = "${panos_tunnel_interface.tunnel51.name}"
    type = ""
    depends_on =["panos_virtual_router.vr"]
}
#Create IKE Crytpo Profile
##################################
resource "panos_ike_crypto_profile" "SC-IKE-Crypto" {
    name = "SC-IKE-Crypto"
    dh_groups = ["group2"]
    authentications = ["sha1"]
    encryptions = ["aes-256-cbc"]
    lifetime_value = 1
    authentication_multiple = 3
}

#Create IPSEC Crytpo Profile
##################################
resource "panos_ipsec_crypto_profile" "SC-IPSEC-Crypto" {
    name = "SC-IPSEC-Crypto"
    authentications = ["sha1", "sha256", "none"]
    encryptions = ["des", "aes-256-gcm"]
    dh_group = "group2"
    lifetime_type = "hours"
    lifetime_value = 2
}

#Create IKE Gatewway
##################################
resource "panos_ike_gateway" "IKE-SC-GW" {
    name = "IKE-SC-GW"
    version ="ikev2"
    peer_ip_type = "ip"
    peer_ip_value ="${var.IKE-Gateway-Japan-peer-address}"
    interface = "ethernet1/2"
    pre_shared_key = "${var.ike-gateway-pre_shared_key}"
    local_id_type = "ufqdn"
    local_id_value = "remotechina@gptest.com"
    peer_id_type = "ufqdn"
    peer_id_value = "localchina@gptest.com"
    ikev1_crypto_profile = "${panos_ike_crypto_profile.SC-IKE-Crypto.name}"
    enable_nat_traversal = true
    nat_traversal_keep_alive = "10"
    depends_on = [ "panos_ethernet_interface.e2"]
}

#Create IPSEC Tunnel
###################################
resource "panos_ipsec_tunnel" "ipsec_tunnel-1" {
    name = "Service-Connection-2-Tunnel"
    tunnel_interface = "tunnel.51"
    anti_replay = true
    ak_ike_gateway = "IKE-SC-GW"
    ak_ipsec_crypto_profile = "SC-IPSEC-Crypto"

    depends_on = [ "panos_ike_gateway.IKE-SC-GW" , "panos_ipsec_crypto_profile.SC-IPSEC-Crypto"]
}
#FW NAT Rules
##################################

resource "panos_nat_rule_group" "SRC-NAT-Internet" {
    rule {
        name = "SRC-NAT-Internet"
        original_packet {
            source_zones = ["${panos_zone.Trust.name}"]
            destination_zone = "${panos_zone.Untrust.name}"
            destination_interface = "${panos_ethernet_interface.e1.name}"
            source_addresses = ["any"]
            destination_addresses = ["any"]
        }
        translated_packet {
            source {
                dynamic_ip_and_port {
                    interface_address {
                        interface = "${panos_ethernet_interface.e1.name}"
                       
                    }
                }
            }
            destination {
                
            }
        }
    }
}

#FW Rules
#These are here as an example.  ANY-ANY rule is not suggested but 
#this provides an example
##################################

/*resource "panos_security_policy" "fw-rules" {
    rule {
        name = "allow-all-traffic"
        source_zones = ["any"]
        source_addresses = ["any"]
        source_users = ["any"]
        hip_profiles = ["any"]
        destination_zones = ["any"]
        destination_addresses = ["any"]
        applications = ["any"]
        services = ["any"]
        categories = ["any"]
        action = "allow"
    }
    rule {
        name = "deny-for-logging"
        source_zones = ["any"]
        source_addresses = ["any"]
        source_users = ["any"]
        hip_profiles = ["any"]
        destination_zones = ["any"]
        destination_addresses = ["any"]
        applications = ["any"]
        services = ["application-default"]
        categories = ["any"]
        action = "deny"
    }
}*/
resource "null_resource" "run_cmd" {
  provisioner "local-exec" {
    command = "expect ./fwcommit.expect ${data.alicloud_eips.all_eips.eips.1.ip_address} ${var.fwusername} ${var.fwpassword}" 
    }
   depends_on = [ "panos_nat_rule_group.SRC-NAT-Internet"]
}
