{{/*
Expand the name of the chart.
*/}}
{{- define "template.name" -}}
{{- default "flink" .Release.Name | trunc 63 | trimSuffix "-" }}
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
app.kubernetes.io/instance: {{ .Release.Name }}
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
"template.ingress.annotations"
*/}}
{{- define "template.ingress.annotations" -}}
nginx.ingress.kubernetes.io/rewrite-target: /$2
alb.ingress.kubernetes.io/healthcheck-interval-seconds: "10"
alb.ingress.kubernetes.io/healthcheck-path: /
alb.ingress.kubernetes.io/healthcheck-port: "{{ .Values.service.port }}"
alb.ingress.kubernetes.io/healthcheck-protocol: HTTP
alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
alb.ingress.kubernetes.io/load-balancer-attributes: routing.http2.enabled=true
alb.ingress.kubernetes.io/scheme: internal
alb.ingress.kubernetes.io/security-groups: sg-07737ef00f09ec7aa
alb.ingress.kubernetes.io/subnets: subnet-0458177a0c65628c7,subnet-08dfbaca738dcf527,subnet-04387eeee54e10788
alb.ingress.kubernetes.io/target-group-attributes: deregistration_delay.timeout_seconds=60,stickiness.enabled=true,stickiness.lb_cookie.duration_seconds=60,deregistration_delay.timeout_seconds=60
alb.ingress.kubernetes.io/target-type: ip
alb.ingress.kubernetes.io/group.name: monitor
kubernetes.io/ingress.class: alb
{{- end }}

{{/*
"template.ingress.host"
*/}}
{{- define "template.ingress.hosts" -}}
hosts:
- host: "*"
  paths:
    - path: /{{.Release.Name}}(/|$)(.*)
      pathType: ImplementationSpecific
      backend:
          service:
            name: {{.Release.Name}}
            port:
              number: {{ .Values.service.port }}
{{- end }}

{{/*
"template.ingress.host"
*/}}
{{- define "template.flinkConfiguration.taskmanager" -}}
{{- range $key,$value := .Values.taskmanager  }}
{{- if  eq $key "numberOfTaskSlots" -}}
taskmanager.{{- $key }}: "{{default $.Values.job.parallelism $value}}"
{{- else}}
taskmanager.{{- $key }}: "{{$value}}"
{{- end}}
{{- end}}
{{- end }}

{{/*
"template.flinkVersion"
*/}}
{{- define "template.flinkVersion" -}}
{{- default "v1_16" .Values.flinkVersion -}}
{{- end }}