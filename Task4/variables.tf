variable "yc_token" {
  type        = string
  description = "Yandex Cloud OAuth token"
  sensitive   = true
}

variable "yc_cloud_id" {
  type        = string
  description = "Yandex Cloud ID"
}

variable "yc_folder_id" {
  type        = string
  description = "Yandex Folder ID"
}

variable "yc_zone" {
  type        = string
  description = "Yandex Cloud zone"
  default     = "ru-central1-a"
}

# Network variables
variable "vpc_name" {
  type        = string
  description = "VPC name"
  default     = "main-vpc"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for public subnet"
  default     = "192.168.10.0/24"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for private subnet"
  default     = "192.168.20.0/24"
}

# VM variables
variable "vm_common_settings" {
  type = object({
    image_family = string
    disk_size    = number
    username     = string
  })
  default = {
    image_family = "ubuntu-2204-lts"
    disk_size    = 20
    username     = "ubuntu"
  }
}

variable "api_gateway_vm" {
  type = object({
    name          = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    name          = "api-gateway"
    platform_id   = "standard-v3"
    cores         = 2
    memory        = 2
    core_fraction = 100
  }
}

variable "internal_services_vm" {
  type = object({
    name          = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
  })
  default = {
    name          = "internal-services"
    platform_id   = "standard-v3"
    cores         = 4
    memory        = 8
    core_fraction = 100
  }
}

variable "ai_vm" {
  type = object({
    name          = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
  })
  default = {
    name          = "ai-services"
    platform_id   = "standard-v3"
    cores         = 8
    memory        = 16
    core_fraction = 100
    disk_size     = 50
  }
}

variable "db_vm" {
  type = object({
    name          = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
  })
  default = {
    name          = "db-rabbitmq"
    platform_id   = "standard-v3"
    cores         = 4
    memory        = 8
    core_fraction = 100
    disk_size     = 100
  }
}

variable "dwh_vm" {
  type = object({
    name          = string
    platform_id   = string
    cores         = number
    memory        = number
    core_fraction = number
    disk_size     = number
  })
  default = {
    name          = "dwh-services"
    platform_id   = "standard-v3"
    cores         = 4
    memory        = 8
    core_fraction = 100
    disk_size     = 200
  }
}