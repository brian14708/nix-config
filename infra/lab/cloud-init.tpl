#cloud-config
write_files:
  - path: /run/secrets/tailscale_key
    content: "${ts_auth}"
