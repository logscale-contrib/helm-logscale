{{- define "humio-instance.environment" -}}
# We always want out logs to std out in json format this is required
# - name: HUMIO_LOG4J_CONFIGURATION
  # value: log4j2-json-stdout.xml
# Reduce log volume to error only on STDOUT we will use otel injection for routine logs  
- name: HUMIO_LOG4J_CONFIGURATION
  value: "/var/lib/humio/config/logging/log4j2-json-k8s.xml"  
#  These can be turned back on
- name: ENABLEINTERNALLOGGER
  value: {{ .Values.humio.config.enableInternalLogger | default "false" | quote }}
- name: SEARCH_PIPELINE_MONITOR_JOB_ENABLE
  value: {{ .Values.humio.config.searchPipelineMonitorJob | default "false" | quote }}
{{- if eq .Values.humio.kafka.manager "strimzi" }}
- name: KAFKA_SERVERS
  value: {{ include "humio-instance.fullname" . }}-kafka-bootstrap:9092
{{- else }}
- name: KAFKA_SERVERS
  value: {{ .Values.humio.kafka.bootstrap | quote }}
{{- end }}
{{- if or (eq .Values.humio.kafka.manager "strimzi") (eq .Values.humio.kafka.manager "external") }}
- name: KAFKA_MANAGED_BY_HUMIO
  value: "false"
{{- else }}
- name: KAFKA_MANAGED_BY_HUMIO
  value: "true"
{{- end }}
{{- if .Values.humio.kafka.prefixEnable }}
- name: HUMIO_KAFKA_TOPIC_PREFIX
  value: {{ .Values.humio.kafka.topicPrefix | default .Release.Name }}-
{{- end }}
  #Object Storage config
{{- if eq  .Values.humio.buckets.type "none" }}  
- name: USING_EPHEMERAL_DISKS
  value: "false"
{{- else }}
- name: USING_EPHEMERAL_DISKS
  value: "true"
{{- end }}
{{- if eq  .Values.humio.buckets.type "aws" }}
- name: LOCAL_STORAGE_MIN_AGE_DAYS
  value: {{ .Values.humio.buckets.localStorageMinAgeDays | default "3" | quote }}
- name: LOCAL_STORAGE_PERCENTAGE
  value: {{ .Values.humio.buckets.localStoragePercentage | default "94" | quote }}
- name: S3_STORAGE_PREFERRED_COPY_SOURCE
  value: "true"
- name: S3_STORAGE_ENCRYPTION_KEY
  value: {{ .Values.humio.buckets.storageKey | default "off" | quote }}
- name: BUCKET_STORAGE_SSE_COMPATIBLE
  value: "true"
- name: S3_STORAGE_BUCKET
  value: {{ .Values.humio.buckets.storage }}
- name: S3_STORAGE_REGION
  value: {{ .Values.humio.buckets.region }}
- name: S3_STORAGE_OBJECT_KEY_PREFIX
  value: {{ .Values.humio.buckets.prefix }}
{{- else if eq  .Values.humio.buckets.type "s3proxy" }}
- name: LOCAL_STORAGE_MIN_AGE_DAYS
  value: {{ .Values.humio.buckets.localStorageMinAgeDays | default "3" | quote }}
- name: LOCAL_STORAGE_PERCENTAGE
  value: {{ .Values.humio.buckets.localStoragePercentage | default "94" | quote }}
- name: S3_STORAGE_PREFERRED_COPY_SOURCE
  value: "true"
- name: S3_STORAGE_PATH_STYLE_ACCESS
  value: "true"
- name: S3_STORAGE_IBM_COMPAT
  value: "true"
- name: BUCKET_STORAGE_IGNORE_ETAG_UPLOAD
  value: "true"
- name: BUCKET_STORAGE_IGNORE_ETAG_AFTER_UPLOAD
  value: "true"
- name: BUCKET_STORAGE_SSE_COMPATIBLE
  value: "true"
- name: S3_STORAGE_ENDPOINT_BASE
  value: {{ .Values.humio.buckets.s3proxy.endpoint }}
- name: S3_STORAGE_ENCRYPTION_KEY
  value: "off"
- name: S3_STORAGE_ACCESSKEY
  valueFrom:
    secretKeyRef:
        key: AWS_ACCESS_KEY_ID
        name: {{ .Values.humio.buckets.s3proxy.secret }}
- name: S3_STORAGE_SECRETKEY
  valueFrom:
    secretKeyRef:
        key: AWS_SECRET_ACCESS_KEY
        name: {{ .Values.humio.buckets.s3proxy.secret }}
- name: S3_STORAGE_BUCKET
  value: {{ .Values.humio.buckets.storage }}
- name: S3_ARCHIVING_PATH_STYLE_ACCESS
  value: "true"
- name: S3_EXPORT_PATH_STYLE_ACCESS
  value: "true"
- name: S3_STORAGE_OBJECT_KEY_PREFIX
  value: {{ .Values.humio.buckets.prefix }}
{{- else if eq  .Values.humio.buckets.type "gcp" }}
- name: LOCAL_STORAGE_MIN_AGE_DAYS
  value: {{ .Values.humio.buckets.localStorageMinAgeDays | default "3" | quote }}
- name: LOCAL_STORAGE_PERCENTAGE
  value: {{ .Values.humio.buckets.localStoragePercentage | default "94" | quote }}
- name: GCP_STORAGE_PREFERRED_COPY_SOURCE
  value: "true"
- name: GCP_STORAGE_BUCKET
  value: {{ .Values.humio.buckets.name }}
- name: GCP_STORAGE_WORKLOAD_IDENTITY
  value: "true"
- name: GCP_STORAGE_ENCRYPTION_KEY
  value: "off"
