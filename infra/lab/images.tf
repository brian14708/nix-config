resource "alicloud_oss_bucket" "lab_os" {
  provider = alicloud.cn
  bucket   = "lab-os-ees4ushi"
}

resource "alicloud_oss_bucket_acl" "lab_os" {
  bucket = alicloud_oss_bucket.lab_os.bucket
  acl    = "private"
}

resource "alicloud_image_import" "cn_nixos_20241117" {
  provider   = alicloud.cn
  image_name = "nixos-20241117"
  disk_device_mapping {
    oss_bucket = alicloud_oss_bucket.lab_os.bucket
    oss_object = "nixos-20241117.qcow2"
  }
}

resource "alicloud_ram_user" "nix_cache" {
  provider = alicloud.cn
  name     = "nix-cache"
}

resource "alicloud_ram_access_key" "nix_cache" {
  user_name = alicloud_ram_user.nix_cache.name
}


resource "alicloud_oss_bucket" "nix_cache" {
  provider = alicloud.cn
  bucket   = "nix-cache-miecho3l"

  lifecycle_rule {
    id      = "lifecycle"
    enabled = true
    expiration {
      days = 14
    }
  }

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "alicloud_oss_bucket_acl" "nix_cache" {
  bucket = alicloud_oss_bucket.nix_cache.bucket
  acl    = "private"
}

resource "alicloud_oss_bucket_policy" "nix_cache" {
  policy = jsonencode({
    "Version" : "1",
    "Statement" : [
      {
        "Action" : ["oss:GetObject", "oss:PutObject", "oss:DeleteObject"],
        "Effect" : "Allow",
        "Principal" : [alicloud_ram_user.nix_cache.id],
        "Resource" : ["acs:oss:*:${alicloud_oss_bucket.nix_cache.owner}:${alicloud_oss_bucket.nix_cache.bucket}/*"]
      }
    ]
  })
  bucket = alicloud_oss_bucket.nix_cache.bucket
}
