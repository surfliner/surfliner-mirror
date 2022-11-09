{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "shoreline.name" -}}
{{ include "common.name" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "shoreline.fullname" -}}
{{ include "common.fullname" . }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "shoreline.chart" -}}
{{ include "common.chart" . }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "shoreline.labels" -}}
{{ include "common.labels.second" . }}
{{- end -}}

{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "shoreline.secretName" -}}
{{ include "common.secretName" . }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "shoreline.serviceAccountName" -}}
{{ include "common.serviceAccountName" . }}
{{- end -}}

{{- define "shoreline.email.fullname" -}}
{{- printf "%s-%s" .Release.Name "email" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "shoreline.geoserver.hostname" -}}
{{- if .Values.geoserver.enabled -}}
{{- .Values.geoserver.ingress.hosts | first -}}
{{- else -}}
{{- .Values.geoserver.geoserverHostname -}}
{{- end -}}
{{- end -}}

{{- define "shoreline.geoserver.port" -}}
{{- if (and .Values.geoserver.enabled .Values.geoserver.ingress.tls) -}}
{{- "443" -}}
{{- else -}}
{{- .Values.geoserver.service.port | default "80" -}}
{{- end -}}
{{- end -}}

{{- define "shoreline.geoserver.scheme" -}}
{{- if .Values.geoserver.enabled -}}
{{- if .Values.geoserver.ingress.tls -}}
{{- "https" -}}
{{- else -}}
{{- "http" -}}
{{- end -}}
{{- else -}}
{{- .Values.geoserver.geoserverScheme | default "http" -}}
{{- end -}}
{{- end -}}

{{- define "shoreline.geoserver.url" -}}
{{- $scheme := ( include "shoreline.geoserver.scheme" .) -}}
{{- $hostname := ( include "shoreline.geoserver.hostname" .) -}}
{{- $port := ( include "shoreline.geoserver.port" .) -}}
{{- printf "%s://%s:%s" $scheme $hostname $port -}}
{{- end -}}

{{- define "shoreline.postgresql.fullname" -}}
{{ include "common.postgresql.fullname" . }}
{{- end -}}

{{- define "shoreline.solr.cloudEnabled" -}}
{{ include "common.solr.cloudEnabled" . }}
{{- end -}}

{{- define "shoreline.solr.fullname" -}}
{{ include "common.solr.fullname" . }}
{{- end -}}

{{- define "shoreline.solr.collection_core_name" -}}
{{ include "common.solr.collection_core_name" . }}
{{- end -}}

{{- define "shoreline.solr.url" -}}
{{ include "common.solr.url" . }}
{{- end -}}

{{- define "shoreline.zk.fullname" -}}
{{ include "common.zk.fullname" . }}
{{- end -}}

{{/*
Supports using an existing consumer secret instead of one built using the Chart
*/}}
{{- define "shoreline.consumer.secretName" -}}
{{ include "common.consumer.secretName" . }}
{{- end -}}
