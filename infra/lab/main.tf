resource "alicloud_instance" "derp" {
  instance_name   = "derp"
  image_id        = "debian_12_4_x64_20G_alibase_20240126.vhd"
  instance_type   = "ecs.t6-c2m1.large"
  security_groups = [alicloud_security_group.cn.id]
  renewal_status  = "AutoRenewal"
}

resource "alicloud_eip_address" "derp" {
  isp          = "BGP"
  address_name = "derp"
  netmode      = "public"
  bandwidth    = "200"
  payment_type = "PayAsYouGo"
}

resource "alicloud_ecs_network_interface" "derp" {
  vswitch_id         = alicloud_vswitch.cn.id
  security_group_ids = [alicloud_security_group.cn.id]
}

resource "alicloud_ecs_network_interface_attachment" "derp" {
  network_interface_id = alicloud_ecs_network_interface.derp.id
  instance_id          = alicloud_instance.derp.id
}

resource "alicloud_instance" "lab01" {
  instance_name                 = "lab01"
  image_id                      = "debian_12_6_x64_20G_alibase_20240819.vhd"
  instance_charge_type          = "PostPaid"
  spot_strategy                 = "SpotAsPriceGo"
  spot_duration                 = 0
  instance_type                 = "ecs.e-c1m4.large"
  security_enhancement_strategy = "Deactive"
  security_groups               = [alicloud_security_group.cn.id]
  vswitch_id                    = alicloud_vswitch.cn.id
  user_data                     = base64gzip(templatefile("${path.module}/cloud-init.tpl", {}))
  system_disk_category          = "cloud_essd_entry"
  system_disk_size              = "20"
}

resource "alicloud_eip_address" "lab01" {
  isp          = "BGP"
  address_name = "lab01"
  netmode      = "public"
  bandwidth    = "200"
  payment_type = "PayAsYouGo"
}

resource "alicloud_eip_association" "lab01" {
  allocation_id = alicloud_eip_address.lab01.id
  instance_id   = alicloud_instance.lab01.id
}

data "cloudflare_zone" "default" {
  name = "brian14708.dev"
}
resource "cloudflare_record" "lab01" {
  zone_id = data.cloudflare_zone.default.id
  name    = "lab01"
  content = alicloud_eip_address.lab01.ip_address
  type    = "A"
}

