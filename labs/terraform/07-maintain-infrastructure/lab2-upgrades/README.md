# Lab 2: Upgrades de Terraform y Providers

![Terraform](https://img.shields.io/badge/Terraform-Upgrades-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Actualizar versiones de Terraform y providers de forma segura y controlada, entendiendo el archivo `.terraform.lock.hcl`.

## ⏱️ Duración
25 minutos

## 📋 Prerrequisitos
- ✅ Lab 1 del módulo 07 completado
- Terraform instalado

## 🚀 Instrucciones Paso a Paso

### Paso 1: Crear el Proyecto con Versiones Fijas

```bash
mkdir lab2-upgrades
cd lab2-upgrades
```

Crea `versions.tf`:

```hcl
# versions.tf — restricciones de versión

terraform {
  required_version = ">= 1.0, < 2.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"   # Acepta 2.x pero no 3.x
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}
```

Crea `main.tf`:

```hcl
resource "local_file" "info" {
  filename = "${path.module}/info.txt"
  content  = "Lab de upgrades\n"
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "suffix" { value = random_id.suffix.hex }
```

```bash
terraform init
terraform apply -auto-approve
cat .terraform.lock.hcl    # versiones exactas instaladas
terraform version
```

### Paso 2: Entender el Lock File

```bash
# .terraform.lock.hcl fija las versiones EXACTAS de providers
# Garantiza que todos los miembros del equipo usen las mismas versiones
cat .terraform.lock.hcl

# Estructura del lock:
# provider "registry.terraform.io/hashicorp/local" {
#   version     = "2.x.y"        ← versión exacta instalada
#   constraints = "~> 2.0"       ← constraint original
#   hashes = [...]                ← hash de integridad
# }
```

### Paso 3: Simular un Upgrade de Provider

```bash
# Ver qué versión está instalada
terraform providers

# Para actualizar a la última versión compatible:
# terraform init -upgrade

# Este comando:
# 1. Busca la última versión que satisfaga los constraints
# 2. Actualiza .terraform.lock.hcl
# 3. Descarga la nueva versión

echo "Ejecutar en entorno real: terraform init -upgrade"
echo "Versiones actuales:"
terraform providers
```

### Paso 4: Cambiar Constraints y Verificar Compatibilidad

Actualiza `versions.tf` con constraints más estrictos:

```hcl
terraform {
  required_version = ">= 1.3"    # Requiere 1.3+

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"         # Solo 2.4.x
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"         # Solo 3.6.x
    }
  }
}
```

```bash
# Re-inicializar con nuevas constraints
terraform init -upgrade

# Verificar
cat .terraform.lock.hcl
terraform providers
terraform validate
terraform plan
```

### Paso 5: Proceso Seguro de Upgrade

```bash
# PROCESO RECOMENDADO PARA UPGRADES EN PRODUCCIÓN:

cat > proceso-upgrade.md << 'EOF'
# Proceso Seguro de Upgrade de Terraform/Providers

## 1. Entorno de desarrollo primero
```
terraform init -upgrade   # en dev/staging
terraform plan            # verificar que no hay cambios inesperados
terraform apply           # aplicar en dev
```

## 2. Revisar CHANGELOG
- Terraform: https://github.com/hashicorp/terraform/blob/main/CHANGELOG.md
- Providers: https://registry.terraform.io/providers/hashicorp/local/latest

## 3. Verificar breaking changes
- Cambios en comportamiento de recursos existentes
- Atributos deprecados o eliminados
- Cambios en la sintaxis HCL

## 4. Commit del lock file actualizado
```
git add .terraform.lock.hcl
git commit -m "chore: upgrade hashicorp/local to 2.4.x"
```

## 5. Aplicar en staging → prod
- Revisar plan antes de cada apply
- Un entorno a la vez
EOF

cat proceso-upgrade.md
```

### Paso 6: Verificar Versión de Terraform Activa

```bash
# Ver versión instalada
terraform version

# Ver si la versión cumple el constraint
# Si no cumple: "This configuration requires Terraform >= X.Y"

# Agregar nota sobre versiones disponibles
cat > notas-terraform-versions.txt << 'EOF'
Versiones de Terraform disponibles:
- 1.0.x: Estable, soporte extendido
- 1.3.x: moved blocks, optional attributes
- 1.5.x: import blocks, check blocks
- 1.6.x: stacks (preview)
- 1.7.x: removed blocks

Política de versiones:
- Patch (1.7.x): Solo bug fixes — safe to upgrade
- Minor (1.x.0): Nuevas features, backwards compatible
- Major (x.0.0): Posibles breaking changes
EOF
cat notas-terraform-versions.txt
```

### Paso 7: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ `versions.tf` con constraints definidos
2. ✅ `.terraform.lock.hcl` generado e inspeccionado
3. ✅ `terraform providers` ejecutado
4. ✅ Proceso de upgrade documentado
5. ✅ `terraform validate` pasa sin errores

## 🔧 Troubleshooting

### Error: "version constraint not met"

```bash
# Tu Terraform instalado no cumple el constraint
terraform version

# Opciones:
# 1. Actualizar Terraform
# 2. Relajar el constraint en versions.tf
```

### Error: "no available releases match the given constraints"

```bash
# El constraint es muy restrictivo
# Verifica las versiones disponibles en el registry
# https://registry.terraform.io/providers/hashicorp/local/versions
```

## 🎓 Conceptos Aprendidos

- ✅ `required_version` y `required_providers` constraints
- ✅ Operadores: `>=`, `~>`, `<`, `!=`
- ✅ `.terraform.lock.hcl` — propósito y estructura
- ✅ `terraform init -upgrade` para actualizar providers
- ✅ Proceso seguro de upgrade en producción

## 🏆 Badge

Al completar este laboratorio obtienes: **Terraform Upgrades Badge**

---

**Anterior:** [Lab 1 - Refactoring](../lab1-refactoring/)
**Siguiente:** [Lab 3 - Drift Detection](../lab3-drift-detection/)
