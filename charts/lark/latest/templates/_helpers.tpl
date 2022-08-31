{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "lark.name" -}}
{{ include "common.name" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lark.fullname" -}}
{{ include "common.fullname" . }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "lark.chart" -}}
{{ include "common.chart" . }}
{{- end -}}

{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "lark.postgresql.fullname" -}}
{{ include "common.postgresql.fullname" . }}
{{- end -}}

{{- define "lark.solr.fullname" -}}
{{ include "common.solr.fullname" . }}
{{- end -}}

{{- define "lark.zk.fullname" -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- end -}}
