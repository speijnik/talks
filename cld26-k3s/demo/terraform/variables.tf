variable "name" {
  description = "Name der VM, Präfix für ACL und Netzwerk"
  type        = string
  default     = "k3s-demo"
}

variable "product_name" {
  description = "VM-Produkt, k3s braucht mindestens 2 GB RAM"
  type        = string
  default     = "vServer Medium"
}

variable "image_name" {
  description = "Image der VM"
  type        = string
  default     = "Debian 13"
}

variable "ssh_public_key" {
  description = "Öffentlicher SSH-Schlüssel für den Benutzer deploy"
  type        = string
}
