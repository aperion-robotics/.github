#!/usr/bin/env bash
# Aperion Robotics - repository CI options.
#
# Usage:
#   load-ci-options.sh <file> <KEY>...
#
# Export KEY=VALUE lines of <file> (blank lines and # comments allowed) to
# $GITHUB_ENV. Only the listed KEYs are accepted. Values are limited to a
# conservative character set, so a pull request cannot inject shell syntax
# into the CI tooling that runs on the runner host. A missing file is fine.

set -euo pipefail

file=$1
shift
allowed=" $* "

if [[ ! -f "$file" ]]; then
  echo "No ${file}; using the organization defaults."
  exit 0
fi

rc=0
lineno=0
while IFS= read -r line || [[ -n "$line" ]]; do
  lineno=$((lineno + 1))
  line=${line%%#*}
  line=${line#"${line%%[![:space:]]*}"}
  line=${line%"${line##*[![:space:]]}"}
  [[ -z "$line" ]] && continue

  if [[ ! "$line" =~ ^([A-Z][A-Z0-9_]*)=(.*)$ ]]; then
    echo "::error file=${file},line=${lineno}::expected KEY=VALUE"
    rc=1
    continue
  fi
  key=${BASH_REMATCH[1]}
  value=${BASH_REMATCH[2]}

  if [[ "$allowed" != *" ${key} "* ]]; then
    echo "::error file=${file},line=${lineno}::${key} is not supported here. Supported:${allowed% }"
    rc=1
  elif [[ ! "$value" =~ ^[A-Za-z0-9\ _.,:=/+*@-]*$ ]]; then
    echo "::error file=${file},line=${lineno}::${key} contains unsupported characters (no quotes, \$, ;, |, & or backticks)"
    rc=1
  else
    echo "${key}=${value}"
    echo "${key}=${value}" >>"${GITHUB_ENV:?}"
  fi
done <"$file"

exit "$rc"
