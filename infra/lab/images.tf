resource "alicloud_oss_bucket" "lab_os" {
  provider = alicloud.cn
  bucket   = "lab-os-ees4ushi"
}

resource "alicloud_oss_bucket_acl" "lab_os" {
  bucket = alicloud_oss_bucket.lab_os.bucket
  acl    = "private"
}

resource "alicloud_image_import" "cn_nixos_20241109" {
  provider   = alicloud.cn
  image_name = "nixos"
  disk_device_mapping {
    oss_bucket = alicloud_oss_bucket.lab_os.bucket
    oss_object = "nixos-20241109.qcow2"
  }
}
