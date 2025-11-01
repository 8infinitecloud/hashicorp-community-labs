# Configuración generada automáticamente desde Consul KV
# Generado el: {{ timestamp }}

[database]
host = "{{ key "app/config/database/host" }}"
port = {{ key "app/config/database/port" }}
name = "{{ key "app/config/database/name" }}"
ssl = {{ key "app/config/database/ssl" }}

[api]
version = "{{ key "app/config/api/version" }}"
timeout = "{{ key "app/config/api/timeout" }}"
max_connections = {{ key "app/config/api/max_connections" }}

[features]
new_ui = {{ key "app/features/new_ui" }}
analytics = {{ key "app/features/analytics" }}
beta_features = {{ key "app/features/beta_features" }}

[environment]
name = "{{ key "app/env/name" }}"
debug = {{ key "app/env/debug" }}
log_level = "{{ key "app/env/log_level" }}"

[services]
redis_url = "{{ key "services/redis/host" }}:{{ key "services/redis/port" }}"
elasticsearch_url = "{{ key "services/elasticsearch/url" }}"
