{{- define "humio-instance.environmentKafka" -}}
{{- if eq .Values.logscale.kafka.manager "strimzi" }}
- name: KAFKA_SERVERS
  value: {{ include "humio-instance.fullname" . }}-kafka-bootstrap:9092
{{- else if eq .Values.logscale.kafka.manager "strimziAccessOperator" }}
- name: KAFKA_SERVERS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.logscale.kafka.serviceBindingSecret }}
      key: bootstrap.servers
- name: KAFKA_JAAS
    valueFrom:
    secretKeyRef:
        name: {{ .Values.logscale.kafka.serviceBindingSecret }}
        key: sasl.jaas.config      
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
# Generate env vars for kafka
{{- range $k, $v := .Values.logscale.kafka.extraConfigCommon -}}
    {{- $value := $v -}}
    {{- if or (kindIs "bool" $v) (kindIs "float64" $v) (kindIs "int" $v) (kindIs "int64" $v) -}}
        {{- $v = $v | toString | b64enc | quote -}}
    {{- else -}}
        {{- $v = tpl $v $.root | toString | b64enc | quote }}
    {{- end -}}
    {{- if and ($v) (ne $v "\"\"") }}
{{ printf "KAFKA_COMMON_%s" (upper $k | replace "." "_") }}: {{ $v }}
    {{- end }}
{{- end -}}
{{- end -}}
{{- end }}

