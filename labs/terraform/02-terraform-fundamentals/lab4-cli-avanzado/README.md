# Lab 4: Terraform CLI Avanzado

## Objetivo

Dominar los comandos esenciales de Terraform CLI: validacion, formato, plan con archivos de salida, workspaces, variables de entorno y debugging, usando un proyecto local real como base de practica.

## Duracion

25 minutos

## Prerrequisitos

- Lab 3 completado (directorio `lab3-state` disponible)
- Terraform instalado (verificar con `terraform version`)

## Instrucciones

### Paso 1: Crear el directorio del proyecto

```bash
mkdir lab4-cli
```

Crea un directorio nuevo para este lab en lugar de reutilizar el del Lab 3, para mantener el state aislado.

```bash
cd lab4-cli
```

Entra al directorio de trabajo del lab.

### Paso 2: Crear el archivo main.tf

```bash
touch main.tf
```

Crea el archivo vacio antes de escribir el contenido.

```bash
cat > main.tf <<'EOF'
terraform {
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

variable "app_name" {
  description = "Nombre de la aplicacion"
  type        = string
  default     = "PeruApp"
}

variable "instance_count" {
  description = "Numero de instancias"
  type        = number
  default     = 2
}

resource "random_pet" "server_name" {
  length    = 2
  separator = "-"
}

resource "random_integer" "port" {
  min = 8000
  max = 9000
}

resource "local_file" "cheatsheet" {
  filename = "terraform-cheatsheet.md"
  content  = <<-EOT
    # Terraform CLI Cheatsheet

    ## Workflow basico
    terraform init      # Inicializar directorio y descargar providers
    terraform validate  # Validar sintaxis sin contactar providers
    terraform fmt       # Formatear codigo HCL automaticamente
    terraform plan      # Ver cambios antes de aplicarlos
    terraform apply     # Aplicar cambios
    terraform destroy   # Destruir todos los recursos

    ## Inspeccion
    terraform show              # Ver state completo en formato legible
    terraform state list        # Listar recursos en el state
    terraform state show RES    # Ver atributos de un recurso
    terraform output            # Ver outputs
    terraform providers         # Ver providers activos

    ## Flags utiles
    -auto-approve               # Omitir confirmacion interactiva
    -var="key=value"            # Pasar variable inline
    -var-file="archivo.tfvars"  # Cargar variables desde archivo
    -out=tfplan                 # Guardar plan en archivo binario
    -target=resource.name       # Operar solo sobre un recurso
    -refresh-only               # Solo actualizar el state
    -json                       # Output en formato JSON

    ## Debugging
    export TF_LOG=DEBUG         # Habilitar logs detallados
    export TF_LOG_PATH=tf.log   # Guardar logs en archivo
    unset TF_LOG                # Deshabilitar logs

    ## Variables de entorno
    TF_VAR_nombre=valor         # Valor para variable de input
    TF_INPUT=false              # Deshabilitar prompts interactivos

    ## Workspaces
    terraform workspace list    # Listar workspaces
    terraform workspace new ENV # Crear workspace
    terraform workspace select  # Cambiar workspace
    terraform workspace show    # Ver workspace actual
  EOT
}

output "app_info" {
  value = {
    app_name       = var.app_name
    instance_count = var.instance_count
    server_name    = random_pet.server_name.id
    port           = random_integer.port.result
  }
}
EOF
```

Este `main.tf` es intencionalmente simple para que el foco del lab sea practicar los comandos CLI, no la configuracion en si. El archivo `cheatsheet` generado es una referencia util para los laboratorios siguientes.

### Paso 3: Validar la sintaxis

```bash
terraform validate
```

Comprueba que el HCL es sintacticamente correcto y que las referencias entre recursos son validas, sin descargar providers ni acceder a APIs. Es el primer comando a ejecutar cuando sospechas de un error de sintaxis.

### Paso 4: Inicializar Terraform

```bash
terraform init
```

Descarga los providers declarados en `required_providers` y configura el directorio `.terraform`. Este paso debe ejecutarse antes de cualquier plan o apply, y cada vez que agregas un nuevo provider.

### Paso 5: Formatear el codigo

```bash
terraform fmt -diff
```

Formatea automaticamente todos los archivos `.tf` del directorio segun el estilo oficial de HashiCorp y muestra las diferencias aplicadas. Agrega este comando a tu flujo de trabajo antes de hacer commits.

```bash
terraform fmt -check
```

Verifica que el codigo esta correctamente formateado sin modificar nada. Si devuelve nombres de archivos, esos archivos necesitan formato. Si no devuelve nada, todo esta bien. Ideal para CI/CD.

