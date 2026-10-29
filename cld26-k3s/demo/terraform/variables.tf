variable "name" {
  description = "Name der VM, Präfix für ACL und Netzwerk"
  type        = string
  default     = "k3s-demo"
}

variable "block_name" {
  description = "Block, in dem die VM läuft"
  type        = string
  default     = "at-preview1-db"
}

variable "product_name" {
  description = "VM-Produkt, die k3s-Doku nennt 2 CPU-Kerne und 2 GB RAM"
  type        = string
  default     = "vServer Small"
}

variable "image_name" {
  description = "Image der VM"
  type        = string
  default     = "Debian 13 Cloud"
}

variable "ssh_public_key" {
  description = "Öffentlicher SSH-Schlüssel für den Benutzer deploy"
  type        = string
}
