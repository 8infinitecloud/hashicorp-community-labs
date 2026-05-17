# Lab 4: Team Collaboration

![Terraform](https://img.shields.io/badge/HCP_Terraform-Team_Collaboration-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Configurar equipos y permisos en HCP Terraform para gestionar el acceso a workspaces, y configurar flujos de aprobación que requieran revisión humana antes del apply.

## ⏱️ Duración
30 minutos

## 📋 Prerrequisitos
- ✅ Labs 1, 2 y 3 del módulo 08 completados
- HCP Terraform con al menos un workspace activo
- Permisos de Owner en la organización

## 🚀 Instrucciones Paso a Paso

### Paso 1: Entender el Modelo de Permisos

```bash
cat > modelo-permisos.md << 'EOF'
# Modelo de Permisos en HCP Terraform

## Niveles de acceso (de menor a mayor)

### Organization Level
- Viewer: solo lectura de todos los workspaces
- Operator: puede ejecutar runs pero no cambiar configuración
- Admin: acceso total a la organización

### Workspace Level (se puede sobreescribir por equipo)
- Read: ver runs y state, sin ejecutar
- Plan: ejecutar plans pero no applies
- Write: ejecutar plans y applies
- Admin: configuración completa del workspace

## Equipos
- Agrupa usuarios con el mismo rol en workspaces
- Un usuario puede estar en múltiples equipos
- El equipo "owners" siempre tiene acceso total
EOF

cat modelo-permisos.md
```

### Paso 2: Crear Equipos en HCP Terraform

En la UI de HCP Terraform:

```
Organization Settings → Teams → Create a team

Crear los siguientes equipos:

1. Equipo: developers
   - Visibilidad: Secret (solo miembros ven el equipo)
   - Permisos org: ninguno (solo workspace-level)

2. Equipo: ops-team
   - Visibilidad: Secret
   - Permisos org: Manage Workspaces

3. Equipo: security
   - Visibilidad: Secret
   - Permisos org: Manage Policies
```

### Paso 3: Asignar Permisos por Workspace

```
Workspace → Settings → Team Access → Add team and permissions

Workspace: lab-vcs-workflow
- developers  → Plan (pueden ver plans, no aplicar)
- ops-team    → Write (pueden aplicar en staging/dev)
- security    → Read (solo auditoría)

Para workspaces de producción:
- developers  → Plan
- ops-team    → Write
- security    → Admin (pueden cambiar políticas)
```

### Paso 4: Configurar Run Triggers (Dependencias entre Workspaces)

En un escenario real con múltiples workspaces:

```
Workspace: app-networking (crea VPCs y subnets)
    ↓ (trigger)
Workspace: app-compute (crea instancias en las subnets)
    ↓ (trigger)
Workspace: app-monitoring (configura alertas)

Configurar en: Workspace → Settings → Run Triggers
- Source workspace: app-networking
- Al completar un apply exitoso → dispara plan en app-compute
```

Para el lab (documentar el flujo):

```bash
cat > run-triggers.md << 'EOF'
# Run Triggers en HCP Terraform

## Caso de uso
Infraestructura en capas donde una capa depende de la anterior.

## Configuración
1. Workspace destino (app-compute) → Settings → Run Triggers
2. Add another workspace → seleccionar app-networking
3. Cuando app-networking completa un apply → app-compute ejecuta un plan

## Beneficios
- No necesitas coordinar manualmente el orden de deploys
- Si app-networking falla, app-compute no se ejecuta
- Historial de runs muestra la cadena de triggers
EOF
cat run-triggers.md
```

### Paso 5: Configurar Aprobaciones Requeridas

```
Workspace: lab-vcs-workflow (de producción)
Settings → General → Manual Apply

Opciones:
- Auto Apply: HCP aplica automáticamente después del plan
- Manual Apply: requiere aprobación explícita en la UI

Para producción: Manual Apply
Para dev/staging: Auto Apply
```

Simular el flujo de aprobación:

```bash
# 1. Hacer un cambio en el código
cat >> main.tf << 'EOF'

# Cambio para trigger un run de aprobación
resource "local_file" "aprobacion" {
  filename = "./aprobacion-requerida.txt"
  content  = "Este archivo requirió aprobación manual antes de crearse\n"
}
EOF

git add .
git commit -m "feat: demostrar flujo de aprobación"
git push origin main
```

En HCP Terraform:
```
1. Se inicia un plan automáticamente
2. El plan completa con éxito
3. Estado: "Needs Confirmation"
4. Alguien del equipo revisa el plan
5. Click "Confirm & Apply" (o "Discard Run")
6. Apply se ejecuta
```

### Paso 6: Notificaciones del Equipo

```
Workspace → Settings → Notifications → Create a notification

Tipo: Slack (o Email)
Name: ops-notifications
URL: https://hooks.slack.com/services/... (webhook de Slack)

Triggers:
✅ Run needs attention (cuando un run espera aprobación)
✅ Run completed
✅ Run errored
```

```bash
cat > notificaciones.md << 'EOF'
# Configuración de Notificaciones

## Canales disponibles
- Email: notifica a emails específicos
- Slack: webhook de Slack
- Microsoft Teams: webhook
- Generic Webhook: cualquier endpoint HTTP

## Cuándo notificar
- Run Pending (plan ejecutado, esperando aprobación)
- Run Planning (plan en ejecución)
- Run Needs Attention (requiere aprobación manual)
- Run Applying (apply en ejecución)
- Run Completed (apply exitoso)
- Run Errored (fallo en plan o apply)
- Assessment Drifted (drift detectado)
EOF
cat notificaciones.md
```

### Paso 7: Audit Log de la Organización

```
Organization Settings → Audit Trail

Muestra:
- Quién ejecutó qué run y cuándo
- Cambios en configuración de workspaces
- Cambios en equipos y permisos
- Aplicaciones de políticas Sentinel

Exportar para auditoría:
Organization Settings → Audit Trail → Export
```

### Paso 8: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Al menos 2 equipos creados en la organización
2. ✅ Permisos asignados por workspace
3. ✅ Flujo de aprobación manual configurado o documentado
4. ✅ Run triggers comprendidos
5. ✅ Notificaciones configuradas o documentadas

## 🔧 Troubleshooting

### Error: "Not authorized to create teams"

```
Solo el Owner de la organización puede crear equipos.
Verifica tu rol: Organization Settings → Teams → Members
```

### Run no aparece como "Needs Confirmation"

```
Verifica que el workspace tiene "Manual Apply" habilitado:
Workspace → Settings → General → Apply Method → Manual Apply
```

## 🎓 Conceptos Aprendidos

- ✅ Modelo de permisos: Organization vs Workspace level
- ✅ Equipos y asignación de roles en workspaces
- ✅ Flujo de aprobación manual para producción
- ✅ Run Triggers para pipelines de infraestructura en capas
- ✅ Notificaciones en Slack/email para el equipo
- ✅ Audit Trail para compliance y auditoría

## 🏆 Badge

Al completar este laboratorio obtienes: **HCP Terraform Team Collaboration Badge**

---

**Anterior:** [Lab 3 - Sentinel Policies](../lab3-sentinel-policies/)
**Siguiente:** ¡Bootcamp Terraform Associate 004 completado! 🎉
