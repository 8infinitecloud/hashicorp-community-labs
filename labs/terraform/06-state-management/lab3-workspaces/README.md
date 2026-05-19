# Lab 3: Workspaces

![Terraform](https://img.shields.io/badge/Terraform-Workspaces-7B42BC?style=flat&logo=terraform)

## Objetivo

Gestionar multiples entornos (dev, staging, prod) usando Terraform workspaces: cada workspace mantiene un state independiente con la misma configuracion de codigo, diferenciando parametros automaticamente mediante `terraform.workspace`.

## Duracion

25 minutos

## Prerrequisitos

- Labs 1 y 2 del modulo 06 completados
- Terraform instalado (`terraform version` >= 1.0)

## Instrucciones Paso a Paso

### Paso 1: Preparar el directorio de trabajo

```bash
cd /root/lab
```

### Paso 2: Crear main.tf con logica multi-entorno

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

locals {
  entorno = terraform.workspace

  config = {
    default  = { instancias = 1, tipo = "micro",  debug = true  }
    dev      = { instancias = 1, tipo = "micro",  debug = true  }
    staging  = { instancias = 2, tipo = "small",  debug = false }
    prod     = { instancias = 4, tipo = "large",  debug = false }
  }

  cfg = lookup(local.config, local.entorno, local.config["default"])
}

resource "local_file" "deploy" {
  filename = "${path.module}/deploy-${local.entorno}.conf"
  content  = <<-EOT
    entorno    = ${local.entorno}
    instancias = ${local.cfg.instancias}
    tipo       = ${local.cfg.tipo}
    debug      = ${local.cfg.debug}
  EOT
}

output "entorno"    { value = local.entorno }
output "instancias" { value = local.cfg.instancias }
output "tipo"       { value = local.cfg.tipo }
EOF
```

`terraform.workspace` es una variable especial de Terraform que devuelve el nombre del workspace activo. El bloque `locals` usa `lookup` para seleccionar la configuracion correcta segun el workspace, lo que permite que el mismo codigo funcione diferente en cada entorno sin duplicar archivos `.tf`.

### Paso 3: Inicializar y aplicar en el workspace default

```bash
terraform init
```

```bash
terraform workspace show
```

```bash
terraform apply -auto-approve
```

```bash
cat deploy-default.conf
```

```bash
terraform output
```

`terraform workspace show` confirma que estas en el workspace `default`. El apply en este workspace crea `deploy-default.conf` con la configuracion de 1 instancia tipo micro. Cada workspace aplica al mismo codigo pero con su propio state aislado.

### Paso 4: Crear y aplicar en workspace dev

```bash
terraform workspace new dev
```

```bash
terraform workspace show
```

```bash
terraform apply -auto-approve
```

```bash
cat deploy-dev.conf
```

`terraform workspace new dev` crea el workspace y lo selecciona automaticamente. El apply genera `deploy-dev.conf` con la configuracion dev (1 instancia, micro). El state de `dev` se guarda en `terraform.tfstate.d/dev/terraform.tfstate`, separado del state de `default`.

### Paso 5: Crear y aplicar en workspace staging

```bash
terraform workspace new staging
```

```bash
terraform apply -auto-approve
```

```bash
cat deploy-staging.conf
```

```bash
terraform output instancias
```

El workspace `staging` genera `deploy-staging.conf` con 2 instancias tipo small. La salida de `terraform output instancias` debe mostrar `2`, confirmando que el lookup por workspace funciona correctamente.

### Paso 6: Crear y aplicar en workspace prod

```bash
terraform workspace new prod
```

```bash
terraform apply -auto-approve
```

```bash
cat deploy-prod.conf
```

```bash
terraform output
```

El workspace `prod` genera `deploy-prod.conf` con 4 instancias tipo large y debug desactivado. La configuracion de produccion es diferente a la de dev simplemente por cambiar el workspace activo, sin modificar ningun archivo `.tf`.

### Paso 7: Comparar los states independientes

```bash
ls terraform.tfstate.d/
```

```bash
ls terraform.tfstate.d/dev/
```

```bash
ls terraform.tfstate.d/prod/
```

```bash
terraform -chdir=. workspace list
```

Terraform almacena el state de cada workspace en `terraform.tfstate.d/<nombre>/terraform.tfstate`. El state del workspace `default` sigue en `terraform.tfstate` en la raiz. Cada workspace puede tener su propio ciclo de vida sin afectar a los demas.

### Paso 8: Cambiar entre workspaces

```bash
terraform workspace select dev
```

```bash
terraform workspace show
```

```bash
terraform output instancias
```

```bash
terraform workspace select prod
```

```bash
terraform output instancias
```

`terraform workspace select` cambia el state activo. Al cambiar a `dev`, `terraform output instancias` muestra `1`; al cambiar a `prod` muestra `4`. El switch es instantaneo porque solo cambia que archivo tfstate usa Terraform.

### Paso 9: Destruir un workspace y eliminarlo

```bash
terraform workspace select staging
```

```bash
terraform destroy -auto-approve
```

```bash
terraform workspace select default
```

```bash
terraform workspace delete staging
```

```bash
terraform workspace list
```

Para eliminar un workspace debes primero destruir sus recursos y luego seleccionar otro workspace. No puedes eliminar el workspace `default`. `terraform workspace delete` falla si el workspace tiene recursos en su state.

### Paso 10: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Criterios de Validacion

1. Terraform inicializado (`.terraform/` presente)
2. State del workspace `default` existe
3. Workspace `dev` creado con su state aplicado
4. Workspace `prod` creado con su state aplicado
5. `main.tf` usa `terraform.workspace`
6. Archivos `deploy-dev.conf` y `deploy-prod.conf` generados

## Cuando usar Workspaces vs Directorios Separados

| Workspaces | Directorios separados |
|------------|----------------------|
| Misma configuracion, entornos distintos | Configuraciones muy distintas por entorno |
| Rapido de crear y cambiar | Mas control y aislamiento |
| Riesgo de aplicar en el entorno equivocado | Mas dificil cometer errores |
| Recomendado para entornos similares | Recomendado para produccion critica |

## Conceptos Aprendidos

- Crear, seleccionar y eliminar workspaces
- Usar `terraform.workspace` en configuraciones
- States independientes por workspace en `terraform.tfstate.d/`
- Lookup dinamico de configuracion por entorno
- Cuando usar workspaces vs estructuras de directorios

---

**Anterior:** [Lab 2 - State Locking](../lab2-state-locking/)
**Siguiente:** [Lab 4 - State Migration](../lab4-state-migration/)
