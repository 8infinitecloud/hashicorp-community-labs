#!/bin/bash

echo "📝 Configurando datos en Consul KV Store..."

# Configuración de aplicación
consul kv put app/config/database/host "localhost"
consul kv put app/config/database/port "5432"
consul kv put app/config/database/name "myapp"
consul kv put app/config/database/ssl "true"

# Configuración de API
consul kv put app/config/api/version "v1"
consul kv put app/config/api/timeout "30s"
consul kv put app/config/api/max_connections "100"

# Configuración de features
consul kv put app/features/new_ui "true"
consul kv put app/features/analytics "false"
consul kv put app/features/beta_features "true"

# Configuración de entorno
consul kv put app/env/name "development"
consul kv put app/env/debug "true"
consul kv put app/env/log_level "info"

# Configuración de servicios externos
consul kv put services/redis/host "redis.example.com"
consul kv put services/redis/port "6379"
consul kv put services/elasticsearch/url "https://es.example.com:9200"

echo "✅ Datos configurados en KV Store"
echo "🔍 Verifica en la UI: http://localhost:8500/ui/dc1/kv"
