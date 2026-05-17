# Lab 3: Sentinel Policies

![Terraform](https://img.shields.io/badge/HCP_Terraform-Sentinel-7B42BC?style=flat&logo=terraform)

## 🎯 Objetivo
Escribir políticas Sentinel para aplicar governance automático: bloquear configuraciones que no cumplan estándares de la organización.

## ⏱️ Duración
35 minutos

## 📋 Prerrequisitos
- ✅ Labs 1 y 2 del módulo 08 completados
- HCP Terraform con plan Plus o trial activo (Sentinel requiere plan de pago)
- Terraform CLI instalado

> 💡 **Sin plan Plus:** Puedes seguir los pasos de escritura y prueba local con `sentinel apply`. El paso de aplicar en HCP Terraform es referencia.

## 🚀 Instrucciones Paso a Paso

### Paso 1: Instalar la CLI de Sentinel

```bash
# macOS con Homebrew
brew install hashicorp/tap/sentinel

# Verificar
sentinel version

# Si no puedes instalar, estudia la sintaxis y el resto del lab
```

### Paso 2: Entender la Sintaxis Sentinel

```bash
mkdir lab3-sentinel-policies
cd lab3-sentinel-policies
```

Crea `politica-basica.sentinel`:

```python
# politica-basica.sentinel
# Política: todos los archivos locales deben tener permiso 0644

import "tfplan/v2" as tfplan

# Obtener todos los recursos local_file del plan
archivos = filter tfplan.resource_changes as _, rc {
    rc.type is "local_file" and
    (rc.change.actions contains "create" or rc.change.actions contains "update")
}

# Regla: file_permission debe ser "0644"
permiso_correcto = rule {
    all archivos as _, archivo {
        archivo.change.after.file_permission is "0644"
    }
}

# Política principal
main = rule {
    permiso_correcto
}
```

```bash
# No se puede probar sin un plan real de HCP Terraform
# Pero podemos verificar la sintaxis
sentinel fmt politica-basica.sentinel   # formatea el archivo
cat politica-basica.sentinel
```

### Paso 3: Política con Mensaje de Error Descriptivo

Crea `politica-naming.sentinel`:

```python
# politica-naming.sentinel
# Política: los archivos generados deben estar en /output/ o /config/

import "tfplan/v2" as tfplan

archivos = filter tfplan.resource_changes as _, rc {
    rc.type is "local_file" and
    rc.change.actions contains "create"
}

# Función helper para verificar el path
ruta_valida = func(filename) {
    return filename matches "^.*(output|config)/.*$"
}

rutas_correctas = rule {
    all archivos as addr, archivo {
        ruta_valida(archivo.change.after.filename) else error(
            "El archivo " + addr + " debe estar en /output/ o /config/, " +
            "se encontró: " + archivo.change.after.filename
        )
    }
}

main = rule {
    rutas_correctas
}
```

### Paso 4: Mock Data para Testing Local

Crea `mocks/tfplan-v2.sentinel.json`:

```bash
mkdir -p mocks
```

```json
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
```

### Paso 5: Probar las Políticas Localmente

```bash
# Crear sentinel.json para configurar el mock
cat > sentinel.json << 'EOF'
{
  "mock": {
    "tfplan/v2": "mocks/tfplan-v2.sentinel.json"
  }
}
EOF

# Probar la política de naming (debe FALLAR porque secretos.txt no está en output/)
sentinel apply -config sentinel.json politica-naming.sentinel

# El resultado esperado:
# FAIL - politica-naming.sentinel
# Error: El archivo local_file.secreto debe estar en /output/ o /config/

# Corregir el mock para que todos los archivos estén en rutas válidas
# y volver a probar:
# PASS - politica-naming.sentinel
```

### Paso 6: Policy Set en HCP Terraform (Referencia)

En HCP Terraform (requiere plan Plus):

```
1. Organization → Policy Sets → New Policy Set
2. Nombre: politicas-peru-hug
3. Scope: All workspaces (o seleccionar workspaces específicos)
4. Conectar con VCS o subir políticas manualmente

Estructura del repositorio de políticas:
politicas/
├── sentinel.hcl          ← configuración del policy set
├── politica-naming.sentinel
├── politica-permisos.sentinel
└── mocks/
    └── ...

# sentinel.hcl
policy "politica-naming" {
  source            = "./politica-naming.sentinel"
  enforcement_level = "hard-mandatory"  # o "soft-mandatory" o "advisory"
}

policy "politica-permisos" {
  source            = "./politica-basica.sentinel"
  enforcement_level = "advisory"
}
```

### Paso 7: Niveles de Enforcement

```bash
cat > niveles-enforcement.md << 'EOF'
# Niveles de Enforcement en Sentinel

## hard-mandatory
- Bloquea el apply completamente si falla
- No puede ser sobrescrito por ningún usuario
- Para: requisitos de seguridad críticos

## soft-mandatory
- Bloquea el apply si falla
- Puede ser sobrescrito por usuarios con permiso "Manage Policies"
- Para: buenas prácticas que a veces tienen excepciones

## advisory
- Solo muestra advertencia, no bloquea
- Para: recomendaciones y auditoría
EOF

cat niveles-enforcement.md
```

### Paso 8: Ejecutar Validación

```bash
./validate-lab.sh
```

## ✅ Criterios de Validación

1. ✅ Al menos una política Sentinel escrita
2. ✅ Mock data creado para testing local
3. ✅ `sentinel apply` ejecutado (pass o fail esperado)
4. ✅ Niveles de enforcement documentados
5. ✅ Estructura de Policy Set comprendida

## 🎓 Conceptos Aprendidos

- ✅ Sintaxis Sentinel: `import`, `filter`, `rule`, `func`
- ✅ `tfplan/v2`: acceder al plan de Terraform desde Sentinel
- ✅ Mock data para testing local sin HCP Terraform
- ✅ Niveles de enforcement: `hard-mandatory`, `soft-mandatory`, `advisory`
- ✅ Policy Sets: aplicar políticas a múltiples workspaces

## 🏆 Badge

Al completar este laboratorio obtienes: **HCP Terraform Sentinel Policies Badge**

---

**Anterior:** [Lab 2 - VCS Workflows](../lab2-vcs-workflows/)
**Siguiente:** [Lab 4 - Team Collaboration](../lab4-team-collaboration/)
