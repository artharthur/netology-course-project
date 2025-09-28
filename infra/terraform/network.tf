resource "yandex_vpc_network" "net" { name = "net-course" }

resource "yandex_vpc_subnet" "public" {
  name           = "subnet-public"
  zone           = var.zones.a
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.129.0.0/24"]
}

resource "yandex_vpc_subnet" "web_a" {
  name           = "subnet-web-a"
  zone           = var.zones.a
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.128.0.0/24"]
}

resource "yandex_vpc_subnet" "web_d" {
  name           = "subnet-web-d"
  zone           = var.zones.d
  network_id     = yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.130.0.0/24"]
}

# SG: ALB
resource "yandex_vpc_security_group" "sg_alb" {
  name       = "sg-alb"
  network_id = yandex_vpc_network.net.id

  ingress { protocol = "TCP" port = 80 v4_cidr_blocks = ["0.0.0.0/0"] }
  egress  { protocol = "ANY" v4_cidr_blocks = ["0.0.0.0/0"] }
}

# SG: web
resource "yandex_vpc_security_group" "sg_web" {
  name       = "sg-web"
  network_id = yandex_vpc_network.net.id

  ingress { protocol = "TCP" port = 80   security_group_id = yandex_vpc_security_group.sg_alb.id }
  ingress { protocol = "TCP" port = 80   predefined_target = "loadbalancer_healthchecks" }
  ingress { protocol = "TCP" port = 22   security_group_id = yandex_vpc_security_group.sg_bastion.id }
  ingress { protocol = "TCP" port = 9100 security_group_id = yandex_vpc_security_group.sg_bastion.id }
  ingress { protocol = "TCP" port = 4040 security_group_id = yandex_vpc_security_group.sg_bastion.id }
  egress  { protocol = "ANY" v4_cidr_blocks = ["0.0.0.0/0"] }
}

# SG: bastion/monitoring
resource "yandex_vpc_security_group" "sg_bastion" {
  name       = "sg-bastion"
  network_id = yandex_vpc_network.net.id

  ingress { protocol = "TCP" port = 22   v4_cidr_blocks = var.allowed_cidrs }
  ingress { protocol = "TCP" port = 3000 v4_cidr_blocks = var.allowed_cidrs } # Grafana
  ingress { protocol = "TCP" port = 9090 v4_cidr_blocks = var.allowed_cidrs } # Prometheus
  ingress { protocol = "TCP" port = 5601 v4_cidr_blocks = var.allowed_cidrs } # Kibana
  ingress { protocol = "TCP" port = 9200 security_group_id = yandex_vpc_security_group.sg_web.id } # ES только от web
  egress  { protocol = "ANY" v4_cidr_blocks = ["0.0.0.0/0"] }
}