- name: GCP_STORAGE_OBJECT_KEY_PREFIX
  value : "storage/"
{{- if eq .Values.humio.drMode "bootstrap" }}
- name: GCP_RECOVER_FROM_BUCKET
  value: {{ .Values.humio.buckets.recoverFromBucketID }}
- name: GCP_RECOVER_FROM_WORKLOAD_IDENTITY
  value: "true"
- name: GCP_RECOVER_FROM_ENCRYPTION_KEY
  value: "off"
- name: GCP_RECOVER_FROM_OBJECT_KEY_PREFIX
  value : "storage/"
{{- if .Values.humio.buckets.recoverFromReplace }}  
- name: GCP_RECOVER_FROM_REPLACE_BUCKET
  value : {{ .Values.humio.buckets.recoverFromReplace | quote }}
{{- end }}  
{{- end }}
- name: GCP_EXPORT_WORKLOAD_IDENTITY
  value: "true"
- name: GCP_EXPORT_BUCKET
  value: {{ .Values.humio.buckets.name }}
- name: GCP_EXPORT_ENCRYPTION_KEY
  value: "off"
- name: GCP_EXPORT_OBJECT_KEY_PREFIX
  value : "export/"
{{- if .Values.humio.buckets.downloadConcurrency }}
- name: GCP_STORAGE_DOWNLOAD_CONCURRENCY
  value : {{ .Values.humio.buckets.downloadConcurrency | quote }}
{{- end }}
{{- else if eq  .Values.humio.buckets.type "none" }}
{{- else }}
{{- end }}
- name: AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN
  value: "true"
- name: AUTO_UPDATE_GROUP_MEMBERSHIPS_ON_SUCCESSFUL_LOGIN
  value: "true"
- name: PUBLIC_URL
  value: "https://{{ .Values.humio.fqdn }}"
- name: AUTHENTICATION_METHOD
  value: {{ .Values.humio.auth.method }}
{{- if eq  .Values.humio.auth.method  "single-user" }}
{{- else if eq  .Values.humio.auth.method  "saml" }}
- name: SAML_IDP_SIGN_ON_URL
  value: {{ .Values.humio.auth.saml.signOnUrl }}
- name: SAML_IDP_ENTITY_ID
  value: {{ .Values.humio.auth.saml.entityID }}
- name: SAML_GROUP_MEMBERSHIP_ATTRIBUTE
  value: {{ .Values.humio.auth.saml.groupMembershipAttribute | default "memberOf" }}
{{- else if eq  .Values.humio.auth.method  "oauth" }}
- name: OIDC_PROVIDER
  value: {{ .Values.humio.auth.oauth.provider }}
- name: OIDC_USERNAME_CLAIM
  value: {{ .Values.humio.auth.oauth.username_claim | default "email" }}
{{- if .Values.humio.auth.oauth.groups_claim }}
- name: OIDC_GROUPS_CLAIM
  value: {{ .Values.humio.auth.oauth.groups_claim }}
{{- end }}
- name: OIDC_OAUTH_CLIENT_ID
  value: {{ .Values.humio.auth.oauth.client_id }}
- name: OIDC_OAUTH_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
        key: {{ .Values.humio.auth.oauth.client_secret_key | default "secret" }}
        name: {{ .Values.humio.auth.oauth.client_secret_name }}
- name: OIDC_SERVICE_NAME
  value: {{ .Values.humio.auth.oauth.serviceName | default "SSO" }}
- name: OIDC_SCOPES
  value: {{ .Values.humio.auth.oauth.scopes | default "openid,email,profile" }}
{{- else }}
{{- end }}
{{- if .Values.humio.smtp.enabled }}
- name: SMTP_HOST
  value: {{ .Values.humio.smtp.host }}
- name: SMTP_USERNAME
  value: {{ .Values.humio.smtp.username }}
- name: SMTP_PASSWORD
  value: {{ .Values.humio.smtp.password }}
- name: SMTP_SENDER_ADDRESS
  value: {{ .Values.humio.smtp.sender }}
- name: SMTP_PORT
  value: {{ .Values.humio.smtp.port | quote }}
- name: SMTP_USE_STARTTLS
  value: {{ .Values.humio.smtp.startTLS | quote }}
{{- end }}
{{- if .Values.humio.jvmARGS }}
- name: HUMIO_JVM_ARGS
  value: {{ .Values.humio.jvmARGS | quote }}
{{- end }}
{{- range .Values.humio.enableFeatures }}
- name: ENABLE_{{ . | upper}}
  value: "true"
{{- end }}
- name: HUMIO_JVM_LOG_OPTS
  value: "-Xlog:jit*=debug:file=/data/java-logs/jit_humio.log:time,tags:filecount=5,filesize=1024000 -Xlog:gc+jni=debug -Xlog:gc*:file=/data/java-logs/gc_humio.log:time,tags:filecount=5,filesize=102400"
{{- with .Values.humio.extraENV }}
{{ toYaml . | indent 0 }}
{{- end }}
{{- if ne .Values.humio.drMode "none" }}
- name: ENABLE_ALERTS
  value: "false"
- name: ENABLE_EVENT_FORWARDING
  value: "false"
- name: ENABLE_SCHEDULED_SEARCHES
  value: "false"
{{- end }}
{{- if ne .Values.humio.drMode "none" }}
- name: ENABLE_ALERTS
  value: "false"
- name: ENABLE_EVENT_FORWARDING
  value: "false"
- name: ENABLE_SCHEDULED_SEARCHES
  value: "false"
{{- end }}
{{- if .Values.humio.trustManagerConfigMap }}
- name: TLS_TRUSTSTORE_LOCATION
  value: /data/truststore/bundle.jks
{{- end }}
{{- end }}