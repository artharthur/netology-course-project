variable "folder_id"   { type = string }
variable "cloud_id"    { type = string }
variable "ssh_user"    { type = string  default = "ubuntu" }
variable "ssh_pubkey"  { type = string } # содержимое публичного ключа

variable "allowed_cidrs" {
  description = "Белый список внешних IP (SSH/Grafana/Prometheus/Kibana)"
  type        = list(string)
  default     = ["1.2.3.4/32"] # <-- поменяй на свой IP
}

variable "zones" {
  type = object({ a = string, d = string })
  default = { a = "ru-central1-a", d = "ru-central1-d" }
}
