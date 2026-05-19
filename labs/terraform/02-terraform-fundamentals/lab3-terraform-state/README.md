# Lab 3: Terraform State

## Objetivo

Entender como Terraform usa el state file para rastrear la infraestructura, inspeccionar su contenido con los comandos `terraform state`, y verificar empiricamente conceptos clave como drift detection y el backup automatico.

## Duracion

30 minutos

## Prerrequisitos

- Lab 2 completado
- Terraform instalado (verificar con `terraform version`)
- `jq` instalado (para explorar el JSON del state)

## Instrucciones

### Paso 1: Crear el directorio del proyecto

```bash
mkdir lab3-state
```

Crea el directorio de trabajo aislado para este lab.

```bash
cd lab3-state
```

Entra al directorio para que todos los comandos operen dentro de el.

### Paso 2: Crear el archivo main.tf

```bash
touch main.tf
```

Crea el archivo vacio antes de escribir el contenido.

```bash
cat > main.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

resource "random_integer" "port" {
  min = 8000
  max = 9000
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_uuid" "session_id" {}

resource "local_file" "server_config" {
  filename = "config/server.conf"
  content  = <<-EOT
    [server]
    name       = ${random_pet.server_name.id}
    port       = ${random_integer.port.result}
    session_id = ${random_uuid.session_id.result}

    [database]
    password = ${random_password.db_password.result}

    # Gestionado por Terraform - no editar manualmente
  EOT
}

resource "local_file" "state_guide" {
  filename = "state-guide.md"
  content  = <<-EOT
    # Comandos de Terraform State

    ## Inspeccion
    terraform state list               # Listar todos los recursos
    terraform state show RECURSO       # Ver atributos de un recurso
    terraform show                     # Ver todo el state en formato legible
    terraform output                   # Ver outputs

    ## Modificacion (avanzado)
    terraform state mv ORIGEN DESTINO  # Renombrar o mover recurso en el state
    terraform state rm RECURSO         # Quitar del state sin destruir
    terraform state pull               # Descargar state remoto
    terraform state push               # Subir state remoto

    ## Refresh
    terraform refresh                  # Actualizar state con el estado real
    terraform plan -refresh-only       # Ver que cambiaria un refresh
    terraform apply -refresh-only      # Aplicar solo el refresh

    ## Estructura del state file (terraform.tfstate)
    {
      "version": 4,
      "terraform_version": "X.Y.Z",
      "serial": N,          <- Incrementa en cada apply
      "lineage": "uuid",    <- ID unico del state
      "outputs": {...},
      "resources": [...]
    }
  EOT
}

output "server_info" {
  value = {
    name       = random_pet.server_name.id
    port       = random_integer.port.result
    session_id = random_uuid.session_id.result
  }
}

output "files_created" {
  value = [
    local_file.server_config.filename,
    local_file.state_guide.filename,
  ]
}
EOF
```

Los seis recursos (cuatro `random_*` y dos `local_file`) generan un state rico en informacion para explorar. El recurso `random_password` demuestra que el state puede contener secretos en texto claro, lo cual justifica el uso de remote state cifrado en produccion.

### Paso 3: Inicializar Terraform

```bash
terraform init
```

Descarga los providers `random` y `local` y configura el directorio `.terraform`. El state file se creara al ejecutar el primer apply.

### Paso 4: Aplicar la configuracion

```bash
terraform apply -auto-approve
```

Crea los seis recursos y genera el state file `terraform.tfstate`. Terraform tambien crea automaticamente un backup `terraform.tfstate.backup` en cada apply sucesivo.

### Paso 5: Listar recursos en el state

```bash
terraform state list
```

Muestra todos los recursos que Terraform esta gestionando actualmente. La lista debe tener seis entradas, una por cada recurso declarado en `main.tf`.

### Paso 6: Inspeccionar un recurso del state

```bash
terraform state show random_pet.server_name
```

Muestra todos los atributos del recurso `random_pet.server_name` tal como estan almacenados en el state: el valor de `id`, `length` y `separator`. Esta es la forma correcta de inspeccionar recursos sin editar el JSON directamente.

