# Lab 1: HCP Terraform Setup

![Terraform](https://img.shields.io/badge/HCP_Terraform-Setup-7B42BC?style=flat&logo=terraform)

## Objetivo

Aprender la estructura de configuracion de HCP Terraform (antes Terraform Cloud): el bloque `cloud {}`, credenciales, y el patron de configuracion de workspaces remotos. Las partes que requieren conectividad real a HCP se usan con un backend local para que puedas ejecutar Terraform de forma practicas.

## Duracion

30 minutos

## Prerrequisitos

- Modulo 07 completado
- Terraform instalado
- (Opcional) Cuenta gratuita en [app.terraform.io](https://app.terraform.io) para ver la UI

## Instrucciones Paso a Paso

### Paso 1: Crear el directorio de trabajo

```bash
mkdir -p /root/lab && cd /root/lab
```

El directorio `/root/lab` es el espacio de trabajo para este laboratorio.

### Paso 2: Crear las versiones y configuracion del provider

```bash
touch versions.tf
```

```bash
cat > versions.tf <<'EOF'
terraform {
  required_version = ">= 1.0"

  # CONCEPTO: bloque cloud {} conecta con HCP Terraform.
  # En un entorno real, reemplaza "TU-ORG" con tu organizacion
  # y ejecuta: terraform login
  #
  # cloud {
  #   organization = "peru-hug-TU-ORG"
  #   workspaces {
  #     name = "lab-hcp-setup"
  #   }
  # }

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}
EOF
```

El bloque `cloud {}` es la forma moderna de conectar Terraform con HCP Terraform. Reemplaza al antiguo `backend "remote" {}`. Esta version usa un comentario para ilustrar el patron sin requerir conectividad a HCP.

### Paso 3: Crear main.tf con los recursos

```bash
touch main.tf
```

```bash
cat > main.tf <<'EOF'
variable "entorno" {
  description = "Nombre del entorno de despliegue"
  type        = string
  default     = "dev"
}

resource "local_file" "info" {
  filename = "/root/lab/info-hcp.txt"
  content  = <<-EOT
    # Configuracion de HCP Terraform
    entorno    = ${var.entorno}
    generado   = local backend (simulando HCP)
  EOT
}

output "mensaje" {
  value = "Configuracion aplicada - entorno: ${var.entorno}"
}
EOF
```

`local_file` crea un archivo en el sistema local. En HCP Terraform real, este recurso se ejecutaria en un runner remoto administrado por HashiCorp.

### Paso 4: Entender el archivo de credenciales de HCP Terraform

```bash
touch hcp-setup.md
```

```bash
cat > hcp-setup.md <<'EOF'
# HCP Terraform Setup - Notas de Configuracion

## Autenticacion con HCP Terraform

### Opcion A: terraform login (recomendado)
```
terraform login
```
Abre el browser, genera un token y lo guarda en:
~/.terraform.d/credentials.tfrc.json

### Opcion B: Variable de entorno
```
export TF_TOKEN_app_terraform_io="tu-token-aqui"
```

### Opcion C: credentials.tfrc.json manual
```json
{
  "credentials": {
    "app.terraform.io": {
      "token": "tu-token-aqui"
    }
  }
}
```

## Bloque cloud {} vs backend "remote" {}

| Caracteristica        | cloud {}              | backend "remote" {}   |
|-----------------------|-----------------------|-----------------------|
| Introducido en        | Terraform 1.1         | Terraform 0.12        |
| Configuracion         | Mas simple            | Mas verboso           |
| Workspaces multiples  | Con tags              | Con prefix            |
| Estado actual         | Recomendado           | Legacy                |

## Modos de ejecucion en HCP Terraform

- Remote:  plan y apply corren en HCP Terraform (runner administrado)
- Local:   plan y apply corren en tu maquina, state se guarda en HCP
- Agent:   plan y apply corren en un agente tuyo (on-prem / VPC privada)

## Variables en HCP Terraform

- Terraform variables: visibles en el codigo como var.nombre
- Environment variables: disponibles en el proceso de terraform
- Sensitive: enmascaradas en logs y en la UI

## Historial y auditoria

- Runs: cada terraform plan/apply queda registrado con autor y commit
- State versions: cada apply genera una nueva version del state
- Audit trail: log de quienes ejecutaron que (plan Plus)
EOF
```

Este archivo documenta los patrones clave de HCP Terraform para referencia durante el lab y en el examen.

### Paso 5: Inicializar Terraform con backend local

```bash
terraform init
```

`terraform init` descarga el provider `hashicorp/local` y prepara el directorio `.terraform`. Con el bloque `cloud {}` activo (y credenciales configuradas), este comando conectaria con HCP Terraform en cambio.

### Paso 6: Ver el plan y aplicar

```bash
terraform plan
```

```bash
terraform apply -auto-approve
```

`terraform apply` crea el archivo `info-hcp.txt` con el backend local. En HCP Terraform real, el runner remoto ejecutaria este mismo codigo y guardaria el state en la nube.

### Paso 7: Verificar el archivo generado

```bash
cat /root/lab/info-hcp.txt
```

El archivo confirma que Terraform creo el recurso correctamente. En HCP Terraform, el state queda en la UI bajo "State Versions".

### Paso 8: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Conceptos Aprendidos

- Bloque `cloud {}` vs `backend "remote" {}`: cuando y por que usar cada uno
- `terraform login` y el archivo `credentials.tfrc.json`
- Modos de ejecucion: Remote, Local, Agent
- Variables en HCP Terraform: Terraform vars y Environment vars
- Historial de runs y versiones de state

## Recursos

- [HCP Terraform Getting Started](https://developer.hashicorp.com/terraform/tutorials/cloud-get-started)
- [Terraform Cloud Block](https://developer.hashicorp.com/terraform/language/settings/terraform-cloud)

---

**Anterior:** [Modulo 07 - Maintain Infrastructure](../../07-maintain-infrastructure/)
**Siguiente:** [Lab 2 - VCS Workflows](../lab2-vcs-workflows/)
