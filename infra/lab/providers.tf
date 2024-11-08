variable "encryption_key" {
}

terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
    sops = {
      source  = "carlpett/sops"
      version = "~> 1"
    }
  }

  encryption {
    key_provider "pbkdf2" "key" {
      passphrase = var.encryption_key
    }
    method "aes_gcm" "encrypted" {
      keys = key_provider.pbkdf2.key
    }
    state {
      method   = method.aes_gcm.encrypted
      enforced = true
    }
    plan {
      method   = method.aes_gcm.encrypted
      enforced = true
    }
  }

  backend "gcs" {
    bucket = "ops-state"
    prefix = "lab"
  }
}

provider "cloudflare" {}

provider "alicloud" {
  region = "cn-beijing"
  alias  = "cn"
}

provider "sops" {}
