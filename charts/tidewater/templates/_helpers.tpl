{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "tidewater.name" -}}
{{ include "common.name" . }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tidewater.fullname" -}}
{{ include "common.fullname" . }}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tidewater.chart" -}}
{{ include "common.chart" . }}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "tidewater.labels" -}}
{{ include "common.labels.second" . }}
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
{{ include "common.postgresql.fullname" . }}
{{- end -}}

{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "tidewater.secretName" -}}
{{ include "common.secretName" . }}
{{- end -}}

{{/*
Supports using an existing consumer secret instead of one built using the Chart
*/}}
{{- define "tidewater.consumer.secretName" -}}
{{ include "common.consumer.secretName" . }}
{{- end -}}

{{/*
Should include a unique item namespace, which can be provided directly via
Values or derived from the ingress hosts (default)
*/}}
{{- define "tidewater.oai.namespaceIdentifier" -}}
{{- default (index .Values.ingress.hosts 0) .Values.oai.namespaceIdentifier -}}
{{- end -}}
