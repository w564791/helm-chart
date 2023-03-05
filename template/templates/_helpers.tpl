{{/*
Expand the name of the chart.
*/}}
{{- define "template.name" -}}
{{- default .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
    expand the name of container
*/}}



{{- define "template.containerName" -}}
{{- default .Release.Name .Values.containerNameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "template.fullname" -}}
{{- if .Release.Name  }}
{{- .Release.Name  | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Release.Name  }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "template.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "template.labels" -}}
helm.sh/chart: {{ include "template.chart" . }}
{{ include "template.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "template.selectorLabels" -}}
app.kubernetes.io/name: {{ include "template.name" . }}
app.kubernetes.io/instance: {{ include "template.name" . }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "template.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "template.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
{{/*
 pod  affinity
*/}}

{{- define "template.affinity" -}}
{{- if .Values.podAffinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution.enabled -}}
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
  {{ range .Values.podAffinity.podAntiAffinity.preferredDuringSchedulingIgnoredDuringExecution.podAffinityTerms}}
  - podAffinityTerm:
      labelSelector:
        matchExpressions:
        - key: {{.key}}
          operator: {{.operator}}
          values:
          - {{ $.Values.fullnameOverride -}}
          {{ range .exAffinityApps}}
          - {{ . -}}
          {{end}}
      topologyKey: kubernetes.io/hostname
    weight: 1
{{- end }}
{{- end }}
{{- end }}