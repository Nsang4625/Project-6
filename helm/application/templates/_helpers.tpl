{{/*
Common labels
*/}}
{{- define "mychart.labels" -}}
app.kubernetes.io/name: {{ .Values.application.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/environment: {{ .Values.application.environment }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- if .Values.labels }}
{{- range $key, $value := .Values.labels }}
{{ $key }}: {{ $value }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "mychart.selectorLabels" -}}
app.kubernetes.io/name: {{ .Values.application.name }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "mychart.fullname" -}}
{{- printf "%s-%s" .Values.application.name .Values.application.environment | trunc 63 | trimSuffix "-" }}
{{- end }}