### Paso 6: Guardar el plan en un archivo

```bash
terraform plan -out=tfplan
```

Genera el plan y lo guarda en el archivo binario `tfplan`. Guardar el plan garantiza que el apply ejecuta exactamente lo que fue revisado, sin recalcular ni sorpresas por cambios intermedios.

```bash
terraform show tfplan
```

Muestra el contenido del plan guardado en formato legible. Esto permite revisar el plan antes de aplicarlo, especialmente util en pipelines CI/CD donde plan y apply ocurren en pasos separados.

### Paso 7: Aplicar el plan guardado

```bash
terraform apply tfplan
```

Aplica exactamente el plan guardado en `tfplan` sin pedir confirmacion. Al usar un archivo de plan, no se necesita `-auto-approve` porque ya fue aprobado al generarse.

### Paso 8: Explorar los comandos de inspeccion

```bash
terraform state list
```

Lista todos los recursos actualmente gestionados por Terraform en el state. Usa esta lista para saber que recursos puedes inspeccionar con `terraform state show`.

```bash
terraform state show random_pet.server_name
```

Muestra todos los atributos del recurso `random_pet.server_name`. Cualquier recurso de la lista anterior puede inspeccionarse de esta forma.

```bash
terraform output -json
```

Muestra los outputs en formato JSON, util para scripting o para integrar los valores de Terraform con otras herramientas.

### Paso 9: Crear y usar workspaces

```bash
terraform workspace list
```

Lista los workspaces existentes. El workspace `default` siempre existe. Cada workspace tiene su propio state file independiente.

```bash
terraform workspace new staging
```

Crea un workspace llamado `staging` y lo selecciona automaticamente. Terraform crea un nuevo state vacio para este workspace.

```bash
terraform workspace show
```

Confirma que el workspace activo es ahora `staging`. Los recursos creados desde aqui quedaran en el state de `staging`, separados del state de `default`.

```bash
terraform workspace select default
```

Vuelve al workspace `default` sin eliminar `staging`. Puedes cambiar entre workspaces en cualquier momento; cada uno mantiene su state independiente.

### Paso 10: Usar variables de entorno

```bash
export TF_VAR_app_name="TiendaPeru"
```

Define el valor de la variable `app_name` via variable de entorno. Terraform detecta automaticamente todas las variables de entorno con prefijo `TF_VAR_` y las usa como valores de input.

```bash
terraform plan
```

Observa en el plan que `var.app_name` tiene el valor `TiendaPeru` sin haberlo especificado con `-var`. Las variables de entorno son utiles en pipelines donde no se puede modificar el comando directamente.

```bash
unset TF_VAR_app_name
```

Limpia la variable de entorno para que las ejecuciones siguientes usen el valor por defecto del `main.tf`.

### Paso 11: Debugging con TF_LOG

```bash
export TF_LOG=INFO
```

Activa el nivel de logging `INFO`. Terraform imprimira mensajes adicionales sobre su proceso interno en stderr. Los niveles disponibles en orden de verbosidad son: `ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`.

```bash
terraform validate
```

Ejecuta validate con logging activo para ver los mensajes internos. Con nivel `INFO` se muestran los pasos de inicializacion y validacion del core de Terraform.

```bash
unset TF_LOG
```

Desactiva el logging para volver al comportamiento silencioso por defecto. Siempre desactiva `TF_LOG` cuando termines de depurar para evitar salidas muy verbosas.

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
| `terraform validate` | Verifica sintaxis HCL y referencias sin acceder a providers ni APIs |
| `terraform fmt` | Formatea archivos `.tf` segun el estilo oficial de HashiCorp |
| `terraform fmt -check` | Verifica formato sin modificar; retorna codigo de error si hay diferencias |
| `terraform plan -out=file` | Guarda el plan en un archivo binario para apply deterministico |
| `terraform apply file` | Aplica exactamente el plan guardado, sin recalcular ni pedir confirmacion |
| `terraform show file` | Muestra el contenido de un plan binario en formato legible |
| `TF_VAR_nombre` | Variable de entorno que define el valor de la variable de input `nombre` |
| `TF_LOG` | Variable de entorno que activa el logging con nivel `ERROR/WARN/INFO/DEBUG/TRACE` |
| `terraform workspace` | Permite tener multiples states independientes para el mismo codigo |
| `-target=resource.name` | Limita plan/apply a un recurso especifico (usar con cuidado) |
| `terraform output -json` | Muestra outputs en JSON para integracion con scripting |

---

**Anterior:** [Lab 3 - State](../lab3-terraform-state/)
**Siguiente:** [Modulo 3 - Core Workflow](../../03-core-workflow/)
