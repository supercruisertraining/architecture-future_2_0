provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

# Создание VPC
resource "yandex_vpc_network" "main" {
  name = var.vpc_name
}

# Публичная подсеть для API Gateway
resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

# Приватная подсеть для внутренних сервисов
resource "yandex_vpc_subnet" "private" {
  name           = "private-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_cidr]
}

# Security Group для API Gateway
resource "yandex_vpc_security_group" "api_gateway_sg" {
  name        = "api-gateway-security-group"
  network_id  = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound to private network"
    v4_cidr_blocks = [var.private_subnet_cidr]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound to internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security Group для внутренних сервисов
resource "yandex_vpc_security_group" "internal_sg" {
  name        = "internal-security-group"
  network_id  = yandex_vpc_network.main.id

  ingress {
    protocol          = "ANY"
    description       = "Internal traffic"
    v4_cidr_blocks    = [var.public_subnet_cidr, var.private_subnet_cidr]
  }

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = [var.public_subnet_cidr]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

# Внешний IP для API Gateway
resource "yandex_vpc_address" "api_gateway_ip" {
  name = "api-gateway-ip"

  external_ipv4_address {
    zone_id = var.yc_zone
  }
}

# 1. ВМ API Gateway (публичная)
resource "yandex_compute_instance" "api_gateway" {
  name               = var.api_gateway_vm.name
  platform_id        = var.api_gateway_vm.platform_id
  zone               = var.yc_zone

  resources {
    cores         = var.api_gateway_vm.cores
    memory        = var.api_gateway_vm.memory
    core_fraction = var.api_gateway_vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vm_common_settings.disk_size
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.public.id
    nat            = true
    nat_ip_address = yandex_vpc_address.api_gateway_ip.external_ipv4_address[0].address
    security_group_ids = [yandex_vpc_security_group.api_gateway_sg.id]
  }

  scheduling_policy {
    preemptible = true
  }
}

# 2. ВМ для внутренних сервисов (приватная)
resource "yandex_compute_instance" "internal_services" {
  name               = var.internal_services_vm.name
  platform_id        = var.internal_services_vm.platform_id
  zone               = var.yc_zone

  resources {
    cores         = var.internal_services_vm.cores
    memory        = var.internal_services_vm.memory
    core_fraction = var.internal_services_vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.vm_common_settings.disk_size
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private.id
    nat            = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  scheduling_policy {
    preemptible = true
  }
}

# 3. ВМ для AI сервисов (приватная)
resource "yandex_compute_instance" "ai_services" {
  name               = var.ai_vm.name
  platform_id        = var.ai_vm.platform_id
  zone               = var.yc_zone

  resources {
    cores         = var.ai_vm.cores
    memory        = var.ai_vm.memory
    core_fraction = var.ai_vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.ai_vm.disk_size
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private.id
    nat            = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  scheduling_policy {
    preemptible = true
  }
}

# 4. ВМ для СУБД и RabbitMQ (приватная)
resource "yandex_compute_instance" "db_rabbitmq" {
  name               = var.db_vm.name
  platform_id        = var.db_vm.platform_id
  zone               = var.yc_zone

  resources {
    cores         = var.db_vm.cores
    memory        = var.db_vm.memory
    core_fraction = var.db_vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.db_vm.disk_size
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private.id
    nat            = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  scheduling_policy {
    preemptible = false # Для БД лучше не использовать прерываемые ВМ
  }
}

# 5. ВМ для DWH сервисов (приватная)
resource "yandex_compute_instance" "dwh_services" {
  name               = var.dwh_vm.name
  platform_id        = var.dwh_vm.platform_id
  zone               = var.yc_zone

  resources {
    cores         = var.dwh_vm.cores
    memory        = var.dwh_vm.memory
    core_fraction = var.dwh_vm.core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size     = var.dwh_vm.disk_size
    }
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.private.id
    nat            = false
    security_group_ids = [yandex_vpc_security_group.internal_sg.id]
  }

  scheduling_policy {
    preemptible = true
  }
}

# Data source для получения ID образа Ubuntu
data "yandex_compute_image" "ubuntu" {
  family = var.vm_common_settings.image_family
}