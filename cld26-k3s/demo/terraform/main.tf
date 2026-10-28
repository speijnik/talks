terraform {
  required_providers {
    eoscloud = {
      source  = "dl.eoscloud.io/eos/eoscloud"
      version = ">= 0.12.0"
    }
  }
}

# Zugangsdaten über EOS_CLIENT_ID und EOS_CLIENT_SECRET
provider "eoscloud" {}

data "eoscloud_blocks" "all" {}
data "eoscloud_products" "all" {}
data "eoscloud_vm_images" "all" {}

locals {
  block_id   = data.eoscloud_blocks.all.blocks[0].id
  product_id = [for p in data.eoscloud_products.all.products : p.id if p.active && p.kind == "vm" && p.name == var.product_name][0]
  image_id   = [for i in data.eoscloud_vm_images.all.vm_images : i.id if i.name == var.image_name][0]
}

resource "eoscloud_acl" "k3s" {
  block_id = local.block_id
  name     = "${var.name}-acl"
}

# Nur SSH und HTTP. kubectl läuft direkt auf der VM, 6443 bleibt zu.
resource "eoscloud_acl_rule" "allow" {
  for_each = toset(["22", "80"])

  acl_id            = eoscloud_acl.k3s.id
  action            = "allow"
  protocol          = "tcp"
  sources           = ["0.0.0.0/0"]
  destination_ports = [each.value]
}

resource "eoscloud_network" "k3s" {
  block_id  = local.block_id
  name      = "${var.name}-network"
  v4_prefix = "10.0.1.0/24"
  acl_ids   = [eoscloud_acl.k3s.id]
}

resource "eoscloud_vm" "k3s" {
  block_id   = local.block_id
  product_id = local.product_id
  network_id = eoscloud_network.k3s.id
  image_id   = local.image_id
  name       = var.name
  disk_size  = 20000 # MB

  user_data = templatefile("${path.module}/cloud-init.yaml", {
    ssh_public_key = var.ssh_public_key
  })
}

resource "eoscloud_public_ip" "k3s" {
  network_id = eoscloud_network.k3s.id
  ip_family  = 4
}

resource "eoscloud_public_ip_attachment" "k3s" {
  public_ip_id = eoscloud_public_ip.k3s.id
  vm_id        = eoscloud_vm.k3s.id
}
