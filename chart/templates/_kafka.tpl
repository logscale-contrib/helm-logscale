{{- define "humio-instance.environmentKafka" -}}
{{- if eq .Values.logscale.kafka.manager "strimzi" }}
- name: KAFKA_SERVERS
  value: {{ include "humio-instance.fullname" . }}-kafka-bootstrap:9092
{{- if eq .Values.logscale.kafka.manager "strimziAccessOperator" }}
- name: KAFKA_SERVERS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.logscale.kafka.serviceBindingSecret }}
      key: bootstrap.servers
{{- else }}
- name: KAFKA_SERVERS
  value: {{ .Values.logscale.kafka.bootstrap | quote }}
{{- end }}
{{- if eq .Values.logscale.kafka.manager "logscale" }}
- name: KAFKA_MANAGED_BY_HUMIO
  value: "true"
{{- else }}
- name: KAFKA_MANAGED_BY_HUMIO
  value: "false"
{{- end }}
{{- if .Values.logscale.kafka.prefixEnable }}
- name: HUMIO_KAFKA_TOPIC_PREFIX
  value: {{ .Values.logscale.kafka.topicPrefix | default .Release.Name }}-
{{- end }}
{{- end }}
