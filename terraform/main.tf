# =============================================================================
# TERRAFORM - CONFIGURACIÓN PRINCIPAL
# Orquesta el módulo de SonarQube con los parámetros deseados
# =============================================================================

module "sonarqube" {
  source = "./modules/sonarqube"
  
  # -----------------------------------------------------------------------------
  # CONFIGURACIÓN DEL MÓDULO
  # -----------------------------------------------------------------------------
  sonarqube_version = "community"
  network_name      = "sonarqube-${var.environment}-network"
  db_password       = var.db_password
  
  # -----------------------------------------------------------------------------
  # RECURSOS: Ajustar según tu máquina
  # -----------------------------------------------------------------------------
  cpu_limit    = "2"
  memory_limit = "2048m"
}