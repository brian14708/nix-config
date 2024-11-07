resource "alicloud_vpc" "cn" {
  provider                = alicloud.cn
  vpc_name                = "lab-vpc"
  system_route_table_name = "lab-route"
  cidr_block              = "172.16.0.0/12"
  enable_ipv6             = true
}

resource "alicloud_vswitch" "cn" {
  vswitch_name = "lab-switch"
  vpc_id       = alicloud_vpc.cn.id
  cidr_block   = "172.30.80.0/20"
  zone_id      = "cn-beijing-k"
}

resource "alicloud_route_table" "cn" {
  vpc_id           = alicloud_vpc.cn.id
  route_table_name = alicloud_vpc.cn.system_route_table_name
  associate_type   = "VSwitch"
}

resource "alicloud_route_table_attachment" "cn" {
  vswitch_id     = alicloud_vswitch.cn.id
  route_table_id = alicloud_route_table.cn.id
}

resource "alicloud_vpc_ipv6_gateway" "cn" {
  ipv6_gateway_name = "lab-ipv6"
  vpc_id            = alicloud_vpc.cn.id
}

resource "alicloud_route_entry" "cn_ipv6" {
  route_table_id        = alicloud_route_table.cn.id
  destination_cidrblock = "::/0"
  nexthop_type          = "IPv6Gateway"
  nexthop_id            = alicloud_vpc_ipv6_gateway.cn.id
}

resource "alicloud_eip_address" "derp" {
  isp          = "BGP"
  address_name = "derp"
  netmode      = "public"
  bandwidth    = "200"
  payment_type = "PayAsYouGo"
}

resource "alicloud_security_group" "cn" {
  name        = "lab-security-group"
  vpc_id      = alicloud_vpc.cn.id
  description = "lab"
}

resource "alicloud_security_group_rule" "cn_allow_ipv4" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  security_group_id = alicloud_security_group.cn.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "cn_allow_ipv6" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "intranet"
  policy            = "accept"
  security_group_id = alicloud_security_group.cn.id
  ipv6_cidr_ip      = "::/0"
}
