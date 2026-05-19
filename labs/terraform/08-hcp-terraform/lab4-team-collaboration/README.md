# Lab 4: Team Collaboration

![Terraform](https://img.shields.io/badge/HCP_Terraform-Team_Collaboration-7B42BC?style=flat&logo=terraform)

## Objetivo

Aprender el modelo de permisos de HCP Terraform: equipos, roles por workspace, flujos de aprobacion manual, run triggers entre workspaces, y notificaciones. Las configuraciones de la UI se documentan con archivos que el script de validacion verifica localmente.

## Duracion

30 minutos

## Prerrequisitos

- Labs 1, 2 y 3 del modulo 08 completados
- Terraform instalado
- (Opcional) HCP Terraform con al menos un workspace activo y permisos de Owner

## Instrucciones Paso a Paso

### Paso 1: Crear el directorio de trabajo

```bash
mkdir -p /root/lab && cd /root/lab
```

El directorio de trabajo contendra la documentacion de los conceptos de colaboracion en equipo que se configuran en la UI de HCP Terraform.

### Paso 2: Documentar el modelo de permisos de HCP Terraform

```bash
touch modelo-permisos.md
```

```bash
cat > modelo-permisos.md <<'EOF'
# Modelo de Permisos en HCP Terraform

## Niveles de acceso (Organization Level)

Los permisos a nivel de organizacion se asignan a equipos y aplican globalmente:

| Permiso org           | Descripcion                                              |
|-----------------------|----------------------------------------------------------|
| Manage Workspaces     | Crear, editar y eliminar workspaces en la org            |
| Manage Policies       | Crear y editar Policy Sets y politicas Sentinel          |
| Manage Policy Overrides | Sobrescribir politicas soft-mandatory                  |
| Manage VCS Settings   | Configurar VCS Providers (GitHub, GitLab, etc.)          |
| Manage Providers      | Gestionar el Private Registry de providers               |
| Manage Modules        | Gestionar el Private Registry de modulos                 |
| Manage Membership     | Invitar usuarios y gestionar miembros de la org          |
| View All Workspaces   | Leer todos los workspaces sin poder editarlos            |
| View All Projects     | Leer todos los proyectos sin poder editarlos             |

## Niveles de acceso (Workspace Level)

Los permisos a nivel de workspace se asignan por equipo y sobrescriben los org-level:

| Rol workspace | Puede hacer                                              |
|---------------|----------------------------------------------------------|
| Read          | Ver runs, state y variables (sin ejecutar nada)          |
| Plan          | Ejecutar terraform plan (no puede aplicar)               |
| Write         | Ejecutar terraform plan y apply                          |
| Admin         | Configuracion completa del workspace (settings, teams)   |

## Equipos en HCP Terraform

- Un equipo agrupa usuarios con el mismo conjunto de permisos
- Un usuario puede pertenecer a multiples equipos
- El equipo "owners" siempre tiene acceso total e irrevocable
- Los equipos son el unico mecanismo de RBAC en HCP Terraform

## Equipos recomendados para una organizacion tipica

### developers
- Permiso org: ninguno
- Workspace dev: Write (pueden aplicar en dev)
- Workspace staging: Plan (solo plans, no aplican)
- Workspace produccion: Read (solo ven los runs)

### ops-team
- Permiso org: Manage Workspaces
- Workspace dev: Write
- Workspace staging: Write
- Workspace produccion: Write (con Manual Apply)

### security
- Permiso org: Manage Policies, Manage Policy Overrides
- Workspace produccion: Admin (pueden cambiar configuracion de seguridad)

### auditores
- Permiso org: View All Workspaces
- Sin acceso de escritura a ningun workspace

## Configuracion en la UI

Organization Settings > Teams > Create a team
- Name: nombre del equipo
- Visibility: Secret (solo miembros ven el equipo) o Visible
- Organization access: seleccionar permisos org
- Workspace access: se configura en cada workspace por separado

Workspace > Settings > Team Access > Add team and permissions
- Seleccionar el equipo
- Seleccionar el rol: Read / Plan / Write / Admin
EOF
```

El modelo de permisos de HCP Terraform es un tema central del examen Terraform Associate. La distincion entre permisos a nivel de Organization y a nivel de Workspace es fundamental para disenar una estrategia de acceso segura.

### Paso 3: Documentar los Run Triggers

```bash
touch run-triggers.md
```

```bash
cat > run-triggers.md <<'EOF'
# Run Triggers en HCP Terraform

## Que son los Run Triggers

Un Run Trigger conecta dos workspaces de forma que cuando el workspace
"fuente" completa un apply exitoso, el workspace "destino" inicia
automaticamente un nuevo plan.

## Caso de uso: infraestructura en capas

Las capas de infraestructura tienen dependencias entre si:

Workspace: networking
  Recursos: VPCs, subnets, security groups, route tables
  Outputs: vpc_id, subnet_ids, sg_id

    |
    v  (Run Trigger)

Workspace: compute
  Recursos: instancias EC2, Auto Scaling Groups
  Dependencias: usa los outputs de networking via terraform_remote_state

    |
    v  (Run Trigger)

Workspace: monitoring
  Recursos: CloudWatch alarms, dashboards
  Dependencias: usa los IDs de las instancias de compute

## Configuracion en la UI

Workspace destino (compute) > Settings > Run Triggers
> Add another workspace
> Seleccionar: networking

Cuando networking completa un apply:
1. HCP Terraform detecta el apply exitoso
2. Inicia automaticamente un plan en compute
3. Si compute tiene Auto Apply: tambien aplica automaticamente
4. Si compute tiene Manual Apply: espera confirmacion

## Comportamiento

- Si el workspace fuente FALLA el apply: el trigger NO se dispara
- Si el workspace fuente tiene un plan (sin apply): el trigger NO se dispara
- Multiple fuentes: un workspace puede tener triggers de varios workspaces
- Cadena: A -> B -> C es posible y cada nodo puede tener su propio Apply method

## Diferencia con Notifications

| Caracteristica    | Run Triggers              | Notifications             |
|-------------------|---------------------------|---------------------------|
| Accion            | Inicia un run             | Envia un mensaje          |
| Requiere          | Otro workspace en HCP     | URL de webhook o email    |
| Uso               | Orquestar infra en capas  | Alertar al equipo         |

## Alternativa: terraform_remote_state

Si los workspaces no usan Run Triggers, se puede usar terraform_remote_state
para leer outputs del workspace fuente directamente en el codigo:

```
data "terraform_remote_state" "networking" {
  backend = "remote"
  config = {
    organization = "mi-org"
    workspaces = { name = "networking" }
  }
}

resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.networking.outputs.subnet_id
}
```
EOF
```

