output "public_ip" {
  value = eoscloud_public_ip.k3s.ip
}

output "ssh" {
  value = "ssh deploy@${eoscloud_public_ip.k3s.ip}"
}
