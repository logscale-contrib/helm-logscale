{{- define "humio-instance.environment" -}}
{{- if eq .Values.humio.kafka.manager "strimzi" }}
- name: KAFKA_SERVERS
  value: {{ include "humio-instance.fullname" . }}-kafka-bootstrap:9092
{{- if eq .Values.humio.kafka.manager "strimziAccessOperator" }}
- name: KAFKA_SERVERS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.humio.kafka.serviceBindingSecret }}
      key: bootstrap.servers
{{- else }}
- name: KAFKA_SERVERS
  value: {{ .Values.humio.kafka.bootstrap | quote }}
{{- end }}
{{- if eq .Values.humio.kafka.manager "logscale" }}
- name: KAFKA_MANAGED_BY_HUMIO
  value: "true"
{{- else }}
- name: KAFKA_MANAGED_BY_HUMIO
  value: "false"
{{- end }}
{{- if .Values.humio.kafka.prefixEnable }}
- name: HUMIO_KAFKA_TOPIC_PREFIX
  value: {{ .Values.humio.kafka.topicPrefix | default .Release.Name }}-
{{- end }}
{{- end }}
