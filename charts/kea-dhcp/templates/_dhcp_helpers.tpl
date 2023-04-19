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

{{- define "keadhcp.dhcp4.yaml" -}}
Dhcp4:
{{- .Values.dhcp4 | toYaml | nindent 2 }}
{{- include "keadhcp.subnet4" . | nindent 2 }}
{{- end }}

{{- define "keadhcp.dhcp4.yamlOLD" -}}
Dhcp4:
  interfaces-config:
    interfaces:
    - "*"
    dhcp-socket-type: raw
  valid-lifetime: 4000
  renew-timer: 1000
  rebind-timer: 2000
{{- include "keadhcp.subnet4" . | nindent 2 }}
  loggers:
  - name: kea-dhcp4
    severity: INFO
    output_options:
    - output: stdout
      pattern: "%D{%Y-%m-%d %H:%M:%S.%q} %-5p [%c/%i.%t] %m\n"
  control-socket:
    socket-type: unix
    socket-name: /kea/sockets/dhcp4.socket
  lease-database:
    type: memfile
    name: /kea/leases/dhcp4.csv
    lfc-interval: 3600
{{- end }}
