{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "starlight.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "starlight.fullname" -}}
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
{{- define "starlight.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create the Sitemap Host URL, as Minio and other s3-compatible providers use endpoint urls.
*/}}
{{- define "starlight.sitemaps.host" -}}
{{- $endpoint := .Values.starlight.storage.endpointUrl -}}
{{- $bucket := .Values.starlight.storage.bucket -}}
{{- $region := .Values.starlight.storage.region -}}

{{- if $endpoint }}
{{- printf "%s/%s/" $endpoint $bucket -}}
{{- else }}
{{- printf "https://s3-%s.amazonaws.com/%s/" $region $bucket -}}
{{- end }}

{{- end -}}

{{/*
Common labels
*/}}
{{- define "starlight.labels" -}}
app.kubernetes.io/name: {{ include "starlight.name" . }}
helm.sh/chart: {{ include "starlight.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}


{{/*
Services
*/}}
{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
Alternatively, if postgresqlHostname is set, we use that which allows for an external database
*/}}
{{- define "starlight.postgresql.fullname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "postgresql" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- end -}}
{{- end -}}

{{- define "starlight.memcached.fullname" -}}
{{- printf "%s-%s" .Release.Name "memcached" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "starlight.minio.fullname" -}}
{{- printf "%s-%s" .Release.Name "minio" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "starlight.redis.fullname" -}}
{{- printf "%s-%s" .Release.Name "redis" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "starlight.secretName" -}}
{{- if .Values.existingSecret.enabled -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{ include "starlight.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Solr hostname, supporting external hostname as well
*/}}
{{- define "starlight.solr.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s" .Release.Name "solr" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.solrHostname -}}
{{- end -}}
{{- end -}}

{{/*
Solr URL, which requires authentication is enabled
*/}}
{{- define "starlight.solr.url" -}}
{{- $user := .Values.solr.authentication.adminUsername -}}
{{- $pass := .Values.solr.authentication.adminPassword -}}
{{- $collection := .Values.solr.collection -}}
{{- $host := (include "starlight.solr.fullname" .) -}}
{{- $port := "8983" -}}
{{- printf "http://%s:%s@%s:%s/solr/%s" $user $pass $host $port $collection  -}}
{{- end -}}

{{/*
Zookeeper hostname, supporting external hostname as well
*/}}
{{- define "starlight.zk.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.zookeeperHostname -}}
{{- end -}}
{{- end -}}
