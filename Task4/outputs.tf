output "api_gateway_public_ip" {
  description = "Public IP address of API Gateway VM"
  value       = yandex_vpc_address.api_gateway_ip.external_ipv4_address[0].address
}

output "api_gateway_private_ip" {
  description = "Private IP address of API Gateway VM"
  value       = yandex_compute_instance.api_gateway.network_interface[0].ip_address
}

output "internal_services_ip" {
  description = "Private IP address of Internal Services VM"
  value       = yandex_compute_instance.internal_services.network_interface[0].ip_address
}

output "ai_services_ip" {
  description = "Private IP address of AI Services VM"
  value       = yandex_compute_instance.ai_services.network_interface[0].ip_address
}

output "db_rabbitmq_ip" {
  description = "Private IP address of DB and RabbitMQ VM"
  value       = yandex_compute_instance.db_rabbitmq.network_interface[0].ip_address
}

output "dwh_services_ip" {
  description = "Private IP address of DWH Services VM"
  value       = yandex_compute_instance.dwh_services.network_interface[0].ip_address
}

output "vpc_network_id" {
  description = "ID of the created VPC network"
  value       = yandex_vpc_network.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = yandex_vpc_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = yandex_vpc_subnet.private.id
}

output "ssh_connection_command" {
  description = "SSH command to connect to API Gateway"
  value       = "ssh ${var.vm_common_settings.username}@${yandex_vpc_address.api_gateway_ip.external_ipv4_address[0].address}"
}