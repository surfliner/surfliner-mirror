{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "geoserver.name" -}}
{{ include "common.name" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "geoserver.fullname" -}}
{{ include "common.fullname" . }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "geoserver.chart" -}}
{{ include "common.chart" . }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "geoserver.labels" -}}
{{ include "common.labels.first" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "geoserver.selectorLabels" -}}
{{ include "common.selectorLabels" . }}
{{- end }}