Los Run Triggers automatizan la orquestacion de infraestructura en capas, eliminando la necesidad de coordinar manualmente el orden de applies entre equipos. Son especialmente utiles en arquitecturas donde la red debe existir antes del computo.

### Paso 4: Documentar las notificaciones

```bash
touch notificaciones.md
```

```bash
cat > notificaciones.md <<'EOF'
# Notificaciones en HCP Terraform

## Canales disponibles

| Canal              | Configuracion                                            |
|--------------------|----------------------------------------------------------|
| Email              | Lista de emails de usuarios de la org                    |
| Slack              | Incoming Webhook URL de un canal de Slack                |
| Microsoft Teams    | Incoming Webhook URL de un canal de Teams                |
| Generic Webhook    | Cualquier endpoint HTTP POST (PagerDuty, custom, etc.)   |

## Eventos que disparan notificaciones

| Evento                    | Cuando ocurre                                        |
|---------------------------|------------------------------------------------------|
| Run Pending               | El run esta en cola, esperando un runner             |
| Run Planning              | terraform plan esta en ejecucion                     |
| Run Needs Attention        | Plan completado, esperando aprobacion Manual Apply   |
| Run Applying              | terraform apply esta en ejecucion                    |
| Run Completed             | Apply exitoso                                        |
| Run Errored               | Plan o apply fallaron                                |
| Assessment Drifted        | Health check detecto drift en la infraestructura     |
| Assessment Failed         | Health check fallo                                   |

## Configuracion en la UI

Workspace > Settings > Notifications > Create a notification

- Name: nombre descriptivo (ej: "ops-slack-alerts")
- Destination: seleccionar el canal
- URL: webhook URL (para Slack, Teams o Generic)
- Token: token de autenticacion opcional para Generic Webhook
- Triggers: seleccionar que eventos notificar

## Estrategia de notificaciones recomendada

Para produccion:
  Canal: Slack #alerts-produccion
  Eventos: Run Needs Attention, Run Errored, Assessment Drifted

Para dev/staging:
  Canal: Slack #infra-dev
  Eventos: Run Errored

Para auditoria:
  Canal: Email o Generic Webhook -> SIEM
  Eventos: todos los eventos

## Formato del payload de Generic Webhook

HCP Terraform envia un POST con JSON:
{
  "payload_version": 1,
  "notification_configuration_id": "nc-...",
  "run_url": "https://app.terraform.io/app/org/workspaces/ws/runs/run-...",
  "run_id": "run-...",
  "run_message": "Queued manually via the Terraform Enterprise API",
  "run_created_at": "2024-01-15T10:30:00.000Z",
  "run_created_by": "usuario@empresa.com",
  "workspace_id": "ws-...",
  "workspace_name": "produccion-vpc",
  "organization_name": "mi-org",
  "notifications": [
    {
      "message": "Run Needs Attention in produccion-vpc",
      "trigger": "run:needs_attention",
      "run_status": "planned",
      "run_updated_at": "2024-01-15T10:35:00.000Z"
    }
  ]
}
EOF
```

