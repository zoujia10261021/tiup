#!/bin/bash
set -e

# WARNING: This file was auto-generated. Do not edit!
#          All your edit might be overwritten!
DEPLOY_DIR={{.DeployDir}}

cd "${DEPLOY_DIR}" || exit 1

{{- define "PDList"}}
  {{- range $idx, $pd := .}}
    {{- if eq $idx 0}}
      {{- $pd.IP}}:{{$pd.ClientPort}}
    {{- else -}}
      ,{{$pd.IP}}:{{$pd.ClientPort}}
    {{- end}}
  {{- end}}
{{- end}}

{{- if .NumaNode}}
exec numactl --cpunodebind={{.NumaNode}} --membind={{.NumaNode}} env GODEBUG=madvdontneed=1 bin/he3db-server \
{{- else}}
exec env GODEBUG=madvdontneed=1 bin/he3db-server \
{{- end}}
    -P {{.Port}} \
    --status="{{.StatusPort}}" \
    --host="{{.ListenHost}}" \
    --advertise-address="{{.IP}}" \
    --store="tikv" \
    --path="{{template "PDList" .Endpoints}}" \
    --log-slow-query="log/he3db_slow_query.log" \
    --config=conf/he3db.toml \
    --log-file="{{.LogDir}}/he3db.log" 2>> "{{.LogDir}}/he3db_stderr.log"
