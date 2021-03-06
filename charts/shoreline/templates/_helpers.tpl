{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "shoreline.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "shoreline.fullname" -}}
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
{{- define "shoreline.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "shoreline.labels" -}}
app.kubernetes.io/name: {{ include "shoreline.name" . }}
helm.sh/chart: {{ include "shoreline.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "shoreline.email.fullname" -}}
{{- printf "%s-%s" .Release.Name "email" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "shoreline.geoserver.fullname" -}}
{{- printf "%s-%s" .Release.Name "geoserver" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "shoreline.postgresql.fullname" -}}
{{- if .Values.postgresql.enabled -}}
{{- printf "%s-%s" .Release.Name "database" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.postgresql.postgresqlHostname -}}
{{- end -}}
{{- end -}}

{{- define "shoreline.solr.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s-svc" .Release.Name "solr" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.solrHostname -}}
{{- end -}}
{{- end -}}

{{- define "shoreline.solr.url" -}}
{{- if .Values.solr.enabled -}}
{{- else -}}
{{- $user := .Values.solr.authentication.adminUsername -}}
{{- $pass := .Values.solr.authentication.adminPassword -}}
{{- $collection := .Values.shoreline.solr.collectionName -}}
{{- printf "http://%s:%s@%s-%s:8983/solr/%s" $user $pass .Release.Name "solr" $collection  -}}
{{- printf "http://%s:%s@%s:%s/solr/%s" $user $pass .Values.solr.solrHostname .Values.solr.solrPort "solr" $collection  -}}
{{- end -}}
{{- end -}}

{{- define "shoreline.zk.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s" .Release.Name "zookeeper" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.zookeeperHostname -}}
{{- end -}}
{{- end -}}
