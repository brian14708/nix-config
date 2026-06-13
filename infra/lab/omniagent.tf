locals {
  omniagent_count              = 0
  omniagent_cloudflare_zone_id = "bf5fdc3e15f7c89a2886befe85c783a2"
}

resource "alicloud_image_copy" "omniagent" {
  count            = local.omniagent_count
  provider         = alicloud.hk
  source_image_id  = alicloud_image_import.cn_nixos_20250531.id
  source_region_id = "cn-beijing"
  image_name       = "nixos-20250531"
  description      = "NixOS 20250531 copied from cn-beijing"
}

resource "alicloud_vpc" "omniagent" {
  count                   = local.omniagent_count
  provider                = alicloud.hk
  vpc_name                = "omniagent-vpc"
  system_route_table_name = "omniagent-route"
  cidr_block              = "10.80.0.0/16"
}

resource "alicloud_vswitch" "omniagent" {
  count        = local.omniagent_count
  provider     = alicloud.hk
  vswitch_name = "omniagent-switch"
  vpc_id       = alicloud_vpc.omniagent[count.index].id
  cidr_block   = "10.80.0.0/20"
  zone_id      = "cn-hongkong-b"
}

resource "alicloud_route_table" "omniagent" {
  count            = local.omniagent_count
  provider         = alicloud.hk
  vpc_id           = alicloud_vpc.omniagent[count.index].id
  route_table_name = alicloud_vpc.omniagent[count.index].system_route_table_name
  associate_type   = "VSwitch"
}

resource "alicloud_route_table_attachment" "omniagent" {
  count          = local.omniagent_count
  provider       = alicloud.hk
  vswitch_id     = alicloud_vswitch.omniagent[count.index].id
  route_table_id = alicloud_route_table.omniagent[count.index].id
}

resource "alicloud_security_group" "omniagent" {
  count               = local.omniagent_count
  provider            = alicloud.hk
  security_group_name = "omniagent-security-group"
  vpc_id              = alicloud_vpc.omniagent[count.index].id
  description         = "omniagent"
}

resource "alicloud_security_group_rule" "omniagent_allow_https" {
  count             = length(alicloud_security_group.omniagent)
  provider          = alicloud.hk
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.omniagent[count.index].id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "omniagent_allow_ssh" {
  count             = length(alicloud_security_group.omniagent)
  provider          = alicloud.hk
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.omniagent[count.index].id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "omniagent" {
  count                      = local.omniagent_count
  provider                   = alicloud.hk
  instance_name              = "omniagent"
  host_name                  = "omniagent"
  image_id                   = alicloud_image_copy.omniagent[count.index].id
  instance_charge_type       = "PostPaid"
  spot_strategy              = "SpotAsPriceGo"
  spot_duration              = 0
  instance_type              = "ecs.t6-c1m4.xlarge"
  security_groups            = [alicloud_security_group.omniagent[count.index].id]
  vswitch_id                 = alicloud_vswitch.omniagent[count.index].id
  system_disk_category       = "cloud_efficiency"
  system_disk_size           = "20"
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 0
  user_data = base64gzip(templatefile("${path.module}/cloud-init.tpl", {
    secrets = {}
  }))
  lifecycle {
    ignore_changes = [image_id, user_data]
  }
}

resource "alicloud_eip_address" "omniagent" {
  count                = length(alicloud_instance.omniagent)
  provider             = alicloud.hk
  isp                  = "BGP_PRO"
  address_name         = "omniagent"
  netmode              = "public"
  bandwidth            = "200"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "omniagent" {
  count         = length(alicloud_instance.omniagent)
  provider      = alicloud.hk
  allocation_id = alicloud_eip_address.omniagent[count.index].id
  instance_id   = alicloud_instance.omniagent[count.index].id
}

resource "cloudflare_dns_record" "omniagent" {
  count   = length(alicloud_instance.omniagent)
  zone_id = local.omniagent_cloudflare_zone_id
  name    = "@"
  content = alicloud_eip_address.omniagent[count.index].ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "omniagent_www" {
  count   = length(alicloud_instance.omniagent)
  zone_id = local.omniagent_cloudflare_zone_id
  name    = "*"
  content = alicloud_eip_address.omniagent[count.index].ip_address
  type    = "A"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "omniagent_ssh" {
  count   = length(alicloud_instance.omniagent)
  zone_id = local.omniagent_cloudflare_zone_id
  name    = "ssh"
  content = alicloud_eip_address.omniagent[count.index].ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}

