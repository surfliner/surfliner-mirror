{{/*
starlight and shoreline
*/}}
{{- define "common.solr.cloudEnabled" -}}
{{- if .Values.solr.enabled -}}
{{- .Values.solr.cloudEnabled }}
{{- else -}}
{{- (eq "cloud" (lower .Values.starlight.solrRunMode)) }}
{{- end -}}
{{- end -}}

{{/*
starlight and shoreline
*/}}
{{- define "common.solr.collection_core_name" -}}
{{- if eq (include "common.solr.cloudEnabled" .) "true" -}}
{{- .Values.solr.collection -}}
{{- else -}}
{{- .Values.solr.coreName -}}
{{- end -}}
{{- end -}}

{{/*
Solr hostname, supporting external hostname as well
*/}}
{{/*
starlight and shoreline
*/}}
{{- define "common.solr.fullname" -}}
{{- if .Values.solr.enabled -}}
{{- printf "%s-%s" .Release.Name "solr" | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- .Values.solr.solrHostname -}}
{{- end -}}
{{- end -}}

{{/*
starlight and shoreline
*/}}
{{- define "common.solr.url" -}}
{{- $collection_core := (include "common.solr.collection_core_name" .) -}}
{{- $host := (include "common.solr.fullname" .) -}}
{{- $port := .Values.solr.solrPort | default "8983" -}}
{{- if .Values.solr.auth.enabled -}}
{{- $user := .Values.solr.auth.adminUsername -}}
{{- $pass := .Values.solr.auth.adminPassword -}}
{{- printf "http://%s:%s@%s:%s/solr/%s" $user $pass $host $port $collection_core -}}
{{- else -}}
{{- printf "http://%s:%s/solr/%s" $host $port $collection_core -}}
{{- end -}}
{{- end -}}