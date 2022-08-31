{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "starlight.name" -}}
{{ include "common.name" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "starlight.fullname" -}}
{{ include "common.fullname" . }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "starlight.chart" -}}
{{ include "common.chart" . }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "starlight.serviceAccountName" -}}
{{ include "common.serviceAccountName" . }}
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
{{ include "common.labels.second" . }}
{{- end -}}

{{- define "starlight.backups.hook" -}}
{{- if .Values.starlight.backups.import.force -}}
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
{{- define "starlight.postgresql.fullname" -}}
{{ include "common.postgresql.fullname" . }}
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
{{ include "common.secretName" . }}
{{- end -}}

{{- define "starlight.solr.cloudEnabled" -}}
{{ include "common.solr.cloudEnabled" . }}
{{- end -}}

{{- define "starlight.solr.collection_core_name" -}}
{{ include "common.solr.collection_core_name" . }}
{{- end -}}

{{/*
Solr hostname, supporting external hostname as well
*/}}
{{- define "starlight.solr.fullname" -}}
{{ include "common.solr.fullname" . }}
{{- end -}}

{{- define "starlight.solr.url" -}}
{{ include "common.solr.url" . }}
{{- end -}}

{{/*
Zookeeper hostname, supporting external hostname as well
*/}}
{{- define "starlight.zk.fullname" -}}
{{ include "common.zk.fullname" . }}
{{- end -}}
