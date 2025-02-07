{{- define "humio-instance.environment" -}}
# We always want out logs to std out in json format this is required
# Reduce log volume to error only on STDOUT we will use otel injection for routine logs  
- name: HUMIO_LOG4J_CONFIGURATION
  value: {{ .Values.logscale.config.log4jConfiguration | default "log4j2-json-stdout.xml"  | quote }}
  # Reduce STDOUT /var/lib/humio/config/logging/log4j2-json-k8s.xml
#  These can be turned back on
- name: ENABLEINTERNALLOGGER
  value: {{ .Values.logscale.config.enableInternalLogger | default "false" | quote }}
- name: SEARCH_PIPELINE_MONITOR_JOB_ENABLE
  value: {{ .Values.logscale.config.searchPipelineMonitorJob | default "false" | quote }}
  #Object Storage config
{{- if eq  .Values.logscale.buckets.type "none" }}  
- name: USING_EPHEMERAL_DISKS
  value: "false"
{{- else }}
- name: USING_EPHEMERAL_DISKS
  value: "true"
{{- end }}
{{- if eq  .Values.logscale.buckets.type "aws" }}
- name: LOCAL_STORAGE_MIN_AGE_DAYS
  value: {{ .Values.logscale.buckets.localStorageMinAgeDays | default "3" | quote }}
- name: LOCAL_STORAGE_PERCENTAGE
  value: {{ .Values.logscale.buckets.localStoragePercentage | default "94" | quote }}
- name: S3_STORAGE_PREFERRED_COPY_SOURCE
  value: "true"
- name: S3_STORAGE_ENCRYPTION_KEY
  value: {{ .Values.logscale.buckets.storageKey | default "off" | quote }}
- name: BUCKET_STORAGE_SSE_COMPATIBLE
  value: "true"
- name: S3_STORAGE_BUCKET
  value: {{ .Values.logscale.buckets.storage }}
- name: S3_STORAGE_REGION
  value: {{ .Values.logscale.buckets.region }}
- name: S3_STORAGE_OBJECT_KEY_PREFIX
  value: {{ .Values.logscale.buckets.prefix }}
{{- else if eq  .Values.logscale.buckets.type "s3proxy" }}
- name: LOCAL_STORAGE_MIN_AGE_DAYS
  value: {{ .Values.logscale.buckets.localStorageMinAgeDays | default "3" | quote }}
- name: LOCAL_STORAGE_PERCENTAGE
  value: {{ .Values.logscale.buckets.localStoragePercentage | default "94" | quote }}
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
  value: {{ .Values.logscale.buckets.s3proxy.endpoint }}
- name: S3_STORAGE_ENCRYPTION_KEY
  value: "off"
- name: S3_STORAGE_ACCESSKEY
  valueFrom:
    secretKeyRef:
        key: AWS_ACCESS_KEY_ID
        name: {{ .Values.logscale.buckets.s3proxy.secret }}
- name: S3_STORAGE_SECRETKEY
  valueFrom:
    secretKeyRef:
        key: AWS_SECRET_ACCESS_KEY
        name: {{ .Values.logscale.buckets.s3proxy.secret }}
- name: S3_STORAGE_BUCKET
  value: {{ .Values.logscale.buckets.storage }}
- name: S3_ARCHIVING_PATH_STYLE_ACCESS
  value: "true"
- name: S3_EXPORT_PATH_STYLE_ACCESS
  value: "true"
- name: S3_STORAGE_OBJECT_KEY_PREFIX
  value: {{ .Values.logscale.buckets.prefix }}
{{- else if eq  .Values.logscale.buckets.type "gcp" }}
- name: LOCAL_STORAGE_MIN_AGE_DAYS
  value: {{ .Values.logscale.buckets.localStorageMinAgeDays | default "3" | quote }}
- name: LOCAL_STORAGE_PERCENTAGE
  value: {{ .Values.logscale.buckets.localStoragePercentage | default "94" | quote }}
- name: GCP_STORAGE_PREFERRED_COPY_SOURCE
  value: "true"
- name: GCP_STORAGE_BUCKET
  value: {{ .Values.logscale.buckets.name }}
- name: GCP_STORAGE_WORKLOAD_IDENTITY
  value: "true"
- name: GCP_STORAGE_ENCRYPTION_KEY
  value: "off"
- name: GCP_STORAGE_OBJECT_KEY_PREFIX
  value : "storage/"
{{- if eq .Values.logscale.drMode "bootstrap" }}
- name: GCP_RECOVER_FROM_BUCKET
  value: {{ .Values.logscale.buckets.recoverFromBucketID }}
- name: GCP_RECOVER_FROM_WORKLOAD_IDENTITY
  value: "true"
- name: GCP_RECOVER_FROM_ENCRYPTION_KEY
  value: "off"
- name: GCP_RECOVER_FROM_OBJECT_KEY_PREFIX
  value : "storage/"
{{- if .Values.logscale.buckets.recoverFromReplace }}  
- name: GCP_RECOVER_FROM_REPLACE_BUCKET
  value : {{ .Values.logscale.buckets.recoverFromReplace | quote }}
{{- end }}  
{{- end }}
- name: GCP_EXPORT_WORKLOAD_IDENTITY
  value: "true"
- name: GCP_EXPORT_BUCKET
  value: {{ .Values.logscale.buckets.name }}
- name: GCP_EXPORT_ENCRYPTION_KEY
  value: "off"
