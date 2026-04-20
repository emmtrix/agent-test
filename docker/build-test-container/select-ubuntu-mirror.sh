#!/usr/bin/env bash
set -euo pipefail

mirrors="
  http://mirrors.usinternet.com/ubuntu/archive/
  http://mirrors.us.kernel.org/ubuntu/
  http://ftp.utexas.edu/ubuntu/
  http://mirror.cc.columbia.edu/pub/linux/ubuntu/archive/
  http://archive.ubuntu.com/ubuntu/
"

probe_mirror() {
  local mirror="$1"
  local rest="${mirror#http://}"
  local host="${rest%%/*}"
  local path="/${rest#${host}/}dists/noble/InRelease"
  local start_ns end_ns

  start_ns="$(date +%s%N)"
  if timeout 20 bash -lc '
      exec 3<>"/dev/tcp/$1/80"
      printf "HEAD %s HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n" "$2" "$1" >&3
      IFS= read -r line <&3
      [[ "$line" == HTTP/*" 200 "* ]]
    ' _ "$host" "$path" >/dev/null 2>&1; then
    end_ns="$(date +%s%N)"
    printf '%s %s\n' "$(((end_ns - start_ns) / 1000000))" "$mirror"
  fi
}

best_mirror="$(
  for mirror in $mirrors; do
    probe_mirror "$mirror"
  done | sort -n | head -n1 | cut -d' ' -f2-
)"

if [ -z "$best_mirror" ]; then
  best_mirror='http://archive.ubuntu.com/ubuntu/'
fi

sed -i \
  "s|http://archive.ubuntu.com/ubuntu/|$best_mirror|g; s|http://security.ubuntu.com/ubuntu/|$best_mirror|g" \
  /etc/apt/sources.list.d/ubuntu.sources

printf 'Selected Ubuntu mirror: %s\n' "$best_mirror"
