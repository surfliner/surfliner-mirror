{{/*
Expand the name of the chart.
*/}}
{{- define "superskunk.name" -}}
{{ include "common.name" . }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "superskunk.fullname" -}}
{{ include "common.fullname" . }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "superskunk.chart" -}}
{{ include "common.chart" . }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "superskunk.labels" -}}
{{ include "common.labels.first" . }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "superskunk.selectorLabels" -}}
{{ include "common.selectorLabels" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "superskunk.serviceAccountName" -}}
{{ include "common.serviceAccountName" . }}
{{- end }}

{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "superskunk.secretName" -}}
{{ include "common.secretName" . }}
{{- end -}}

{{/*
Services
*/}}
{{/*
Create a default fully qualified postgresql name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
Alternatively, if postgresqlHostname is set, we use that which allows for an external database
*/}}
{{- define "superskunk.postgresql.fullname" -}}
{{- if .Values.superskunk.db.standalone -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- else -}}
{{ include "common.postgresql.fullname" . }}
{{- end -}}
{{- end -}}

{{/*
Set the appropriate database name based on using standalone or external Comet database
*/}}
{{- define "superskunk.postgresql.database" -}}
{{- if .Values.superskunk.db.standalone -}}
{{- .Values.postgresql.auth.database -}}
{{- else -}}
{{- .Values.superskunk.db.metadata_database_name -}}
{{- end -}}
{{- end -}}
