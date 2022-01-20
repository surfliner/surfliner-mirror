{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "tidewater.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tidewater.fullname" -}}
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
{{- define "tidewater.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the Sitemap Host URL, as Minio and other s3-compatible providers use endpoint urls.
*/}}
{{- define "tidewater.sitemaps.host" -}}
{{- $endpoint := .Values.tidewater.storage.endpointUrl -}}
{{- $bucket := .Values.tidewater.storage.bucket -}}
{{- $region := .Values.tidewater.storage.region -}}

{{- if $endpoint }}
{{- printf "%s/%s/" $endpoint $bucket -}}
{{- else }}
{{- printf "https://s3-%s.amazonaws.com/%s/" $region $bucket -}}
{{- end }}

{{- end -}}

{{/*
Common labels
*/}}
{{- define "tidewater.labels" -}}
app.kubernetes.io/name: {{ include "tidewater.name" . }}
helm.sh/chart: {{ include "tidewater.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "tidewater.backups.hook" -}}
{{- if .Values.tidewater.backups.import.force -}}
post-upgrade
{{- else -}}
post-install
{{- end -}}
{{- end -}}

{{/*
Services
*/}}
{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
Alternatively, if postgresqlHostname is set, we use that which allows for an external database
*/}}
{{- define "tidewater.postgresql.fullname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- end -}}
{{- end -}}

{{- define "tidewater.memcached.fullname" -}}
{{- printf "%s-%s" .Release.Name "memcached" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tidewater.minio.fullname" -}}
{{- printf "%s-%s" .Release.Name "minio" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "tidewater.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "tidewater.secretName" -}}
{{- if .Values.existingSecret.enabled -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{ include "tidewater.fullname" . }}
{{- end -}}
{{- end -}}

{{- define "tidewater.solr.cloudEnabled" -}}
{{- if .Values.solr.enabled -}}
{{- .Values.solr.cloudEnabled }}
{{- else -}}
{{- (eq "cloud" (lower .Values.tidewater.solrRunMode)) }}
{{- end -}}
{{- end -}}

{{- define "tidewater.solr.collection_core_name" -}}
{{- if eq (include "tidewater.solr.cloudEnabled" .) "true" -}}
{{- .Values.solr.collection -}}
{{- else -}}
{{- .Values.solr.coreName -}}
{{- end -}}
{{- end -}}

{{/*
Solr hostname, supporting external hostname as well
*/}}
{{- define "tidewater.solr.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s" .Release.Name "solr" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.solrHostname -}}
{{- end -}}
{{- end -}}

{{- define "tidewater.solr.url" -}}
{{- $collection_core := (include "tidewater.solr.collection_core_name" .) -}}
{{- $host := (include "tidewater.solr.fullname" .) -}}
{{- $port := .Values.solr.solrPort | default "8983" -}}
{{- if .Values.solr.authentication.enabled -}}
{{- $user := .Values.solr.authentication.adminUsername -}}
{{- $pass := .Values.solr.authentication.adminPassword -}}
{{- printf "http://%s:%s@%s:%s/solr/%s" $user $pass $host $port $collection_core -}}
{{- else -}}
{{- printf "http://%s:%s/solr/%s" $host $port $collection_core -}}
{{- end -}}
{{- end -}}

{{/*
Zookeeper hostname, supporting external hostname as well
*/}}
{{- define "tidewater.zk.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.zookeeperHostname -}}
{{- end -}}
{{- end -}}
