#!/bin/bash

echo "⚙️  Generando configuración desde template..."

# Verificar si consul-template está disponible
if command -v consul-template &> /dev/null; then
    # Usar consul-template si está disponible
    consul-template -template="app-config.tpl:app-config.conf" -once
    echo "✅ Configuración generada con consul-template"
else
    # Generar manualmente si consul-template no está disponible
    echo "📝 Generando configuración manualmente..."
    
    cat > app-config.conf << EOF
# Configuración generada automáticamente desde Consul KV
# Generado el: $(date)

[database]
host = "$(consul kv get app/config/database/host)"
port = $(consul kv get app/config/database/port)
name = "$(consul kv get app/config/database/name)"
ssl = $(consul kv get app/config/database/ssl)

[api]
version = "$(consul kv get app/config/api/version)"
timeout = "$(consul kv get app/config/api/timeout)"
max_connections = $(consul kv get app/config/api/max_connections)

[features]
new_ui = $(consul kv get app/features/new_ui)
analytics = $(consul kv get app/features/analytics)
beta_features = $(consul kv get app/features/beta_features)

[environment]
name = "$(consul kv get app/env/name)"
debug = $(consul kv get app/env/debug)
log_level = "$(consul kv get app/env/log_level)"

[services]
redis_url = "$(consul kv get services/redis/host):$(consul kv get services/redis/port)"
elasticsearch_url = "$(consul kv get services/elasticsearch/url)"
EOF
    echo "✅ Configuración generada manualmente"
fi

echo ""
echo "📄 Archivo de configuración generado:"
echo "====================================="
cat app-config.conf
