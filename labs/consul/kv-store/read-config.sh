#!/bin/bash

echo "📖 Leyendo configuración desde Consul KV Store..."

echo ""
echo "🗄️  Configuración de Base de Datos:"
echo "=================================="
echo "Host: $(consul kv get app/config/database/host)"
echo "Puerto: $(consul kv get app/config/database/port)"
echo "Nombre: $(consul kv get app/config/database/name)"
echo "SSL: $(consul kv get app/config/database/ssl)"

echo ""
echo "🔌 Configuración de API:"
echo "======================="
echo "Versión: $(consul kv get app/config/api/version)"
echo "Timeout: $(consul kv get app/config/api/timeout)"
echo "Max Conexiones: $(consul kv get app/config/api/max_connections)"

echo ""
echo "🎛️  Features Habilitadas:"
echo "========================"
echo "Nueva UI: $(consul kv get app/features/new_ui)"
echo "Analytics: $(consul kv get app/features/analytics)"
echo "Beta Features: $(consul kv get app/features/beta_features)"

echo ""
echo "🌍 Configuración de Entorno:"
echo "============================"
echo "Nombre: $(consul kv get app/env/name)"
echo "Debug: $(consul kv get app/env/debug)"
echo "Log Level: $(consul kv get app/env/log_level)"

echo ""
echo "🔗 Servicios Externos:"
echo "====================="
echo "Redis: $(consul kv get services/redis/host):$(consul kv get services/redis/port)"
echo "Elasticsearch: $(consul kv get services/elasticsearch/url)"
