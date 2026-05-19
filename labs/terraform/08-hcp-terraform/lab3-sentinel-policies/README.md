# Lab 3: Sentinel Policies

![Terraform](https://img.shields.io/badge/HCP_Terraform-Sentinel-7B42BC?style=flat&logo=terraform)

## Objetivo

Escribir politicas Sentinel para aplicar governance automatico sobre planes de Terraform. Las politicas se prueban localmente con mock data sin requerir HCP Terraform Plus: los mismos archivos que escribas aqui se podrian subir directamente a un Policy Set en HCP Terraform.

## Duracion

35 minutos

## Prerrequisitos

- Labs 1 y 2 del modulo 08 completados
- Terraform instalado
- (Opcional) CLI de Sentinel para pruebas locales: `brew install hashicorp/tap/sentinel`

## Instrucciones Paso a Paso

### Paso 1: Crear el directorio de trabajo

```bash
mkdir -p /root/lab && cd /root/lab
```

El directorio de trabajo contendra las politicas `.sentinel`, los mocks de prueba, y la configuracion del Policy Set.

### Paso 2: Crear la primera politica de permisos de archivo

```bash
touch politica-permisos.sentinel
```

```bash
cat > politica-permisos.sentinel <<'EOF'
# politica-permisos.sentinel
# Regla: todos los recursos local_file deben tener file_permission "0644"

import "tfplan/v2" as tfplan

# Filtrar solo los recursos local_file que se van a crear o actualizar
archivos = filter tfplan.resource_changes as _, rc {
    rc.type is "local_file" and
    (rc.change.actions contains "create" or rc.change.actions contains "update")
}

# Regla: file_permission debe ser exactamente "0644"
permiso_correcto = rule {
    all archivos as _, archivo {
        archivo.change.after.file_permission is "0644"
    }
}

# Regla principal que Sentinel evalua
main = rule {
    permiso_correcto
}
EOF
```

`import "tfplan/v2"` da acceso al plan de Terraform que HCP Terraform evaluaria antes de aplicar. `filter` selecciona solo los recursos relevantes, y `rule` define la condicion booleana que debe cumplirse.

### Paso 3: Crear la politica de rutas de archivos

```bash
touch politica-naming.sentinel
```

```bash
cat > politica-naming.sentinel <<'EOF'
# politica-naming.sentinel
# Regla: los archivos generados deben estar en /output/ o /config/

import "tfplan/v2" as tfplan

archivos = filter tfplan.resource_changes as _, rc {
    rc.type is "local_file" and
    rc.change.actions contains "create"
}

# Funcion helper que verifica si el path es valido
ruta_valida = func(filename) {
    return filename matches "^.*(output|config)/.*$"
}

rutas_correctas = rule {
    all archivos as addr, archivo {
        ruta_valida(archivo.change.after.filename) else error(
            "El archivo " + addr + " debe estar en /output/ o /config/, " +
            "se encontro: " + archivo.change.after.filename
        )
    }
}

main = rule {
    rutas_correctas
}
EOF
```

La funcion `func` en Sentinel permite extraer logica reutilizable. El uso de `else error(...)` produce mensajes descriptivos que aparecen en la UI de HCP Terraform cuando una politica falla.

### Paso 4: Crear el directorio de mocks

```bash
mkdir -p /root/lab/mocks
```

Los mocks simulan la salida del plan de Terraform (`tfplan/v2`) para que las politicas se puedan probar sin ejecutar un run real en HCP Terraform.

### Paso 5: Crear mock data que PASA las politicas

```bash
touch /root/lab/mocks/tfplan-v2-pass.sentinel.json
```

```bash
cat > /root/lab/mocks/tfplan-v2-pass.sentinel.json <<'EOF'
{
  "resource_changes": {
    "local_file.config": {
      "type": "local_file",
      "change": {
        "actions": ["create"],
        "after": {
          "filename": "/workspace/output/config.txt",
          "file_permission": "0644",
          "content": "entorno=dev"
        }
      }
    },
    "local_file.datos": {
      "type": "local_file",
      "change": {
        "actions": ["create"],
        "after": {
          "filename": "/workspace/config/app.conf",
          "file_permission": "0644",
          "content": "debug=false"
        }
      }
    }
  }
}
EOF
```

Este mock representa un plan donde todos los archivos estan en rutas validas (`/output/` y `/config/`) y tienen el permiso correcto (`0644`). Las politicas deben retornar PASS con este mock.

### Paso 6: Crear mock data que FALLA las politicas

```bash
touch /root/lab/mocks/tfplan-v2-fail.sentinel.json
```

```bash
cat > /root/lab/mocks/tfplan-v2-fail.sentinel.json <<'EOF'
{
  "resource_changes": {
    "local_file.config": {
      "type": "local_file",
      "change": {
        "actions": ["create"],
        "after": {
          "filename": "/workspace/output/config.txt",
          "file_permission": "0644",
          "content": "entorno=dev"
        }
      }
    },
    "local_file.secreto": {
      "type": "local_file",
      "change": {
        "actions": ["create"],
        "after": {
          "filename": "/workspace/secretos.txt",
          "file_permission": "0600",
          "content": "password=abc123"
        }
      }
    }
  }
}
EOF
```

Este mock representa el escenario problematico: `secretos.txt` no esta en `/output/` ni `/config/`, y tiene permiso `0600` en lugar de `0644`. Las politicas deben retornar FAIL.

### Paso 7: Crear el archivo sentinel.json de configuracion

```bash
touch /root/lab/sentinel.json
```

```bash
cat > /root/lab/sentinel.json <<'EOF'
{
  "mock": {
    "tfplan/v2": "mocks/tfplan-v2-pass.sentinel.json"
  }
}
EOF
```

`sentinel.json` le dice a la CLI de Sentinel que archivo usar como mock para cada import. Esto permite cambiar entre el mock de PASS y FAIL sin modificar las politicas.

### Paso 8: Crear el archivo de configuracion del Policy Set

```bash
touch /root/lab/sentinel.hcl
```

```bash
cat > /root/lab/sentinel.hcl <<'EOF'
# sentinel.hcl - Configuracion del Policy Set para HCP Terraform

policy "politica-permisos" {
  source            = "./politica-permisos.sentinel"
  enforcement_level = "hard-mandatory"
}

policy "politica-naming" {
  source            = "./politica-naming.sentinel"
  enforcement_level = "soft-mandatory"
}
EOF
```

`sentinel.hcl` define que politicas forman parte del Policy Set y con que nivel de enforcement. Este archivo se sube junto con los `.sentinel` al repositorio que HCP Terraform monitorea.

### Paso 9: Documentar los niveles de enforcement

```bash
touch /root/lab/niveles-enforcement.md
```

```bash
cat > /root/lab/niveles-enforcement.md <<'EOF'
# Niveles de Enforcement en Sentinel

## hard-mandatory

- Bloquea el apply completamente si la politica falla
- No puede ser sobrescrito por ningun usuario, ni por owners
- Uso: requisitos de seguridad criticos (ej: no exponer puertos 22/3389 publicamente)

## soft-mandatory

- Bloquea el apply si la politica falla
- Puede ser sobrescrito por usuarios con permiso "Manage Policies"
- Uso: buenas practicas que a veces tienen excepciones justificadas

## advisory

- Solo muestra una advertencia en la UI, no bloquea el apply
- El run continua aunque la politica falle
- Uso: recomendaciones de estilo o auditorias que no son criticas

## Flujo de evaluacion en HCP Terraform

Plan completado
    |
    v
Sentinel evalua TODAS las politicas del Policy Set
    |
    +-- hard-mandatory FAIL --> Run bloqueado, no se puede aplicar
    |
    +-- soft-mandatory FAIL --> Run bloqueado, owner puede sobrescribir
    |
    +-- advisory FAIL       --> Advertencia visible, apply continua
    |
    v
Apply ejecutado (si todas las politicas pasan o son sobrescritas)

## Estructura de un Policy Set en HCP Terraform

politicas/
├── sentinel.hcl                    <- configuracion del policy set
├── politica-permisos.sentinel      <- politica hard-mandatory
├── politica-naming.sentinel        <- politica soft-mandatory
└── mocks/
    ├── tfplan-v2-pass.sentinel.json
    └── tfplan-v2-fail.sentinel.json

## Scope de aplicacion

- All workspaces: la politica aplica a todos los workspaces de la org
- Selected workspaces: la politica aplica solo a workspaces especificos
- Exclusiones: se pueden excluir workspaces especificos del scope
EOF
```

Los niveles de enforcement son un tema frecuente en el examen Terraform Associate. `hard-mandatory` no puede ser sobrescrito por nadie, `soft-mandatory` puede ser sobrescrito por quien tiene el permiso correcto.

### Paso 10: Probar las politicas (si tienes sentinel CLI)

```bash
cd /root/lab && sentinel apply -config sentinel.json politica-permisos.sentinel 2>/dev/null || echo "sentinel CLI no instalado - los archivos estan correctos para HCP Terraform"
```

Si la CLI de Sentinel esta instalada, este comando evalua la politica contra el mock de PASS y debe retornar `Pass`. Sin la CLI, los archivos `.sentinel` son validos para subirse directamente a HCP Terraform.

### Paso 11: Ejecutar validacion

```bash
cd /root/lab && bash validate-lab.sh
```

## Conceptos Aprendidos

- Sintaxis Sentinel: `import`, `filter`, `rule`, `func`, `all`
- `tfplan/v2`: como acceder al plan de Terraform desde una politica
- Mock data: probar politicas sin un run real en HCP Terraform
- Niveles de enforcement: `hard-mandatory`, `soft-mandatory`, `advisory`
- `sentinel.hcl`: definir un Policy Set con multiples politicas
- Scope de aplicacion: All workspaces vs Selected workspaces

## Recursos

- [Sentinel Documentation](https://developer.hashicorp.com/sentinel/docs)
- [Terraform Sentinel Imports](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/sentinel/import)
- [Policy Sets](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/manage-policy-sets)

---

**Anterior:** [Lab 2 - VCS Workflows](../lab2-vcs-workflows/)
**Siguiente:** [Lab 4 - Team Collaboration](../lab4-team-collaboration/)
