# 🛡️ SonarQube QA Infrastructure

Infraestructura como Código (IaC) para desplegar **SonarQube Community Edition** con **PostgreSQL**, orquestado por **GitHub Actions** y configurado con **Quality Gates** automatizados.

---

## 🏗️ Arquitectura - Mapa Tecnológico

```mermaid
flowchart TB
    subgraph DESARROLLO["📱 ENTORNO DE DESARROLLO"]
        DEV[("👤 Developer")]
        CODE[("📝 Código Fuente")]
        PR[("🔀 Pull Request")]
    end

    subgraph PLATAFORMA["☁️ PLATAFORMA CLOUD"]
        subgraph GITHUB["🐙 GitHub"]
            REPO["📁 Repository"]
            ACTIONS["⚙️ GitHub Actions"]
            TRIGGERS["🎯 Triggers"]
        end

        subgraph CI_CD["🔄 CI/CD Pipeline"]
            VALIDATE["✅ Validar\nTerraform"]
            BUILD["🐳 Build\nDocker + Trivy"]
            DEPLOY["🚀 Deploy\nInfraestructura"]
            CONFIGURE["⚙️ Config\nQuality Gates"]
        end
    end

    subgraph INFRA["🖥️ INFRAESTRUCTURA"]
        subgraph DOCKER["🐳 Docker"]
            SQ["🔍 SonarQube\nServer"]
            PG["🗄️ PostgreSQL\nDatabase"]
            NET["🌐 Network"]
        end
    end

    subgraph ANALISIS["📊 ANÁLISIS DE CÓDIGO"]
        SCAN["🔎 SonarScanner"]
        METRICS["📈 Métricas\n• Cobertura\n• Bugs\n• Vulnerabilidades"]
        QG["🚦 Quality Gates\n• Coverage ≥ 80%\n• 0 Bugs\n• 0 Vulnerab."]
    end

    subgraph RESULTADOS["📋 RESULTADOS"]
        PASS["✅ PASS\nAprobado"]
        FAIL["❌ FAIL\nRechazado"]
    end

    DEV --> CODE
    CODE --> PR
    PR --> REPO
    REPO --> TRIGGERS
    TRIGGERS --> ACTIONS
    
    ACTIONS --> VALIDATE
    VALIDATE --> BUILD
    BUILD --> DEPLOY
    DEPLOY --> CONFIGURE
    
    DEPLOY --> SQ
    SQ --> PG
    SQ --> NET
    
    SQ --> SCAN
    SCAN --> METRICS
    METRICS --> QG
    
    QG --> PASS
    QG --> FAIL
    
    PASS -.->|"Merge"| REPO
    FAIL -.->|"Bloqueado"| REPO

    style DEV fill:#00BCD4,color:#fff
    style CODE fill:#2962FF,color:#fff
    style PR fill:#7C4DFF,color:#fff
    style REPO fill:#2962FF,color:#fff
    style ACTIONS fill:#00C853,color:#000
    style VALIDATE fill:#00E676,color:#000
    style BUILD fill:#76FF03,color:#000
    style DEPLOY fill:#64DD17,color:#000
    style CONFIGURE fill:#1DE9B6,color:#000
    style SQ fill:#76FF03,color:#000
    style PG fill:#FFD600,color:#000
    style NET fill:#448AFF,color:#fff
    style SCAN fill:#FFAB00,color:#000
    style METRICS fill:#FF9100,color:#000
    style QG fill:#FFD600,color:#000
    style PASS fill:#00E676,color:#000
    style FAIL fill:#FF1744,color:#fff
```

---

## 🚀 Inicio Rápido

### Opción 1: Docker Compose (Local)

```bash
cd docker
docker-compose up -d
# Acceder: http://localhost:9000
# Credenciales por defecto: admin / admin
```

### Opción 2: Terraform (Local)

```bash
cd terraform
terraform init
terraform plan -var="db_password=sonar"
terraform apply -var="db_password=sonar"
```

---

## 📁 Estructura del Proyecto

```
sonarqube-qa-infrastructure/
├── .github/workflows/     # Pipelines CI/CD de GitHub Actions
├── docker/               # Dockerfile y docker-compose
├── terraform/            # IaC - Módulos y configuración
├── docs/                 # Documentación técnica
├── .gitignore            # Archivos ignorados por Git
└── README.md             # Este archivo
```

---

## 🔧 Componentes

### 🐳 Docker
- **SonarQube**: Community Edition 10.6
- **PostgreSQL**: Base de datos 15-alpine

### 🏗️ Terraform
- Provider: kreuzwerker/docker
- Módulos: sonarqube (contenedores, redes, volúmenes)

### ⚙️ GitHub Actions
1. **validate-infra**: Valida configuración Terraform
2. **build-and-scan**: Build Docker + Trivy security scan
3. **deploy**: Aplica cambios de infraestructura
4. **configure-quality-gates**: Configura reglas QA

---

## 📖 Documentación

### Guías de configuración
- [🔐 Configurar Secrets en GitHub](./docs/setup-github-secrets.md) - Cómo configurar variables de entorno y tokens
- [⚙️ GitHub Actions Explicado](./docs/github-actions.md) - Explicación detallada del pipeline CI/CD
- [🚀 Guía de Despliegue](./docs/deployment-guide.md) - Cómo levantar SonarQube local y en la nube

### Temas avanzados
- [Configuración de Quality Gates](./docs/quality-gates.md)
- [Pipeline CI/CD](./docs/cicd-pipeline.md)

---

## 🧪 Comandos Útiles

```bash
# Levantar servicios
docker-compose -f docker/docker-compose.yml up -d

# Ver estado
docker-compose -f docker/docker-compose.yml ps

# Ver logs
docker-compose -f docker/docker-compose.yml logs -f sonarqube

# Detener servicios
docker-compose -f docker/docker-compose.yml down

# Validar Terraform
cd terraform && terraform validate

# Destruir infraestructura
cd terraform && terraform destroy -var="db_password=sonar"
```

---

## 🔐 Variables de Entorno

### Terraform (Local)
```bash
export TF_VAR_db_password="sonar"
export TF_VAR_environment="dev"
```

### Secretos GitHub (Repositorio)
| Secreto | Descripción |
|---------|-------------|
| `SONAR_HOST_URL` | URL de SonarQube (http://localhost:9000) |
| `SONAR_TOKEN` | Token de SonarQube (generar en: My Account → Security) |
| `DB_PASSWORD` | Password de PostgreSQL |

---

## 🎯 Quality Gates Configurados

| Métrica | Condición | Descripción |
|---------|-----------|-------------|
| Coverage | < 80% | Cobertura de código mínima |
| blocker_violations | > 0 | Bugs bloqueantes |
| vulnerabilities | > 0 | Vulnerabilidades de seguridad |
| critical_violations | > 0 | Code smells críticos |

---

## 📝 Licencia

GPL-3.0 - Ver LICENSE para más detalles.

---

**Grupo G2 - QA Framework Demo**  
🏫 Universidad Centroamericana (UCE)  
📅 Semestre 2026