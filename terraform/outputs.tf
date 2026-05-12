# =============================================================================
# TERRAFORM - OUTPUTS GLOBALES
# Re-exporta los outputs del módulo para fácil acceso
# =============================================================================

output "sonarqube_access_url" {
  description = "URL para acceder a SonarQube en el navegador"
  value       = module.sonarqube.sonarqube_url
}

output "environment" {
  description = "Entorno actual desplegado"
  value       = var.environment
}