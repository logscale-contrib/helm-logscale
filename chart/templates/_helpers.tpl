{{/*
Expand the name of the chart.
*/}}
{{- define "humio-instance.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "humio-instance.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "humio-instance.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "humio-instance.labels" -}}
helm.sh/chart: {{ include "humio-instance.chart" . }}
{{ include "humio-instance.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "humio-instance.selectorLabels" -}}
app.kubernetes.io/name: {{ include "humio-instance.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "humio-instance.humio.serviceAccountName" -}}
{{- if .Values.humio.serviceAccount.create }}
{{- default (include "humio-instance.fullname" .) .Values.humio.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.humio.serviceAccount.name }}
{{- end }}
{{- end }}



{{/*
Create the zookeeper service
*/}}
{{- define "humio-instance.externalService.zookeeper" -}}
{{- default (printf "%s-%s" .Release.Name "zookeeper-headless:2181") .Values.humio.externalzookeeperHostname }}
{{- end }}

{{/*
Create the kafka service
*/}}
{{- define "humio-instance.externalService.kafka" -}}
{{- default (printf "%s-%s" .Release.Name "kafka-kafkacluster-kafka-bootstrap:9092") .Values.humio.kafka.externalKafkaHostname }}
{{- end }}

{{- define "humio-instance.persistance.storageclass" -}}
{{- if eq .Values.platform.provider "azure" }}
{{- printf "managed-csi-premium" }}
{{- else if eq .Values.platform.provider "aws" }}
{{- printf "gp3" }}
{{- else }}
{{- printf "default" }}
{{- end }}
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "otel.serviceAccountName" -}}
{{- if .Values.otel.serviceAccount.create }}
{{- default (include "otel.fullname" .) .Values.otel.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.otel.serviceAccount.name }}
{{- end }}
{{- end }}