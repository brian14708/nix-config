data "sops_file" "vars" {
  source_file = "vars.secret.yaml"
}

resource "alicloud_instance" "derp" {
  instance_name   = "derp"
  image_id        = "debian_12_4_x64_20G_alibase_20240126.vhd"
  instance_type   = "ecs.t6-c2m1.large"
  security_groups = [alicloud_security_group.cn.id]
  renewal_status  = "AutoRenewal"
}

resource "alicloud_eip_address" "derp" {
  isp                  = "BGP"
  address_name         = "derp"
  netmode              = "public"
  bandwidth            = "200"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
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
  host_name                     = "lab01"
  image_id                      = alicloud_image_import.cn_nixos.id
  instance_charge_type          = "PostPaid"
  spot_strategy                 = "SpotAsPriceGo"
  spot_duration                 = 0
  instance_type                 = "ecs.e-c1m4.large"
  security_enhancement_strategy = "Deactive"
  security_groups               = [alicloud_security_group.cn.id]
  vswitch_id                    = alicloud_vswitch.cn.id
  user_data = base64gzip(templatefile("${path.module}/cloud-init.tpl", {
    ts_auth = data.sops_file.vars.data["ts_auth"]
  }))
  system_disk_category = "cloud_essd_entry"
  system_disk_size     = "20"
}

resource "alicloud_eip_address" "lab01" {
  isp                  = "BGP"
  address_name         = "lab01"
  netmode              = "public"
  bandwidth            = "10"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "lab01" {
  allocation_id = alicloud_eip_address.lab01.id
  instance_id   = alicloud_instance.lab01.id
}

resource "alicloud_oss_bucket" "lab_os" {
  provider = alicloud.cn
  bucket   = "lab-os-ees4ushi"
}

resource "alicloud_oss_bucket_acl" "lab_os" {
  bucket = alicloud_oss_bucket.lab_os.bucket
  acl    = "private"
}

resource "alicloud_image_import" "cn_nixos" {
  provider   = alicloud.cn
  image_name = "nixos"
  disk_device_mapping {
    oss_bucket = alicloud_oss_bucket.lab_os.bucket
    oss_object = "nixos-20241108.qcow2"
  }
}
