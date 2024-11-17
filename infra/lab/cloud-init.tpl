#cloud-config
write_files:
%{ for n, data in secrets }
  - path: /var/secrets/${n}
    permissions: '0400'
    content: |
      ${indent(6, data)}
%{ endfor }
