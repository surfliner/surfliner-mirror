{{/*
Expand the name of the chart.
*/}}
{{- define "orange-empire.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "orange-empire.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{- define "orange-empire.minio.fullname" -}}
{{- printf "%s-%s" .Release.Name "minio" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "orange-empire.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "orange-empire.labels" -}}
helm.sh/chart: {{ include "orange-empire.chart" . }}
{{ include "orange-empire.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "orange-empire.selectorLabels" -}}
app.kubernetes.io/name: {{ include "orange-empire.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "orange-empire.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "orange-empire.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Supports using an existing secret instead of one built using the Chart
*/}}
{{- define "orange-empire.secretName" -}}
{{- if .Values.existingSecret.enabled -}}
{{- .Values.existingSecret.name -}}
{{- else -}}
{{ include "orange-empire.fullname" . }}
{{- end -}}
{{- end -}}
