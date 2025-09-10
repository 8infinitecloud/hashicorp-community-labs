# Lab Consul: KV Store Básico

![Consul](https://img.shields.io/badge/Consul-Practitioner-F24C53?style=flat&logo=consul)

## 🎯 Objetivo
Usar Consul como almacén de configuración distribuida (KV Store).

## ⏱️ Duración
10-15 minutos

## 📋 Prerrequisitos
- Consul instalado

## 🚀 Instrucciones

1. **Iniciar Consul en modo dev**:
   ```bash
   ./start-consul.sh
   ```

2. **Configurar datos en KV Store**:
   ```bash
   ./setup-kv-data.sh
   ```

3. **Leer configuración**:
   ```bash
   ./read-config.sh
   ```

4. **Usar templates para configuración**:
   ```bash
   ./generate-config.sh
   ```

5. **Limpiar entorno**:
   ```bash
   ./cleanup.sh
   ```

## ✅ Validación
El laboratorio se considera completado cuando:
- Consul está ejecutándose correctamente
- Los datos se almacenan en el KV Store
- Se pueden leer los valores correctamente
- Los templates generan configuración válida

## 🏆 Badge
Al completar este lab, obtienes el badge **Consul Practitioner**.
