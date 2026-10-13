#!/usr/bin/env bash
# Aperion Robotics - source dependencies for the ROS CI workflows.
#
# Usage:
#   source-deps.sh resolve <manifest> <allowlist>
#       Print the aperion-robotics repositories referenced by <manifest> as a
#       comma-separated list. Fail if any of them is missing from <allowlist>,
#       so a pull request cannot widen the scope of the dependency token.
#
#   source-deps.sh import <manifest> <destination> [local-repos-file]
#       Import <manifest> into <destination> with vcstool. APERION_CI_TOKEN,
#       when set, authenticates github.com over HTTPS and SSH URLs. With
#       [local-repos-file], also write a .repos file pointing at the local
#       clones (file://), so later steps can use them without any token.

set -euo pipefail

resolve() {
  local manifest=$1 allowlist=$2
  local referenced allowed repo rc=0
  local -a accepted=()

  # Drop YAML comments first: '#' at line start or after whitespace. A '#'
  # elsewhere (e.g. in a key or a branch name) is data and must be kept.
  referenced=$(sed -E 's/(^|[[:space:]])#.*//' "$manifest" \
    | grep -ioE 'github\.com[:/]+aperion-robotics/[A-Za-z0-9._-]+' \
    | sed -E 's#.*/##; s/\.git$//' | sort -fu || true)
  allowed=$(sed -E 's/#.*//; s/[[:space:]]//g' "$allowlist" | grep -v '^$' || true)

  while IFS= read -r repo; do
    [[ -z "$repo" ]] && continue
    if grep -qixF -- "$repo" <<<"$allowed"; then
      accepted+=("$repo")
    else
      echo "::error file=${manifest}::aperion-robotics/${repo} is not an allowed source dependency." \
        "Add it to ci/source-deps/allowed-repositories.txt in aperion-robotics/.github." >&2
      rc=1
    fi
  done <<<"$referenced"

  [[ $rc -eq 0 ]] || return 1
  (IFS=,; echo "${accepted[*]}")
}

import_deps() {
  local manifest=$1 dest=$2 local_repos=${3:-}
  local vcs=vcs https_base

  if ! command -v vcs >/dev/null 2>&1; then
    # vcstool 0.3.0 (latest) imports pkg_resources, which setuptools removed
    # in 82.0.0; Python >= 3.12 venvs no longer ship setuptools at all.
    python3 -m venv "${RUNNER_TEMP:?}/vcstool-venv"
    "${RUNNER_TEMP}/vcstool-venv/bin/pip" install \
      --disable-pip-version-check --quiet vcstool==0.3.0 "setuptools<82"
    vcs="${RUNNER_TEMP}/vcstool-venv/bin/vcs"
  fi

  # Private HOME for git, removed on exit, so the token never lands in the
  # real ~/.gitconfig and never reaches later steps. GIT_CONFIG_GLOBAL is not
  # used because git < 2.32 (Bionic, Focal) silently ignores it. git_home is
  # global because the EXIT trap runs after this function has returned.
  git_home=$(mktemp -d "${RUNNER_TEMP:-/tmp}/aperion-git-home.XXXXXX")
  trap 'rm -rf "$git_home"' EXIT
  export HOME="$git_home" XDG_CONFIG_HOME="$git_home/.config" GIT_TERMINAL_PROMPT=0
  unset GIT_CONFIG_GLOBAL

  https_base="https://github.com/"
  if [[ -n "${APERION_CI_TOKEN:-}" ]]; then
    https_base="https://x-access-token:${APERION_CI_TOKEN}@github.com/"
    git config --global --add url."${https_base}".insteadOf "https://github.com/"
  fi
  # CI has no SSH key: fetch SSH URLs over HTTPS.
  git config --global --add url."${https_base}".insteadOf "git@github.com:"
  git config --global --add url."${https_base}".insteadOf "ssh://git@github.com/"

  mkdir -p "$dest"
  "$vcs" import --input "$manifest" "$dest"

  if [[ -n "$local_repos" ]]; then
    local gitdir path
    {
      echo "repositories:"
      while IFS= read -r gitdir; do
        path=$(cd "$(dirname "$gitdir")" && pwd)
        printf "  '%s':\n    type: git\n    url: 'file://%s'\n    version: '%s'\n" \
          "${path#"$(cd "$dest" && pwd)"/}" "$path" "$(git -C "$path" rev-parse HEAD)"
      done < <(find "$dest" -name .git -prune -print | sort)
    } >"$local_repos"
  fi
}

case "${1:-}" in
  resolve) shift; resolve "$@" ;;
  import) shift; import_deps "$@" ;;
  *) echo "usage: $0 resolve <manifest> <allowlist> | import <manifest> <dest> [local-repos-file]" >&2; exit 2 ;;
esac
