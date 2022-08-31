{{/*
Expand the name of the chart.
*/}}
{{- define "orange-empire.name" -}}
{{ include "common.name" . }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "orange-empire.fullname" -}}
{{ include "common.fullname" . }}
{{- end }}

{{- define "orange-empire.minio.fullname" -}}
{{ include "common.minio.fullname" . }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "orange-empire.chart" -}}
{{ include "common.chart" . }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "orange-empire.labels" -}}
{{ include "common.labels.first" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "orange-empire.selectorLabels" -}}
{{ include "common.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "orange-empire.serviceAccountName" -}}
{{ include "common.serviceAccountName" . }}
{{- end }}

{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "orange-empire.secretName" -}}
{{ include "common.secretName" . }}
{{- end -}}
