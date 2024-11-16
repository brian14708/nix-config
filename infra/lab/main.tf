data "sops_file" "vars" {
  source_file = "vars.secrets.yaml"
}

resource "alicloud_instance" "watchtower" {
  instance_name   = "watchtower"
  host_name       = "watchtower"
  image_id        = alicloud_image_import.cn_nixos_20241109.id
  instance_type   = "ecs.t6-c2m1.large"
  renewal_status  = "AutoRenewal"
  security_groups = [alicloud_security_group.cn.id]
  vswitch_id      = alicloud_vswitch.cn.id
  user_data = base64gzip(templatefile("${path.module}/cloud-init.tpl", {
    ts_auth = data.sops_file.vars.data["ts_auth"]
  }))
}

resource "alicloud_eip_address" "watchtower" {
  isp                  = "BGP"
  address_name         = "watchtower"
  netmode              = "public"
  bandwidth            = "200"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_ecs_network_interface" "watchtower" {
  vswitch_id         = alicloud_vswitch.cn.id
  security_group_ids = [alicloud_security_group.cn.id]
}

resource "alicloud_ecs_network_interface_attachment" "watchtower" {
  network_interface_id = alicloud_ecs_network_interface.watchtower.id
  instance_id          = alicloud_instance.watchtower.id
}

resource "alicloud_instance" "lab01" {
  instance_name        = "lab01"
  host_name            = "lab01"
  image_id             = alicloud_image_import.cn_nixos_20241109.id
  instance_charge_type = "PostPaid"
  spot_strategy        = "SpotAsPriceGo"
  spot_duration        = 0
  instance_type        = "ecs.e-c1m4.large"
  security_groups      = [alicloud_security_group.cn.id]
  vswitch_id           = alicloud_vswitch.cn.id
  user_data = base64gzip(templatefile("${path.module}/cloud-init.tpl", {
    ts_auth = data.sops_file.vars.data["ts_auth"]
  }))
  system_disk_category       = "cloud_essd_entry"
  system_disk_size           = "20"
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 10
}

