# Lab 4: State Migration

![Terraform](https://img.shields.io/badge/Terraform-State_Migration-7B42BC?style=flat&logo=terraform)

## Objetivo

Renombrar recursos en el state con `terraform state mv` sin destruir infraestructura, mover un recurso a un modulo en el state, y entender como funciona `terraform init -migrate-state` para cambiar de backend.

## Duracion

30 minutos

## Prerrequisitos

- Labs 1, 2 y 3 del modulo 06 completados
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
cd /root/lab
```

### Paso 2: Crear main.tf con nombres de recursos "viejos"

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

resource "local_file" "archivo_viejo" {
  filename = "${path.module}/config.txt"
  content  = "version=1.0\nentorno=dev\n"
}

resource "local_file" "datos_viejo" {
  filename = "${path.module}/datos.txt"
  content  = "usuario=admin\nrol=superuser\n"
}

resource "local_file" "log_viejo" {
  filename = "${path.module}/app.log"
  content  = "INFO: aplicacion iniciada\n"
}
EOF
```

Los recursos tienen el sufijo `_viejo` para simular nombres incorrectos que necesitan refactorizacion. El objetivo es renombrarlos en el state sin destruir los archivos fisicos en disco.

### Paso 3: Inicializar y aplicar

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

```bash
terraform state list
```

El state ahora contiene `local_file.archivo_viejo`, `local_file.datos_viejo`, y `local_file.log_viejo`. Los archivos fisicos `config.txt`, `datos.txt`, y `app.log` existen en disco.

### Paso 4: Renombrar recursos con state mv

```bash
terraform state mv local_file.archivo_viejo local_file.config
```

```bash
terraform state mv local_file.datos_viejo local_file.datos
```

```bash
terraform state mv local_file.log_viejo local_file.log
```

```bash
terraform state list
```

`terraform state mv` renombra un recurso dentro del state sin tocar los archivos fisicos. Ahora el state muestra `local_file.config`, `local_file.datos`, `local_file.log`. Si ejecutaras `terraform plan` en este momento, Terraform querria destruir los recursos con nombres viejos porque el codigo aun los referencia — por eso el siguiente paso actualiza el codigo.

### Paso 5: Actualizar main.tf para que coincida con el state

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

resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "version=1.0\nentorno=dev\n"
}

resource "local_file" "datos" {
  filename = "${path.module}/datos.txt"
  content  = "usuario=admin\nrol=superuser\n"
}

resource "local_file" "log" {
  filename = "${path.module}/app.log"
  content  = "INFO: aplicacion iniciada\n"
}
EOF
```

Ahora los nombres en el codigo (`local_file.config`, etc.) coinciden con los nombres en el state. El flujo correcto es siempre: primero `state mv`, luego actualizar el codigo. Si lo haces al reves, Terraform planea destruir y recrear.

### Paso 6: Verificar que plan muestra "No changes"

```bash
terraform plan
```

`terraform plan` debe mostrar "No changes. Your infrastructure matches the configuration." Esto confirma que el state mv fue exitoso: el state y el codigo son consistentes sin haber destruido ni recreado ningun archivo.

### Paso 7: Crear el modulo de destino

```bash
mkdir -p modules/archivos
```

```bash
touch modules/archivos/main.tf
```

```bash
cat > modules/archivos/main.tf <<'EOF'
variable "prefix" {
  type    = string
  default = "app"
}

resource "local_file" "log" {
  filename = "${path.module}/output/${var.prefix}-app.log"
  content  = "INFO: log gestionado por modulo\n"
}
EOF
```

```bash
mkdir -p modules/archivos/output
```

El modulo `modules/archivos` encapsula la gestion del log. Crear el directorio `output/` dentro del modulo es necesario porque `local_file` no crea directorios intermedios automaticamente.

### Paso 8: Actualizar el root main.tf para usar el modulo

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

resource "local_file" "config" {
  filename = "${path.module}/config.txt"
  content  = "version=1.0\nentorno=dev\n"
}

resource "local_file" "datos" {
  filename = "${path.module}/datos.txt"
  content  = "usuario=admin\nrol=superuser\n"
}

module "archivos" {
  source = "./modules/archivos"
  prefix = "dev"
}
EOF
```

El recurso `local_file.log` se elimina del root y ahora vive dentro de `module.archivos`. Antes de hacer el `state mv` al modulo, hay que hacer `terraform init` para registrar el nuevo modulo.

### Paso 9: Re-inicializar por el nuevo modulo

```bash
terraform init
```

`terraform init` es necesario siempre que se agrega un nuevo `module` o `provider`. Sin este paso, Terraform no conoce la ruta del modulo y el `state mv` fallaria.

### Paso 10: Mover el recurso log al modulo en el state

```bash
terraform state mv local_file.log module.archivos.local_file.log
```

```bash
terraform state list
```

`terraform state mv` puede mover recursos no solo entre nombres sino tambien entre el root y un modulo. La sintaxis de destino `module.archivos.local_file.log` usa el nombre del bloque `module` en el root seguido del address del recurso dentro del modulo.

### Paso 11: Verificar integridad con plan

```bash
terraform apply -auto-approve
```

```bash
terraform state list
```

El apply confirma que el state y el codigo son consistentes. El state debe mostrar `local_file.config`, `local_file.datos`, y `module.archivos.local_file.log`. Los archivos fisicos no fueron destruidos ni recreados en ningun momento del proceso.

### Paso 12: Respaldar el state y documentar la migracion de backend

```bash
cp terraform.tfstate terraform.tfstate.pre-migracion
```

```bash
touch migracion-backend.md
```

```bash
cat > migracion-backend.md <<'EOF'
# Proceso de Migracion de Backend

## Cuando necesitas migrar el backend
- Pasar de state local a S3 (primer despliegue en equipo)
- Cambiar de region o bucket S3
- Mover de un cloud a otro

## Pasos para migrar de local a S3
1. Respaldar el state actual: cp terraform.tfstate terraform.tfstate.backup
2. Agregar bloque backend en main.tf o backend.tf:
   terraform { backend "s3" { bucket = "..." key = "..." region = "..." } }
3. Ejecutar: terraform init -migrate-state
   Terraform pregunta: "Do you want to copy existing state to the new backend? (yes)"
4. Verificar: terraform state list (debe mostrar los mismos recursos)
5. Verificar: terraform plan (debe mostrar No changes)

## Notas importantes
- Nunca borrar terraform.tfstate local hasta confirmar que el remote tiene el state
- Si algo falla, restaurar desde el backup y quitar el bloque backend
EOF
```

Respaldar el state antes de cualquier operacion de migracion es un habito critico. Si la migracion falla a mitad, el backup local permite restaurar sin perder el historial de recursos gestionados.

### Paso 13: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Criterios de Validacion

1. Terraform inicializado (`.terraform/` presente)
2. `terraform.tfstate` existe
3. El state NO contiene recursos con sufijo `_viejo`
4. El state contiene `module.archivos`
5. `terraform plan` muestra "No changes"
6. `local_file.config` esta en el state con nombre correcto
7. `migracion-backend.md` creado

## Conceptos Aprendidos

- `terraform state mv` para renombrar sin destruir recursos
- `terraform state mv` para mover recursos a modulos
- Por que hay que actualizar el codigo despues del `state mv`
- Proceso de migracion de backend (`init -migrate-state`)
- Validar integridad con `terraform plan` (No changes)
- Importancia de respaldar el state antes de operaciones

---

**Anterior:** [Lab 3 - Workspaces](../lab3-workspaces/)
**Siguiente:** [Modulo 07 - Maintain Infrastructure](../../07-maintain-infrastructure/)
