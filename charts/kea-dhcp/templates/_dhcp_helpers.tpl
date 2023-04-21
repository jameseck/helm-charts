{{- define "keadhcp.subnet4" -}}
subnet4:
{{- range $k,$v := .Values.vlans -}}
{{- if (or (not (hasKey $v "enable_dhcp")) (and (hasKey $v "enable_dhcp") ($v.enable_dhcp))) }}
- subnet: {{ $v.subnet }}/{{ $v.cidr }}
  pools:
  - pool: {{ $v.range_begin }}-{{ $v.range_end }}
  reservations:
  {{- range $host := $v.hosts }}
  {{- if $host.mac }}
  - hostname: {{ $host.name }}
    hw-address: {{ $host.mac }}
    ip-address: {{ $host.ip }}
  {{- end }}
  {{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "keadhcp.dhcp4" -}}
Dhcp4:
{{- .Values.dhcp4 | toYaml | nindent 2 }}
{{- include "keadhcp.subnet4" . | nindent 2 }}
{{- end }}
