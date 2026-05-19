# Lab 2: VCS Workflows

![Terraform](https://img.shields.io/badge/HCP_Terraform-VCS_Workflows-7B42BC?style=flat&logo=terraform)

## Objetivo

Aprender como HCP Terraform integra con sistemas de control de versiones (GitHub, GitLab, Bitbucket) para ejecutar plans automaticos en cada Pull Request y applies al mergear a `main`. El lab practica la estructura de archivos y documenta el flujo, usando un repositorio git local para los pasos que requieren conectividad.

## Duracion

30 minutos

## Prerrequisitos

- Lab 1 del modulo 08 completado
- Terraform instalado
- Git instalado
- (Opcional) Cuenta GitHub para ver el flujo de PR en la UI real

## Instrucciones Paso a Paso

### Paso 1: Crear el directorio de trabajo e inicializar git

```bash
mkdir -p /root/lab && cd /root/lab
```

```bash
git init
```

Un repositorio git es el prerequisito del VCS Workflow: HCP Terraform clona el repo en cada run, sin necesidad de subir archivos manualmente.

### Paso 2: Crear main.tf con la configuracion del provider

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

variable "version_app" {
  description = "Version de la aplicacion a desplegar"
  type        = string
  default     = "1.0.0"
}

resource "local_file" "version" {
  filename = "/root/lab/version.txt"
  content  = "version=${var.version_app}\ndeployado_por=terraform-vcs\n"
}

output "version" {
  value = "App version: ${var.version_app}"
}
EOF
```

Este archivo Terraform usa el provider `local` para simular un despliegue. En un proyecto real, aqui estarian recursos de AWS, Azure o GCP que HCP Terraform aprovisionaria remotamente.

### Paso 3: Crear el primer commit

```bash
git add main.tf
```

```bash
git commit -m "feat: configuracion inicial para VCS workflow"
```

El historial de commits es fundamental en HCP Terraform: cada run queda vinculado al commit exacto que lo disparo, permitiendo rastrear quien hizo que cambio y cuando.

### Paso 4: Documentar la configuracion del VCS Workflow en HCP Terraform

```bash
touch vcs-workflow-notas.md
```

```bash
cat > vcs-workflow-notas.md <<'EOF'
# VCS Workflows en HCP Terraform

## Como conectar GitHub con HCP Terraform

1. Organization Settings > VCS Providers > Add VCS Provider
2. Seleccionar: GitHub.com
3. Seguir el flujo OAuth (HCP solicita permisos al repo)
4. Guardar el nombre del provider (ej: "github-personal")

## Crear un Workspace con VCS Trigger

1. Workspaces > New Workspace > Version control workflow
2. Conectar el VCS provider (GitHub)
3. Seleccionar el repositorio con el codigo Terraform
4. Configurar:
   - Terraform Working Directory: . (raiz del repo)
   - VCS Branch: main
   - Auto Apply: Off para produccion, On para dev
5. Create workspace

## Flujo de trabajo con Pull Requests

PUSH a un branch de feature:
  -> HCP Terraform ejecuta un "speculative plan"
  -> El resultado aparece como check en el PR de GitHub
  -> Si el plan falla: el PR muestra error (no bloquea el merge por defecto)

MERGE a main:
  -> HCP Terraform detecta el push a main
  -> Ejecuta terraform init + terraform plan
  -> Si Auto Apply: ejecuta terraform apply automaticamente
  -> Si Manual Apply: espera confirmacion en la UI

## Tipos de runs en HCP Terraform

| Tipo              | Cuando ocurre                        | Aplica?  |
|-------------------|--------------------------------------|----------|
| Speculative Plan  | Push a branch / PR abierto           | Nunca    |
| Plan              | Push a branch de trigger (main)      | Con confirm |
| Apply             | Despues de plan aprobado             | Si       |
| Destroy           | Manual desde UI o CLI                | Si       |

## Trigger patterns

Por defecto, HCP Terraform ejecuta un run cuando cualquier archivo .tf cambia.
Se puede limitar con patrones:
- Include: "modules/**" → solo cambios en /modules/
- Exclude: "*.md" → ignorar cambios en documentacion

## Auto Apply vs Manual Apply

Auto Apply (dev/staging):
- Cada merge a main ejecuta plan + apply sin intervencion
- Riesgo: un cambio incorrecto se aplica inmediatamente

Manual Apply (produccion):
- El plan completa y queda en estado "Needs Confirmation"
- Un miembro del equipo revisa y aprueba (o descarta) en la UI
- Ventana de tiempo para detectar errores antes de aplicar
EOF
```

Esta documentacion captura todos los conceptos del VCS Workflow que aparecen en el examen Terraform Associate: speculative plans, trigger patterns, y la diferencia entre Auto Apply y Manual Apply.

### Paso 5: Crear un archivo .gitignore para Terraform

```bash
touch .gitignore
```

```bash
cat > .gitignore <<'EOF'
# Terraform
.terraform/
.terraform.lock.hcl
*.tfstate
*.tfstate.backup
*.tfvars
crash.log
override.tf
override.tf.json
*_override.tf
*_override.tf.json
EOF
```

El `.gitignore` es critico en un flujo VCS: evita que el state de Terraform (que puede contener secretos) se suba al repositorio. HCP Terraform gestiona el state de forma segura en su backend.

### Paso 6: Simular el flujo de feature branch

```bash
git add .gitignore vcs-workflow-notas.md
```

```bash
git commit -m "docs: agregar notas VCS workflow y gitignore"
```

```bash
git checkout -b feature/version-2
```

```bash
sed -i 's/default = "1.0.0"/default = "2.0.0"/' main.tf
```

```bash
git add main.tf
```

```bash
git commit -m "feat: actualizar version de app a 2.0.0"
```

Este flujo replica exactamente lo que ocurre en un equipo real: un developer crea un branch, hace cambios, y al abrir un PR HCP Terraform ejecuta un speculative plan para verificar que los cambios son seguros antes del merge.

### Paso 7: Inicializar y aplicar con backend local

```bash
git checkout main
```

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

`terraform init` descarga el provider y prepara el workspace local. En un VCS Workflow real, este paso lo ejecuta HCP Terraform en su runner, no en tu maquina.

### Paso 8: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Conceptos Aprendidos

- Integracion HCP Terraform + GitHub via OAuth VCS Provider
- Speculative plans en Pull Requests: solo plan, nunca apply
- Trigger patterns: que cambios disparan un run
- Auto Apply vs Manual Apply: cuando usar cada uno en cada ambiente
- Historial de runs vinculado a commits de Git

## Recursos

- [VCS-Driven Workflows](https://developer.hashicorp.com/terraform/cloud-docs/run/ui)
- [Speculative Plans](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations#speculative-plans)

---

**Anterior:** [Lab 1 - HCP Terraform Setup](../lab1-hcp-setup/)
**Siguiente:** [Lab 3 - Sentinel Policies](../lab3-sentinel-policies/)