- name: GCP_EXPORT_OBJECT_KEY_PREFIX
  value : "export/"
{{- if .Values.logscale.buckets.downloadConcurrency }}
- name: GCP_STORAGE_DOWNLOAD_CONCURRENCY
  value : {{ .Values.logscale.buckets.downloadConcurrency | quote }}
{{- end }}
{{- else if eq  .Values.logscale.buckets.type "none" }}
{{- else }}
{{- end }}
{{- if .Values.scim.enabled }}
- name: AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN
  value: "false"
- name: AUTO_UPDATE_GROUP_MEMBERSHIPS_ON_SUCCESSFUL_LOGIN
  value: "false"
{{- else }}
- name: AUTO_CREATE_USER_ON_SUCCESSFUL_LOGIN
  value: "true"
- name: AUTO_UPDATE_GROUP_MEMBERSHIPS_ON_SUCCESSFUL_LOGIN
  value: "true"
{{- end }}
- name: PUBLIC_URL
  value: "https://{{ .Values.logscale.fqdn }}"
- name: AUTHENTICATION_METHOD
  value: {{ .Values.logscale.auth.method }}
{{- if eq  .Values.logscale.auth.method  "single-user" }}
{{- else if eq  .Values.logscale.auth.method  "saml" }}
- name: SAML_IDP_SIGN_ON_URL
  value: {{ .Values.logscale.auth.saml.signOnUrl }}
- name: SAML_IDP_ENTITY_ID
  value: {{ .Values.logscale.auth.saml.entityID }}
- name: SAML_GROUP_MEMBERSHIP_ATTRIBUTE
  value: {{ .Values.logscale.auth.saml.groupMembershipAttribute | default "memberOf" }}
{{- else if eq  .Values.logscale.auth.method  "oauth" }}
- name: OIDC_PROVIDER
  value: {{ .Values.logscale.auth.oauth.provider }}
- name: OIDC_USERNAME_CLAIM
  value: {{ .Values.logscale.auth.oauth.username_claim | default "email" }}
{{- if .Values.logscale.auth.oauth.groups_claim }}
- name: OIDC_GROUPS_CLAIM
  value: {{ .Values.logscale.auth.oauth.groups_claim }}
{{- end }}
- name: OIDC_OAUTH_CLIENT_ID
  value: {{ .Values.logscale.auth.oauth.client_id }}
- name: OIDC_OAUTH_CLIENT_SECRET
  valueFrom:
    secretKeyRef:
        key: {{ .Values.logscale.auth.oauth.client_secret_key | default "secret" }}
        name: {{ .Values.logscale.auth.oauth.client_secret_name }}
- name: OIDC_SERVICE_NAME
  value: {{ .Values.logscale.auth.oauth.serviceName | default "SSO" }}
- name: OIDC_SCOPES
  value: {{ .Values.logscale.auth.oauth.scopes | default "openid,email,profile" }}
{{- else }}
{{- end }}
{{- if .Values.logscale.smtp.enabled }}
- name: SMTP_HOST
  value: {{ .Values.logscale.smtp.host }}
{{- if .Values.logscale.smtp.username }}  
- name: SMTP_USERNAME
  value: {{ .Values.logscale.smtp.username }}
{{- end }}
{{- if .Values.logscale.smtp.password }}  
- name: SMTP_PASSWORD
  value: {{ .Values.logscale.smtp.password }}
{{- end }}
- name: SMTP_SENDER_ADDRESS
  value: {{ .Values.logscale.smtp.sender }}
- name: SMTP_PORT
  value: {{ .Values.logscale.smtp.port | quote }}
- name: SMTP_USE_STARTTLS
  value: {{ .Values.logscale.smtp.startTLS | quote }}
{{- end }}
{{- if .Values.logscale.jvmARGS }}
- name: HUMIO_JVM_ARGS
  value: {{ .Values.logscale.jvmARGS | quote }}
{{- end }}
{{- range .Values.logscale.enableFeatures }}
- name: ENABLE_{{ . | upper}}
  value: "true"
{{- end }}
- name: HUMIO_JVM_LOG_OPTS
  value: "-Xlog:jit*=debug:file=/data/java-logs/jit_humio.log:time,tags:filecount=5,filesize=1024000 -Xlog:gc+jni=debug -Xlog:gc*:file=/data/java-logs/gc_humio.log:time,tags:filecount=5,filesize=102400"
{{- with .Values.logscale.extraENV }}
{{ toYaml . | indent 0 }}
{{- end }}
{{- if ne .Values.logscale.drMode "none" }}
- name: ENABLE_ALERTS
  value: "false"
- name: ENABLE_EVENT_FORWARDING
  value: "false"
- name: ENABLE_SCHEDULED_SEARCHES
  value: "false"
{{- end }}
{{- if ne .Values.logscale.drMode "none" }}
- name: ENABLE_ALERTS
  value: "false"
- name: ENABLE_EVENT_FORWARDING
  value: "false"
- name: ENABLE_SCHEDULED_SEARCHES
  value: "false"
{{- end }}
{{- if .Values.logscale.trustManagerConfigMap }}
- name: TLS_TRUSTSTORE_LOCATION
  value: /data/truststore/bundle.jks
{{- end }}
{{- if .Values.pdfRenderService.enabled }}
- name: DEFAULT_PDF_RENDER_SERVICE_URL
  value: http://{{ include "humio-instance.fullname" . }}-pdfrenderservice:5123
- name: ENABLE_SCHEDULED_REPORT
  value: "true"
{{- end }}
{{- end }}