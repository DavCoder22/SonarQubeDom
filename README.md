# 🛡️ SonarQube QA Infrastructure

Infraestructura como Código (IaC) para desplegar **SonarQube Community Edition** con **PostgreSQL**, orquestado por **GitHub Actions** y configurado con **Quality Gates** automatizados.

---

## 🏗️ Arquitectura

```dot
digraph "SonarQube + Quality Gates + GitHub Actions" {
    bgcolor="transparent";
    rankdir=TB;
    node [
        shape=box,
        style="rounded,filled",
        fontname="Helvetica",
        fontsize=11,
        penwidth=1.5
    ];
    edge [
        fontname="Helvetica",
        fontsize=10,
        penwidth=1.5
    ];

    Developer [
        label="👤 Developer\n(Push/PR)",
        shape=ellipse,
        fillcolor="#00BCD4",
        color="#00E5FF",
        fontcolor="#FFFFFF"
    ];
    
    GitHub_Repo [
        label="📁 GitHub\nRepository",
        shape=folder,
        fillcolor="#2962FF",
        color="#448AFF",
        fontcolor="#FFFFFF"
    ];
    
    GitHub_Actions [
        label="⚙️ GitHub Actions\n(Orquestador CI/CD)\n• Validar Terraform\n• Build Docker\n• Deploy",
        shape=component,
        fillcolor="#00C853",
        color="#69F0AE",
        fontcolor="#000000"
    ];
    
    SonarQube [
        label="🔍 SonarQube\n(Análisis de Código)\n• Calidad Estática\n• Cobertura\n• Vulnerabilidades",
        shape=box3d,
        fillcolor="#76FF03",
        color="#64DD17",
        fontcolor="#000000"
    ];
    
    Quality_Gates [
        label="🚦 Quality Gates\n(Reglas QA)\n• Cobertura ≥ 80%\n• 0 Bugs Críticos\n• 0 Vulnerabilidades\n• 0 Code Smells",
        shape=diamond,
        fillcolor="#FFD600",
        color="#FFFF00",
        fontcolor="#000000"
    ];
    
    Pass [
        label="✅ PASS\nPR Aprobado\nMerge Permitido",
        shape=ellipse,
        fillcolor="#00E676",
        color="#69F0AE",
        fontcolor="#000000"
    ];
    
    Fail [
        label="❌ FAIL\nPR Rechazado\nMerge Bloqueado",
        shape=ellipse,
        fillcolor="#FF1744",
        color="#FF5252",
        fontcolor="#FFFFFF"
    ];

    Developer -> GitHub_Repo [
        label="1. git push / Pull Request",
        color="#00E5FF",
        fontcolor="#00E5FF"
    ];
    
    GitHub_Repo -> GitHub_Actions [
        label="2. Trigger automático",
        color="#448AFF",
        fontcolor="#448AFF"
    ];
    
    GitHub_Actions -> SonarQube [
        label="3. Ejecuta análisis estático",
        color="#69F0AE",
        fontcolor="#69F0AE"
    ];
    
    SonarQube -> Quality_Gates [
        label="4. Evalúa métricas",
        color="#76FF03",
        fontcolor="#76FF03"
    ];
    
    Quality_Gates -> Pass [
        label="Cumple ≥ 80% cobertura",
        color="#00E676",
        fontcolor="#00E676"
    ];
    
    Quality_Gates -> Fail [
        label="No cumple métricas",
        color="#FF5252",
        fontcolor="#FF5252"
    ];
    
    Pass -> GitHub_Repo [
        label="6a. Permite merge",
        color="#00E676",
        fontcolor="#00E676",
        style="dashed"
    ];
    
    Fail -> GitHub_Repo [
        label="6b. Bloquea merge",
        color="#FF1744",
        fontcolor="#FF1744",
        style="dashed",
        penwidth=2
    ];
}
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

- [Guía de Despliegue](./docs/deployment-guide.md)
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