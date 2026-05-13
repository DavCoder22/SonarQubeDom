# =============================================================================
# TERRAFORM - MÓDULO SONARQUBE
# Infraestructura como Código para desplegar SonarQube con Docker
# NOTA: Usa H2 embebida (sin PostgreSQL)
# =============================================================================

# -----------------------------------------------------------------------------
# RECURSO 1: Red Docker privada
# -----------------------------------------------------------------------------
resource "docker_network" "sonarqube" {
  name   = var.network_name
  driver = "bridge"
}

# -----------------------------------------------------------------------------
# RECURSO 2: Volúmenes persistentes para datos
# -----------------------------------------------------------------------------
resource "docker_volume" "sonarqube_data" {
  name = "sonarqube_data"
}

resource "docker_volume" "sonarqube_extensions" {
  name = "sonarqube_extensions"
}

resource "docker_volume" "sonarqube_logs" {
  name = "sonarqube_logs"
}

# -----------------------------------------------------------------------------
# POSTGRESQL (COMENTADO - opcional)
# Descomenta si necesitas PostgreSQL en lugar de H2
# -----------------------------------------------------------------------------
# resource "docker_volume" "postgresql_data" {
#   name = "postgresql_data"
# }

# resource "docker_container" "sonarqube_db" {
#   name  = "sonarqube-postgres"
#   image = "postgres:15-alpine"
#   env = [
#     "POSTGRES_USER=sonar",
#     "POSTGRES_PASSWORD=${var.db_password}",
#     "POSTGRES_DB=sonarqube"
#   ]
#   networks_advanced {
#     name = docker_network.sonarqube.name
#   }
#   volumes {
#     volume_name    = docker_volume.postgresql_data.name
#     container_path = "/var/lib/postgresql/data"
#   }
#   restart = "unless-stopped"
#   resources {
#     memory = var.memory_limit
#     cpu    = var.cpu_limit
#   }
# }

# -----------------------------------------------------------------------------
# RECURSO: Contenedor SonarQube (con H2 embebida)
# -----------------------------------------------------------------------------
resource "docker_container" "sonarqube" {
  name  = "sonarqube-server"
  image = "sonarqube:${var.sonarqube_version}"

  # Sin dependencia de PostgreSQL (usa H2)
  # depends_on = [docker_container.sonarqube_db]

  # Exponer puerto 9000 al host
  ports {
    internal = 9000
    external = 9000
  }

  # Variables de entorno (sin PostgreSQL - usa H2 por defecto)
  env = [
    "SONAR_WEB_JAVAOPTS=-Xmx512m -Xms128m",
    "SONAR_CE_JAVAOPTS=-Xmx512m -Xms128m",
    "SONAR_SEARCH_JAVAOPTS=-Xmx512m -Xms512m"
    # DESCOMENTAR SI USAS POSTGRESQL:
    # "SONAR_JDBC_URL=jdbc:postgresql://sonarqube-postgres:5432/sonarqube",
    # "SONAR_JDBC_USERNAME=sonar",
    # "SONAR_JDBC_PASSWORD=${var.db_password}",
  ]

  # Conectar a la red privada
  networks_advanced {
    name = docker_network.sonarqube.name
  }

  # Múltiples volúmenes persistentes
  volumes {
    volume_name    = docker_volume.sonarqube_data.name
    container_path = "/opt/sonarqube/data"
  }

  volumes {
    volume_name    = docker_volume.sonarqube_extensions.name
    container_path = "/opt/sonarqube/extensions"
  }

  volumes {
    volume_name    = docker_volume.sonarqube_logs.name
    container_path = "/opt/sonarqube/logs"
  }

  # Política de reinicio
  restart = "unless-stopped"

  # Límites de recursos
  resources {
    memory = var.memory_limit
    cpu    = var.cpu_limit
  }

  # Health check
  healthcheck {
    test     = ["CMD", "curl", "-f", "http://localhost:9000/api/system/status"]
    interval = "30s"
    timeout  = "10s"
    retries  = 3
  }
}