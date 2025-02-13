{{- define "humio-instance.environmentKafka" -}}
# Generate env vars for kafka
{{- range $k, $v := .Values.logscale.kafka.extraConfigCommon -}}
    {{- $value := $v -}}
    {{- if or (kindIs "bool" $v) (kindIs "float64" $v) (kindIs "int" $v) (kindIs "int64" $v) -}}
        {{- $v = $v | toString | quote -}}
    {{- else -}}
        {{- $v = tpl $v $.root | toString | quote }}
    {{- end -}}
    {{- if and ($v) (ne $v "\"\"") }}
{{ printf "- name: KAFKA_COMMON_%s" (upper $k | replace "." "_") }}
  value: {{ $v }}
    {{- end }}
{{- end -}}

{{- if .Values.logscale.kafka.serviceBindingSecret }}
- name: KAFKA_SERVERS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.logscale.kafka.serviceBindingSecret }}
      key: bootstrap.servers
- name: KAFKA_COMMON_SASL_JAAS_CONFIG
  valueFrom:
    secretKeyRef:
      name: {{ .Values.logscale.kafka.serviceBindingSecret }}
      key: sasl.jaas.config
      # optional: true
- name: KAFKA_COMMON_SASL_MECHANISM
  valueFrom:
    secretKeyRef:
      name: {{ .Values.logscale.kafka.serviceBindingSecret }}
      key: sasl.mechanism
      # optional: true
- name: KAFKA_COMMON_SECURITY_PROTOCOL
  valueFrom:
    secretKeyRef:
      name: {{ .Values.logscale.kafka.serviceBindingSecret }}
      key: security.protocol
      # optional: true
{{- if .Values.logscale.trustManagerConfigMap }}
- name: KAFKA_COMMON_SSL_TRUSTSTORE_LOCATION
  value: /mnt/truststore/bundle.jks
{{- else }}
- name: KAFKA_COMMON_SSL_TRUSTSTORE_LOCATION
  value: /mnt/kafka/truststore/bundle.jks
- name: KAFKA_COMMON_SSL_TRUSTSTORE_TYPE
  value: PEM
{{- end }}
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

{{- define "humio-instance.extraVolumesKafka" -}}
{{- if .Values.logscale.kafka.serviceBindingSecret }}
- name: kafka-trust-store
  secret:
    # Provide the name of the ConfigMap containing the files you want
    # to add to the container
    secretName: {{ .Values.logscale.kafka.serviceBindingSecret }}
    items:
    - key: ssl.truststore.crt
      path: bundle.pem
{{- end }}
{{- end }}
{{- define "humio-instance.extraHumioVolumeMountsKafka" -}}
{{- if .Values.logscale.kafka.serviceBindingSecret }}
- name: kafka-trust-store
  mountPath: /mnt/kafka/truststore
{{- end }}
{{- end }}
