grafana:
  enabled: true

prometheus:
  enabled: true

  server:
    persistentVolume:
      enabled: false

  alertmanager:
    enabled: false