Las notificaciones cierran el ciclo de colaboracion en equipo: cuando un run requiere aprobacion o falla, el equipo recibe la alerta en el canal correcto sin tener que monitorear la UI constantemente.

### Paso 5: Crear la configuracion Terraform del lab

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

# Simula la configuracion que un equipo aprobaria antes de aplicar
resource "local_file" "politica_acceso" {
  filename = "/root/lab/politica-acceso.txt"
  content  = <<-EOT
    # Politica de acceso - requiere aprobacion del equipo ops-team
    workspace     = lab-team-collaboration
    apply_method  = manual
    aprovador     = ops-team
    generado      = ${timestamp()}
  EOT
}

resource "local_file" "resumen_teams" {
  filename = "/root/lab/resumen-teams.txt"
  content  = <<-EOT
    # Equipos configurados en HCP Terraform
    - developers: Write en dev, Plan en staging, Read en produccion
    - ops-team: Write en todos los ambientes (con Manual Apply en prod)
    - security: Manage Policies + Admin en produccion
    - auditores: View All Workspaces
  EOT
}
EOF
```

Este `main.tf` genera archivos que representan la documentacion de acceso de la organizacion. En produccion, estos datos estarian en un sistema de gestion de identidades integrado con HCP Terraform.

### Paso 6: Inicializar y aplicar

```bash
terraform init
```

```bash
terraform apply -auto-approve
```

`terraform apply` crea los archivos de documentacion localmente. En HCP Terraform con Manual Apply, este paso quedaria detenido en "Needs Confirmation" hasta que un miembro del equipo apruebe el run en la UI.

### Paso 7: Ver el state generado

```bash
terraform show
```

`terraform show` muestra el estado actual de todos los recursos gestionados. En HCP Terraform, este estado queda almacenado de forma cifrada y con historial de versiones.

### Paso 8: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Conceptos Aprendidos

- Modelo de permisos: Organization Level vs Workspace Level
- Equipos y asignacion de roles: Read, Plan, Write, Admin
- Manual Apply vs Auto Apply: cuando usar cada uno por ambiente
- Run Triggers: orquestar infraestructura en capas sin intervencion manual
- Notificaciones: canales (Slack, Email, Teams, Webhook) y eventos
- Audit Trail: trazabilidad de quien ejecuto que y cuando

## Recursos

- [HCP Terraform Teams](https://developer.hashicorp.com/terraform/cloud-docs/users-teams-organizations/teams)
- [Run Triggers](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers)
- [Notifications](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/notifications)

---

**Anterior:** [Lab 3 - Sentinel Policies](../lab3-sentinel-policies/)
**Siguiente:** Bootcamp Terraform Associate 004 completado.
