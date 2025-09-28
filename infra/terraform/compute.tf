locals {
  img_family = "ubuntu-2404-lts"
}

data "yandex_compute_image" "ubuntu" { family = local.img_family }

resource "yandex_compute_instance" "cp_mon" {
  name = "cp-mon"
  zone = var.zones.a
  resources { cores = 2 memory = 4 }
  boot_disk { initialize_params { image_id = data.yandex_compute_image.ubuntu.id size = 10 } }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.sg_bastion.id]
  }

  metadata = {
    "ssh-keys" = "${var.ssh_user}:${var.ssh_pubkey}"
  }
}

resource "yandex_compute_instance" "cp_web_a" {
  name = "cp-web-a"
  zone = var.zones.a
  resources { cores = 2 memory = 2 }
  boot_disk { initialize_params { image_id = data.yandex_compute_image.ubuntu.id size = 10 } }

  network_interface {
    subnet_id          = yandex_vpc_subnet.web_a.id
    security_group_ids = [yandex_vpc_security_group.sg_web.id]
  }

  metadata = {
    "ssh-keys" = "${var.ssh_user}:${var.ssh_pubkey}"
  }
}

resource "yandex_compute_instance" "cp_web_d" {
  name = "cp-web-d"
  zone = var.zones.d
  resources { cores = 2 memory = 2 }
  boot_disk { initialize_params { image_id = data.yandex_compute_image.ubuntu.id size = 10 } }

  network_interface {
    subnet_id          = yandex_vpc_subnet.web_d.id
    security_group_ids = [yandex_vpc_security_group.sg_web.id]
  }

  metadata = {
    "ssh-keys" = "${var.ssh_user}:${var.ssh_pubkey}"
  }
}
