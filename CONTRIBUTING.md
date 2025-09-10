# Guía de Contribución

¡Gracias por tu interés en contribuir a HashiCorp Foundational Labs! 🎉

## 🤝 Cómo Contribuir

### Reportar Issues
- Usa el template de issue apropiado
- Incluye información detallada sobre el problema
- Proporciona pasos para reproducir el issue

### Proponer Nuevos Labs
- Crea un issue describiendo el lab propuesto
- Incluye el objetivo de aprendizaje
- Especifica la duración estimada (10-15 minutos)
- Define los criterios de validación

### Enviar Pull Requests
1. Fork el repositorio
2. Crea una rama para tu feature: `git checkout -b feature/nuevo-lab`
3. Realiza tus cambios
4. Asegúrate de que los tests pasen
5. Commit con mensajes descriptivos
6. Push a tu fork: `git push origin feature/nuevo-lab`
7. Abre un Pull Request

## 📋 Estándares para Labs

### Estructura de Directorios
```
labs/
├── <tecnologia>/
│   └── <nombre-lab>/
│       ├── README.md
│       ├── scripts/
│       └── archivos de configuración
```

### README del Lab
Cada lab debe incluir:
- 🎯 Objetivo claro
- ⏱️ Duración (10-15 minutos)
- 📋 Prerrequisitos
- 🚀 Instrucciones paso a paso
- ✅ Criterios de validación
- 🏆 Badge obtenido

### Scripts
- Usar `#!/bin/bash` como shebang
- Incluir mensajes informativos con emojis
- Manejar errores apropiadamente
- Incluir script de cleanup

### Validación
- Cada lab debe tener validación automática en GitHub Actions
- Los tests deben ser determinísticos
- Incluir verificación de prerrequisitos

## 🔧 Desarrollo Local

### Prerrequisitos
- Git
- Docker
- Herramientas HashiCorp (según el lab)

### Setup
```bash
git clone https://github.com/tu-usuario/hashicorp-foundational-labs.git
cd hashicorp-foundational-labs
```

### Testing
```bash
# Ejecutar validaciones localmente
.github/workflows/validate-labs.yml
```

## 📝 Estilo de Código

### Scripts Bash
- Usar `set -e` para fallar en errores
- Validar prerrequisitos al inicio
- Usar variables en mayúsculas para exports
- Incluir cleanup en caso de error

### Documentación
- Usar markdown para toda la documentación
- Incluir emojis para mejorar legibilidad
- Mantener consistencia en formato

## 🏆 Sistema de Badges

Los badges se actualizan automáticamente basado en:
- Validación exitosa de GitHub Actions
- Completitud de la documentación
- Funcionalidad de los scripts

## ❓ Preguntas

Si tienes preguntas, puedes:
- Abrir un issue con la etiqueta `question`
- Contactar a los maintainers
- Revisar la documentación existente

¡Esperamos tus contribuciones! 🚀
