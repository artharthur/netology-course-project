output "alb_address"    { value = yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address }
output "cp_mon_public"  { value = yandex_compute_instance.cp_mon.network_interface[0].nat_ip_address }
output "cp_mon_private" { value = yandex_compute_instance.cp_mon.network_interface[0].ip_address }
output "web_privates"   { value = [yandex_compute_instance.cp_web_a.network_interface[0].ip_address, yandex_compute_instance.cp_web_d.network_interface[0].ip_address] }

output "ansible_inventory" {
  value = <<-EOT
[cp_mon]
${yandex_compute_instance.cp_mon.network_interface[0].nat_ip_address} ansible_user=ubuntu

[web]
${yandex_compute_instance.cp_web_a.network_interface[0].ip_address} ansible_user=ubuntu ansible_host=${yandex_compute_instance.cp_mon.network_interface[0].nat_ip_address} ansible_ssh_common_args='-o ProxyJump=ubuntu@${yandex_compute_instance.cp_mon.network_interface[0].nat_ip_address}'
${yandex_compute_instance.cp_web_d.network_interface[0].ip_address} ansible_user=ubuntu ansible_host=${yandex_compute_instance.cp_mon.network_interface[0].nat_ip_address} ansible_ssh_common_args='-o ProxyJump=ubuntu@${yandex_compute_instance.cp_mon.network_interface[0].nat_ip_address}'

[all:vars]
es_host=${yandex_compute_instance.cp_mon.network_interface[0].ip_address}
prom_host=${yandex_compute_instance.cp_mon.network_interface[0].ip_address}
  EOT
}
