resource "alicloud_oss_bucket" "lab_os" {
  provider = alicloud.cn
  bucket   = "lab-os-ees4ushi"
}

resource "alicloud_oss_bucket_acl" "lab_os" {
  bucket = alicloud_oss_bucket.lab_os.bucket
  acl    = "private"
}

resource "alicloud_image_import" "cn_nixos_20250531" {
  provider   = alicloud.cn
  image_name = "nixos-20250531"
  disk_device_mapping {
    oss_bucket = alicloud_oss_bucket.lab_os.bucket
    oss_object = "nixos_20250531.qcow2"
  }
}

resource "alicloud_ram_user" "nix_cache" {
  provider = alicloud.cn
  name     = "nix-cache"
}

resource "alicloud_ram_access_key" "nix_cache" {
  user_name = alicloud_ram_user.nix_cache.name
}

resource "alicloud_ram_user" "lab_oss" {
  provider = alicloud.cn
  name     = "lab-oss"
}

resource "alicloud_ram_access_key" "lab_oss" {
  user_name = alicloud_ram_user.lab_oss.name
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

resource "alicloud_oss_bucket" "lab_oss" {
  provider      = alicloud.cn
  bucket        = "lab-bistro"
  storage_class = "Standard"

  lifecycle {
    ignore_changes = [policy]
  }
}

resource "alicloud_oss_bucket_acl" "lab_oss" {
  provider = alicloud.cn
  bucket   = alicloud_oss_bucket.lab_oss.bucket
  acl      = "private"
}

resource "alicloud_oss_bucket_policy" "lab_oss" {
  provider = alicloud.cn
  bucket   = alicloud_oss_bucket.lab_oss.bucket
  policy = jsonencode({
    "Version" : "1",
    "Statement" : [
      {
        "Action" : ["oss:*"],
        "Effect" : "Allow",
        "Principal" : [alicloud_ram_user.lab_oss.id],
        "Resource" : [
          "acs:oss:*:${alicloud_oss_bucket.lab_oss.owner}:${alicloud_oss_bucket.lab_oss.bucket}",
          "acs:oss:*:${alicloud_oss_bucket.lab_oss.owner}:${alicloud_oss_bucket.lab_oss.bucket}/*"
        ]
      }
    ]
  })
}
