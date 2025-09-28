resource "yandex_alb_target_group" "tg" {
  name = "tg-web"
  target {
    ip_address = yandex_compute_instance.cp_web_a.network_interface[0].ip_address
    subnet_id  = yandex_vpc_subnet.web_a.id
  }
  target {
    ip_address = yandex_compute_instance.cp_web_d.network_interface[0].ip_address
    subnet_id  = yandex_vpc_subnet.web_d.id
  }
}

resource "yandex_alb_backend_group" "bg" {
  name = "bg-web"
  http_backend {
    name             = "http"
    weight           = 1
    port             = 80
    target_group_ids = [yandex_alb_target_group.tg.id]
    healthcheck {
      timeout = "1s"
      interval = "2s"
      healthy_threshold = 3
      unhealthy_threshold = 3
      http_healthcheck { path = "/" }
    }
  }
}

resource "yandex_alb_http_router" "router" { name = "router" }

resource "yandex_alb_virtual_host" "vh" {
  name           = "vh-web"
  http_router_id = yandex_alb_http_router.router.id
  route {
    name = "root"
    http {
      route { backend_group_id = yandex_alb_backend_group.bg.id }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name               = "alb"
  network_id         = yandex_vpc_network.net.id
  security_group_ids = [yandex_vpc_security_group.sg_alb.id]

  allocation_policy {
    location { zone_id = var.zones.a subnet_id = yandex_vpc_subnet.public.id }
  }

  listener {
    name = "http"
    endpoint { address { external_ipv4_address {} } port = 80 }
    http { handler { http_router_id = yandex_alb_http_router.router.id } }
  }
}
