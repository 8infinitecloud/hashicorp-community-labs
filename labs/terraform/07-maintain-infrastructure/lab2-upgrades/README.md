# Lab 2: Upgrades de Terraform y Providers

![Terraform](https://img.shields.io/badge/Terraform-Upgrades-7B42BC?style=flat&logo=terraform)

## Objetivo
Gestionar versiones de Terraform y providers de forma controlada usando constraints y el archivo `.terraform.lock.hcl`.

## Duracion
25 minutos

## Prerrequisitos
- Lab 1 del modulo 07 completado
- Terraform instalado

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
mkdir -p /root/lab
cd /root/lab
```

### Paso 2: Crear versions.tf con constraints de version

```bash
touch versions.tf
```

```bash
cat > versions.tf <<'EOF'
# versions.tf — restricciones de version centralizadas

terraform {
  required_version = ">= 1.0, < 2.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0, < 4.0"
    }
  }
}
EOF
```

`required_version` evita que el proyecto se aplique con una version de Terraform incompatible. `required_providers` fija el rango aceptable para cada provider; `~> 2.0` acepta cualquier `2.x` pero bloquea `3.0+`.

### Paso 3: Crear main.tf con recursos de prueba

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
resource "local_file" "info" {
  filename = "${path.module}/info.txt"
  content  = "Lab de upgrades\n"
}

resource "random_id" "suffix" {
  byte_length = 4
}

output "suffix" {
  value = random_id.suffix.hex
}
EOF
```

`local_file` escribe un archivo en disco y `random_id` genera un ID aleatorio. Usar dos providers distintos permite ver como el lock file gestiona multiples dependencias.

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

```bash
terraform version
```

`terraform version` muestra la version instalada junto con las versiones de providers descargados.

### Paso 4: Inspeccionar el lock file

```bash
cat .terraform.lock.hcl
```

El lock file fija las versiones **exactas** de cada provider (no solo el rango). Contiene hashes criptograficos `h1:` que garantizan integridad. Este archivo debe commitearse a Git para que todos los miembros del equipo usen exactamente las mismas versiones.

```bash
terraform providers
```

`terraform providers` lista los providers requeridos por la configuracion y las versiones que satisfacen los constraints actuales.

### Paso 5: Simular un upgrade de provider

```bash
cat > versions.tf <<'EOF'
terraform {
  required_version = ">= 1.0, < 2.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
EOF
```

Cambiar `~> 2.0` a `~> 2.4` restringe el provider `local` a versiones `2.4.x`. Esto es como fijar una version minima en produccion despues de validar una version especifica en staging.

```bash
terraform init -upgrade
```

```bash
cat .terraform.lock.hcl
```

```bash
terraform validate
```

`terraform init -upgrade` busca la ultima version dentro del nuevo constraint, actualiza el lock file y descarga los binarios. `terraform validate` verifica que la configuracion sigue siendo valida con los nuevos providers.

### Paso 6: Documentar el proceso de upgrade

```bash
touch notas-terraform-versions.txt
```

```bash
cat > notas-terraform-versions.txt <<'EOF'
Proceso seguro de upgrade de Terraform/Providers

1. Actualizar en dev/staging primero
   terraform init -upgrade
   terraform plan
   terraform apply

2. Revisar el CHANGELOG del provider antes de subir version

3. Commitear el lock file actualizado
   git add .terraform.lock.hcl
   git commit -m "chore: upgrade providers"

4. Aplicar en staging -> produccion de uno en uno

Versiones de Terraform de referencia:
- 1.1.x: moved blocks
- 1.3.x: optional attributes en modulos
- 1.5.x: import blocks y check blocks
- 1.7.x: removed blocks

Politica de versiones semanticas:
- Patch (1.7.x): solo bug fixes — seguro actualizar
- Minor (1.x.0): nuevas features, backwards compatible
- Major (x.0.0): posibles breaking changes, revisar CHANGELOG
EOF
```

Documentar el proceso de upgrade evita errores en produccion y facilita las revisiones de codigo. El archivo captura decisiones de version para futuras referencias.

### Paso 7: Verificar estado final

```bash
terraform plan
```

```bash
terraform state list
```

El plan debe mostrar `No changes`. El state debe listar `local_file.info` y `random_id.suffix` con los providers actualizados.

### Paso 8: Ejecutar validacion

```bash
cd /root/lab
```

```bash
bash validate-lab.sh
```

## Criterios de Validacion

1. `versions.tf` con `required_version` y `required_providers` definidos
2. `.terraform.lock.hcl` generado con hashes `h1:`
3. `terraform validate` pasa sin errores
4. Estado aplicado (`terraform.tfstate` existe)
5. Archivo `notas-terraform-versions.txt` creado

## Operadores de version

| Operador | Significado | Ejemplo |
|---|---|---|
| `>=` | Mayor o igual | `>= 1.0` |
| `<` | Menor que | `< 2.0` |
| `~>` | Solo patch/minor updates | `~> 2.4` acepta `2.4.x`, bloquea `2.5+` |
| `!=` | Excluye version especifica | `!= 1.2.0` |

## Conceptos Aprendidos

- `required_version` y `required_providers` con constraints
- Operadores: `>=`, `~>`, `<`, `!=`
- `.terraform.lock.hcl` — proposito y estructura
- `terraform init -upgrade` para actualizar providers
- Proceso seguro de upgrade en produccion

---

**Anterior:** [Lab 1 - Refactoring](../lab1-refactoring/)
**Siguiente:** [Lab 3 - Drift Detection](../lab3-drift-detection/)
