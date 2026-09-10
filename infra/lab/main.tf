data "sops_file" "vars" {
  source_file = "vars.secrets.yaml"
}

resource "random_password" "lab_tunnel_secret" {
  length = 64
}

resource "cloudflare_zero_trust_tunnel_cloudflared" "lab" {
  account_id    = data.sops_file.vars.data["cloudflare_account_id"]
  name          = "lab"
  tunnel_secret = base64sha256(random_password.lab_tunnel_secret.result)
}

resource "cloudflare_zero_trust_tunnel_cloudflared_config" "lab" {
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.lab.id
  account_id = data.sops_file.vars.data["cloudflare_account_id"]
  config = {
    ingress = [
      {
        service = "http://127.0.0.1:80"
      }
    ]
  }
}

resource "cloudflare_dns_record" "lab_wildcard" {
  zone_id = data.sops_file.vars.data["cloudflare_zone_id"]
  name    = "*"
  content = "${cloudflare_zero_trust_tunnel_cloudflared.lab.id}.cfargotunnel.com"
  type    = "CNAME"
  ttl     = 1
  proxied = true
}

resource "cloudflare_dns_record" "jump" {
  zone_id = data.sops_file.vars.data["cloudflare_zone_id"]
  name    = "jump"
  content = alicloud_eip_address.watchtower.ip_address
  type    = "A"
  ttl     = 300
  proxied = false
}

resource "tailscale_tailnet_key" "lab" {
  description         = "lab cloud-init"
  reusable            = false
  ephemeral           = false
  preauthorized       = true
  expiry              = 7776000
  recreate_if_invalid = "always"
  tags                = ["tag:lab"]
}

resource "alicloud_instance" "watchtower" {
  instance_name     = "watchtower"
  host_name         = "watchtower"
  image_id          = alicloud_image_import.cn_nixos_20250531.id
  instance_type     = "ecs.t6-c2m1.large"
  renewal_status    = "AutoRenewal"
  auto_renew_period = 12
  security_groups   = [alicloud_security_group.cn.id]
  vswitch_id        = alicloud_vswitch.cn.id
  # Only the tailscale auth key is delivered via cloud-init; the cloudflared
  # tunnel token comes from sops-nix (secrets/lab.yaml).
  user_data = base64gzip(templatefile("${path.module}/cloud-init.tpl", {
    secrets = {
      tailscale_key = tailscale_tailnet_key.lab.key
    }
  }))
  lifecycle {
    ignore_changes = [image_id, user_data]
  }
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
  count                = 0
  instance_name        = "lab01"
  host_name            = "lab01"
  image_id             = alicloud_image_import.cn_nixos_20250531.id
  instance_charge_type = "PostPaid"
  spot_strategy        = "SpotAsPriceGo"
  spot_duration        = 0
  instance_type        = "ecs.e-c1m4.large"
  security_groups      = [alicloud_security_group.cn.id]
  vswitch_id           = alicloud_vswitch.cn.id
  user_data = base64gzip(templatefile("${path.module}/cloud-init.tpl", {
    secrets = {}
  }))
  system_disk_category       = "cloud_essd_entry"
  system_disk_size           = "20"
  internet_charge_type       = "PayByTraffic"
  internet_max_bandwidth_out = 10
  lifecycle {
    ignore_changes = [image_id, user_data]
  }
}
