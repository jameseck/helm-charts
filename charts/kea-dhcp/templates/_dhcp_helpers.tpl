{{- define "keadhcp.subnet4" -}}
subnet4:
{{- range $k,$v := .Values.vlans -}}
{{- if (or (not (hasKey $v "enable_dhcp")) (and (hasKey $v "enable_dhcp") ($v.enable_dhcp))) }}
- subnet: {{ $v.subnet }}/{{ $v.cidr }}
  next-server: {{ $v.next_server | default $.Values.next_server }}
{{- if $v.valid_lifetime }}
  valid-lifetime: {{ $v.valid_lifetime }}
{{- end }}
  option-data:
  - code: 3
    name: routers
    data: {{ $v.gateway }}
  - code: 6
    name: domain-name-servers
    data: {{ $v.dns }}
  - code: 15
    name: domain-name
    data: {{ $v.domain }}
  - code: 42
    name: ntp-servers
    data: {{ $v.ntp }}
  - code: 119
    name: domain-search
    data: {{ $v.domain }}
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
  client-classes:
  - name: Legacy_Intel_x86PC
    test: "option[93].hex == 0x0"
    boot-file-name: netboot.xyz.kpxe
  - name: EFI_x86-64_1
    test: "option[93].hex == 0x0007"
    boot-file-name: netboot.xyz.efi
  - name: EFI_x86-64_2
    test: "option[93].hex == 0x0009"
    boot-file-name: netboot.xyz.efi
  - name: "HTTPClient"
    test: "option[93].hex == 0x0010"
    boot-file-name: "http://{{ $v.http_server | default $.Values.http_server }}/netboot.xyz.efi"
    option-data:
    - name: vendor-class-identifier
      data: HTTPClient
  - name: XClient_iPXE
    test: "substring(option[77].hex,0,4) == 'iPXE'"
    boot-file-name: netboot.xyz.kpxe
{{- end }}
{{- end }}
{{- end }}

{{- define "keadhcp.dhcp4" -}}
Dhcp4:
{{- .Values.dhcp4 | toYaml | nindent 2 }}
{{- include "keadhcp.subnet4" . | nindent 2 }}
{{- if not (index .Values "dhcp4" "client-classes") }}
  client-classes:
  - name: Legacy_Intel_x86PC
    test: "option[93].hex == 0x0"
    boot-file-name: netboot.xyz.kpxe
  - name: EFI_x86-64_1
    test: "option[93].hex == 0x0007"
    boot-file-name: netboot.xyz.efi
  - name: EFI_x86-64_2
    test: "option[93].hex == 0x0009"
    boot-file-name: netboot.xyz.efi
  - name: "HTTPClient"
    test: "option[93].hex == 0x0010"
    boot-file-name: "http://{{ .Values.http_server }}/netboot.xyz.efi"
    option-data:
    - name: vendor-class-identifier
      data: HTTPClient
  - name: XClient_iPXE
    test: "substring(option[77].hex,0,4) == 'iPXE'"
    boot-file-name: netboot.xyz.kpxe
{{- end }}
{{- end }}