```bash
terraform state show random_password.db_password
```

Observa que el password generado aparece en texto claro dentro del state. Esto ilustra por que el state file nunca debe commitearse a Git sin cifrado, y por que en produccion se usa remote state con cifrado en reposo.

### Paso 7: Ver el state completo

```bash
terraform show
```

Muestra todo el state en formato HCL legible, incluyendo todos los atributos de todos los recursos. Es equivalente a leer el JSON pero con mejor formato.

```bash
cat terraform.tfstate | jq 'keys'
```

Muestra las claves de nivel superior del state file: `version`, `terraform_version`, `serial`, `lineage`, `outputs` y `resources`. El campo `serial` incrementa en cada apply.

```bash
cat terraform.tfstate | jq '.resources | length'
```

Cuenta cuantos recursos hay en el array `resources`. Debe ser seis, uno por cada recurso del `main.tf`.

### Paso 8: Verificar los outputs

```bash
terraform output
```

Lista los outputs declarados con sus valores. Los outputs son el mecanismo oficial para exponer valores desde el state hacia el usuario o hacia modulos padre.

```bash
terraform output server_info
```

Muestra solo el output `server_info` con el nombre, puerto y session_id del servidor. El valor viene del state, no de una evaluacion nueva.

### Paso 9: Simular drift (deteccion de cambios manuales)

```bash
rm config/server.conf
```

Elimina el archivo manualmente, simulando un cambio fuera de Terraform. El state todavia registra que `local_file.server_config` existe, pero la realidad es diferente.

```bash
terraform plan
```

Terraform detecta que el archivo fue eliminado y muestra un plan con `1 to add` (recrear el archivo). Esta es la drift detection: Terraform compara el state contra la realidad y propone correcciones.

```bash
terraform apply -auto-approve
```

Recrea el archivo eliminado, devolviendo la infraestructura al estado deseado. Esto demuestra la naturaleza declarativa de Terraform: siempre converge hacia la configuracion deseada.

### Paso 10: Inspeccionar el serial del state

```bash
cat terraform.tfstate | jq '.serial'
```

El `serial` aumento respecto al apply anterior. Cada vez que Terraform modifica el state, incrementa este contador. Es una forma sencilla de verificar cuantos cambios se han aplicado.

```bash
cat terraform.tfstate | jq '.lineage'
```

El `lineage` es un UUID unico que identifica este state especifico. Si dos equipos tienen states con distintos `lineage`, Terraform detecta que son estados independientes y no los mezcla.

### Paso 11: Ver el backup del state

```bash
cat terraform.tfstate.backup | jq '.serial'
```

El backup contiene el state previo al ultimo apply. Compara el serial con el state actual para ver la diferencia. En caso de un apply fallido, este backup permite recuperar el estado anterior.

### Paso 12: Volver al directorio del lab y validar

```bash
cd /root/lab
```

Regresa al directorio raiz del lab donde se encuentra el script de validacion.

```bash
bash validate-lab.sh
```

Ejecuta todas las verificaciones automaticas para confirmar que el lab fue completado correctamente.

## Conceptos

| Concepto | Descripcion |
|---|---|
| `terraform.tfstate` | Archivo JSON que mapea cada recurso de la config con su estado real |
| `serial` | Contador que incrementa en cada apply; permite ordenar versiones del state |
| `lineage` | UUID unico del state que previene mezclar states de proyectos distintos |
| `terraform state list` | Lista todos los recursos gestionados actualmente |
| `terraform state show` | Muestra los atributos completos de un recurso especifico |
| `terraform show` | Muestra todo el state en formato HCL legible |
| Drift detection | Terraform compara el state contra la realidad y detecta diferencias |
| `terraform.tfstate.backup` | Backup automatico del state previo al ultimo apply |
| Remote state | State almacenado en un backend externo (S3, GCS, HCP Terraform) con cifrado y locking |
| State locking | Mecanismo que impide que dos operaciones modifiquen el state simultaneamente |

---

**Anterior:** [Lab 2 - Providers](../lab2-providers/)
**Siguiente:** [Lab 4 - CLI Avanzado](../lab4-cli-avanzado/)
