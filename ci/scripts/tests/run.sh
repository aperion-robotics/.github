#!/usr/bin/env bash
# Tests for ci/scripts. Run from anywhere: ci/scripts/tests/run.sh
# Needs git, python3 and either vcs or python3-venv (vcstool is installed on demand).

set -euo pipefail
exit 1

SCRIPTS=$(cd "$(dirname "$0")/.." && pwd)
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
export RUNNER_TEMP="$WORK/runner-temp"
mkdir -p "$RUNNER_TEMP"
failures=0

pass() { echo "ok   - $1"; }
fail() { echo "FAIL - $1"; failures=$((failures + 1)); }
expect_eq() { if [[ "$2" == "$3" ]]; then pass "$1"; else fail "$1: expected [$3], got [$2]"; fi; }

# --- source-deps.sh resolve ---------------------------------------------------
cat >"$WORK/allow.txt" <<'EOF'
# comment
shared_msgs
Aristos_Common   # trailing comment
EOF

cat >"$WORK/ok.repos" <<'EOF'
repositories:
  a: {type: git, url: https://github.com/aperion-robotics/shared_msgs.git, version: main}
  b: {type: git, url: git@github.com:aperion-robotics/aristos_common.git, version: main}
  c: {type: git, url: https://github.com/ros/ros_comm.git, version: melodic-devel}
EOF
expect_eq "resolve: allowed https and ssh URLs" \
  "$("$SCRIPTS/source-deps.sh" resolve "$WORK/ok.repos" "$WORK/allow.txt")" "aristos_common,shared_msgs"

cat >"$WORK/public.repos" <<'EOF'
repositories:
  c: {type: git, url: https://github.com/ros/ros_comm.git, version: melodic-devel}
EOF
expect_eq "resolve: no aperion repositories" \
  "$("$SCRIPTS/source-deps.sh" resolve "$WORK/public.repos" "$WORK/allow.txt")" ""

cat >"$WORK/comments.repos" <<'EOF'
# Formerly github.com/aperion-robotics/old_repo
repositories:
  a: {type: git, url: https://github.com/aperion-robotics/shared_msgs.git, version: fix#12}  # see github.com/aperion-robotics/other
  "tools#legacy": {type: git, url: https://github.com/aperion-robotics/aristos_common.git, version: main}
EOF
expect_eq "resolve: ignores YAML comments, keeps '#' inside keys and values" \
  "$("$SCRIPTS/source-deps.sh" resolve "$WORK/comments.repos" "$WORK/allow.txt")" "aristos_common,shared_msgs"

cat >"$WORK/bad.repos" <<'EOF'
repositories:
  a: {type: git, url: https://github.com/aperion-robotics/shared_msgs.git, version: main}
  x: {type: git, url: https://github.com/Aperion-Robotics/secret_repo, version: main}
EOF
if "$SCRIPTS/source-deps.sh" resolve "$WORK/bad.repos" "$WORK/allow.txt" >/dev/null 2>"$WORK/err"; then
  fail "resolve: rejects repositories missing from the allowlist"
elif grep -q 'secret_repo is not an allowed' "$WORK/err"; then
  pass "resolve: rejects repositories missing from the allowlist"
else
  fail "resolve: unexpected error output: $(cat "$WORK/err")"
fi

# --- source-deps.sh import (offline, file:// remotes) -------------------------
git init -q "$WORK/remote/dep_pkg"
git -C "$WORK/remote/dep_pkg" -c user.name=ci -c user.email=ci@example.com \
  commit -q --allow-empty -m "feat: initial"
sha=$(git -C "$WORK/remote/dep_pkg" rev-parse HEAD)
cat >"$WORK/local.repos" <<EOF
repositories:
  nested/dep_pkg: {type: git, url: 'file://$WORK/remote/dep_pkg', version: $sha}
EOF
"$SCRIPTS/source-deps.sh" import "$WORK/local.repos" "$WORK/deps" "$WORK/out.repos" >/dev/null
expect_eq "import: dependency checked out" "$(git -C "$WORK/deps/nested/dep_pkg" rev-parse HEAD)" "$sha"
expect_eq "import: local repos file points at the clone" \
  "$(grep -c "file://$WORK/deps/nested/dep_pkg" "$WORK/out.repos")" "1"
if ls -d "$RUNNER_TEMP"/aperion-git-home.* >/dev/null 2>&1; then
  fail "import: temporary git home removed"
else
  pass "import: temporary git home removed"
fi

# The token must reach git, but never the caller's global git configuration.
real_home=$HOME
export HOME="$WORK/caller-home"
mkdir -p "$HOME"
cat >"$WORK/fake-git" <<'EOF'
#!/usr/bin/env bash
if [[ "${1:-}" == "clone" ]]; then
  cat "$HOME/.gitconfig" >"$CAPTURE"
fi
exec "$REAL_GIT" "$@"
EOF
chmod +x "$WORK/fake-git"
mkdir -p "$WORK/fakebin"
ln -sf "$WORK/fake-git" "$WORK/fakebin/git"
CAPTURE="$WORK/seen-gitconfig" REAL_GIT=$(command -v git) PATH="$WORK/fakebin:$PATH" \
  APERION_CI_TOKEN=test-token \
  "$SCRIPTS/source-deps.sh" import "$WORK/local.repos" "$WORK/deps-token" >/dev/null
expect_eq "import: token used for github.com" \
  "$(grep -c 'x-access-token:test-token@github.com' "$WORK/seen-gitconfig")" "1"
if grep -rqs 'test-token' "$HOME"; then
  fail "import: token kept out of the caller's HOME"
else
  pass "import: token kept out of the caller's HOME"
fi
export HOME=$real_home

vcs_bin=$(command -v vcs || echo "$RUNNER_TEMP/vcstool-venv/bin/vcs")
mkdir -p "$WORK/reimport"
"$vcs_bin" import --input "$WORK/out.repos" "$WORK/reimport" >/dev/null
expect_eq "import: local repos file is importable without a token" \
  "$(git -C "$WORK/reimport/nested/dep_pkg" rev-parse HEAD)" "$sha"

# --- load-ci-options.sh -------------------------------------------------------
export GITHUB_ENV="$WORK/github_env"
: >"$GITHUB_ENV"
cat >"$WORK/good.env" <<'EOF'
# Bionic has no rosdep key for these
ROSDEP_SKIP_KEYS=libgeographic-dev python2-paho-mqtt
ADDITIONAL_DEBS=libgeographic-dev
CLANG_TIDY_ARGS=-checks=-*,bugprone-*
EOF
"$SCRIPTS/load-ci-options.sh" "$WORK/good.env" ROSDEP_SKIP_KEYS ADDITIONAL_DEBS CLANG_TIDY_ARGS >/dev/null
expect_eq "options: accepted lines exported" "$(wc -l <"$GITHUB_ENV" | tr -d ' ')" "3"
expect_eq "options: value kept verbatim" "$(sed -n 3p "$GITHUB_ENV")" "CLANG_TIDY_ARGS=-checks=-*,bugprone-*"

# shellcheck disable=SC2016 # the literal $(...) is the injection attempt under test
for bad in 'AFTER_INIT=./evil.sh' 'CMAKE_ARGS=$(curl evil)' 'ROSDEP_SKIP_KEYS=a;b' 'lowercase=1' 'NOEQUALS'; do
  : >"$GITHUB_ENV"
  printf '%s\n' "$bad" >"$WORK/bad.env"
  if "$SCRIPTS/load-ci-options.sh" "$WORK/bad.env" ROSDEP_SKIP_KEYS CMAKE_ARGS >/dev/null; then
    fail "options: rejects [$bad]"
  elif [[ -s "$GITHUB_ENV" ]]; then
    fail "options: [$bad] leaked into GITHUB_ENV"
  else
    pass "options: rejects [$bad]"
  fi
done

: >"$GITHUB_ENV"
"$SCRIPTS/load-ci-options.sh" "$WORK/missing.env" ROSDEP_SKIP_KEYS >/dev/null
expect_eq "options: missing file is fine" "$(wc -c <"$GITHUB_ENV" | tr -d ' ')" "0"

# --- list-packages.py ---------------------------------------------------------
mkdir -p "$WORK/repo/pkg_a" "$WORK/repo/group/pkg_b/nested" "$WORK/repo/ignored/pkg_c" \
  "$WORK/repo/.aperion-upstream/dep" "$WORK/repo/ros_ws/src/copy"
for p in pkg_a group/pkg_b group/pkg_b/nested ignored/pkg_c .aperion-upstream/dep ros_ws/src/copy; do
  printf '<package format="3">\n  <name> %s </name>\n</package>\n' "$(basename "$p")" >"$WORK/repo/$p/package.xml"
done
touch "$WORK/repo/ignored/COLCON_IGNORE"
expect_eq "list-packages: repository packages only" \
  "$(python3 "$SCRIPTS/list-packages.py" "$WORK/repo")" "pkg_a pkg_b"

echo
if [[ $failures -ne 0 ]]; then
  echo "$failures test(s) failed"
  exit 1
fi
echo "all tests passed"
