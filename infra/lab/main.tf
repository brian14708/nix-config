resource "alicloud_instance" "derp" {
  image_id        = "debian_12_4_x64_20G_alibase_20240126.vhd"
  instance_type   = "ecs.t6-c2m1.large"
  security_groups = [alicloud_security_group.cn.id]
  renewal_status  = "AutoRenewal"
}

resource "alicloud_ecs_network_interface" "derp" {
  vswitch_id         = alicloud_vswitch.cn.id
  security_group_ids = [alicloud_security_group.cn.id]
}

resource "alicloud_ecs_network_interface_attachment" "derp" {
  network_interface_id = alicloud_ecs_network_interface.derp.id
  instance_id          = alicloud_instance.derp.id
}

