# Lab 2: VCS Workflows

![Terraform](https://img.shields.io/badge/HCP_Terraform-VCS_Workflows-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Conectar HCP Terraform con GitHub para ejecutar plans automáticamente en cada Pull Request y applies automáticos al mergear a `main`.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 del módulo 08 completado (HCP Terraform con workspace activo)
- Cuenta de GitHub
- Repositorio Git con código Terraform

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear un Repositorio en GitHub

```bash
# Si no tienes un repo de Terraform, crea uno
mkdir lab2-vcs-workflows
cd lab2-vcs-workflows
git init
```

Crea `main.tf`:

```hcl
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
  type    = string
  default = "1.0.0"
}

resource "local_file" "version" {
  filename = "./version.txt"
  content  = "version=${var.version_app}\ndeployado_por=hcp-terraform\n"
}

output "version" { value = var.version_app }
```

```bash
git add .
git commit -m "feat: configuración inicial para VCS workflow"

# Crear repo en GitHub y hacer push
# gh repo create lab2-vcs-terraform --public --push
# O manualmente desde github.com
```

### Paso 2: Conectar HCP Terraform con GitHub

En la UI de HCP Terraform:

```
1. Organization Settings → VCS Providers → Add VCS Provider
2. Selecciona: GitHub.com
3. Sigue el flujo OAuth:
   - Se abre GitHub para autorizar HCP Terraform
   - Acepta los permisos
   - Se redirige de vuelta a HCP Terraform

4. Guarda el nombre del provider VCS (ej: "github-personal")
```

### Paso 3: Crear Workspace con VCS Trigger

```
1. Workspaces → New Workspace
2. Selecciona: Version control workflow
3. Conecta tu VCS provider (GitHub)
4. Selecciona el repositorio con tu código Terraform
5. Nombre del workspace: lab-vcs-workflow
6. Configura:
   - Terraform Working Directory: . (raíz)
   - Auto Apply: Desactivado (para aprobar manualmente primero)
7. Create workspace
```

### Paso 4: Primer Plan Automático

```bash
# Hacer un cambio y push a main
echo "# Trigger plan" >> main.tf
git add .
git commit -m "chore: trigger plan inicial en HCP Terraform"
git push origin main

# HCP Terraform detecta el push y ejecuta automáticamente:
# 1. git clone del repo
# 2. terraform init
# 3. terraform plan
```

Ve a HCP Terraform y observa el run iniciado automáticamente.

### Paso 5: Workflow con Pull Request

```bash
# Crear un branch para el cambio
git checkout -b feature/nueva-version

# Hacer un cambio
sed -i 's/default = "1.0.0"/default = "2.0.0"/' main.tf
git add .
git commit -m "feat: actualizar versión de la app a 2.0.0"
git push origin feature/nueva-version

# Crear un Pull Request en GitHub
gh pr create --title "feat: versión 2.0.0" --body "Actualiza la versión de la aplicación"
```

En GitHub verás un check de HCP Terraform en el PR:
- Si el plan es exitoso: ✅ `HCP Terraform — Plan succeeded`
- Si hay errores: ❌ `HCP Terraform — Plan errored`

### Paso 6: Aprobar y Aplicar

```bash
# Mergear el PR a main
gh pr merge --merge

# HCP Terraform detecta el merge a main y ejecuta un nuevo plan
# En la UI: confirmar el apply
```

### Paso 7: Habilitar Auto Apply

```
Workspace Settings → General → Apply Method
→ Cambiar a "Auto apply"
```

Con Auto Apply activado, cada merge a `main` ejecuta plan + apply automáticamente sin aprobación manual.

### Paso 8: Ver Historial de Runs

```
Workspace → Runs
- Cada run muestra: branch, commit, autor, estado
- Click en un run: ver plan detallado, logs, state resultante
- Filtrar por: Planned, Applied, Errored, Discarded
```

### Paso 9: Ejecutar Validación Local

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Repositorio GitHub conectado a HCP Terraform
2. ✅ Plan automático ejecutado al hacer push
3. ✅ Plan de especulación visible en un PR de GitHub
4. ✅ Apply ejecutado después del merge a main
5. ✅ Historial de runs inspeccionado en la UI

## 🔧 Troubleshooting

### Error: "VCS provider not found"

```
Verifica que el OAuth con GitHub fue completado correctamente.
Organization Settings → VCS Providers → debe aparecer GitHub
```

### El plan no se ejecuta automáticamente

```
Verifica en Workspace Settings:
- VCS Branch: debe ser "main" o el branch que usas
- Working Directory: ruta correcta al directorio con Terraform
- Trigger patterns: por defecto todos los archivos .tf
```

### Error: "No Terraform configuration files found"

```
Verifica que el Working Directory del workspace apunta
al directorio correcto donde está main.tf
```

## 🎓 Conceptos Aprendidos

- ✅ Integración HCP Terraform + GitHub via OAuth
- ✅ Plans automáticos en cada push a cualquier branch
- ✅ Speculative plans en Pull Requests (solo plan, no apply)
- ✅ Apply automático o con aprobación al mergear a main
- ✅ Historial de runs vinculado a commits de Git

## 🏆 Badge

Al completar este laboratorio obtienes: **HCP Terraform VCS Workflows Badge**

---

**Anterior:** [Lab 1 - HCP Terraform Setup](../lab1-hcp-setup/)
**Siguiente:** [Lab 3 - Sentinel Policies](../lab3-sentinel-policies/)
