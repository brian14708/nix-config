resource "alicloud_vpc" "cn" {
  provider                = alicloud.cn
  vpc_name                = "lab-vpc"
  system_route_table_name = "lab-route"
  cidr_block              = "172.16.0.0/12"
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

resource "alicloud_security_group" "cn" {
  security_group_name = "lab-security-group"
  vpc_id              = alicloud_vpc.cn.id
  description         = "lab"
}

resource "alicloud_security_group_rule" "cn_allow_udp_services" {
  type              = "ingress"
  ip_protocol       = "udp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "32768/65535"
  security_group_id = alicloud_security_group.cn.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "cn_allow_tcp_services" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "32768/65535"
  security_group_id = alicloud_security_group.cn.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "cn_allow_ssh" {
  count             = 0
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.cn.id
  cidr_ip           = "0.0.0.0/0"
}
