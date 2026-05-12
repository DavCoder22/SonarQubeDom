# =============================================================================
# TERRAFORM - OUTPUTS DEL MÓDULO SONARQUBE
# Estos valores se muestran después de terraform apply
# =============================================================================

output "sonarqube_url" {
  description = "URL de acceso a SonarQube"
  value       = "http://localhost:9000"
}

output "sonarqube_container_name" {
  description = "Nombre del contenedor SonarQube"
  value       = docker_container.sonarqube.name
}

output "database_container_name" {
  description = "Nombre del contenedor PostgreSQL"
  value       = docker_container.sonarqube_db.name
}

output "network_name" {
  description = "Nombre de la red Docker creada"
  value       = docker_network.sonarqube.name
}