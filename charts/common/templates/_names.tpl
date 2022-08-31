{{/*
Expand the name of the chart.
*/}}
{{- define "common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{/*
how do we add the specific chart name into the define statement--can it be anything other than a literal string 
does what i have above work 
*/}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "common.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "common.postgresql.fullname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- end -}}
{{- end -}}

{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "common.secretName" -}}
{{- if .Values.existingSecret.enabled -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{ include "common.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{/*
orange-empire, superskunk, orange-empire, superskunk 
*/}}
{{- define "common.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "common.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Zookeeper hostname, supporting external hostname as well
*/}}
{{/*
starlight and shoreline
*/}}
{{- define "common.zk.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.zookeeperHostname -}}
{{- end -}}
{{- end -}}

{{/*
Supports using an existing consumer secret instead of one built using the Chart
*/}}
{{/*
tidewater and shoreline
*/}}
{{- define "common.consumer.secretName" -}}
{{- if .Values.consumer.existingSecret.enabled -}}
{{- .Values.consumer.existingSecret.name -}}
{{- else -}}
{{ include "common.fullname" . }}-consumer
{{- end -}}
{{- end -}}

{{/*
orange-empire and starlight 
*/}}
{{- define "common.minio.fullname" -}}
{{- printf "%s-%s" .Release.Name "minio" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
