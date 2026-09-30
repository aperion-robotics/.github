# Local Pre-commit Checks

Aperion Robotics uses `pre-commit` for fast local repository-hygiene checks.

The purpose is to catch inexpensive problems before code reaches review or GitHub CI.

GitHub CI remains authoritative.

---

## What the Aperion baseline checks

The organization baseline currently checks for:

- accidentally added large files
- filename case conflicts
- merge-conflict markers
- broken symlinks
- invalid YAML
- invalid JSON
- invalid TOML
- invalid XML
- accidentally committed private keys
- missing final newlines
- mixed line endings
- trailing whitespace

The generic baseline intentionally does **not** enforce ROS-specific C++ or Python formatting.

ROS-specific formatting, linting, build, and test checks belong to the corresponding ROS environment and CI workflow.

---

## Why `pre-commit`

`pre-commit` manages hook environments independently from the developer's project environment.

This is useful for Aperion repositories because the same organization contains:

- ROS 1 Melodic
- ROS 1 Noetic
- ROS 2 Jazzy
- infrastructure and non-ROS repositories

The fast repository-hygiene layer can therefore remain independent from the ROS runtime and Python version used by the project itself.

---

## Install `pipx`

On Ubuntu 23.04 and newer, including Ubuntu 24.04:

```bash
sudo apt update
sudo apt install -y pipx

pipx ensurepath
```

Restart the shell if `~/.local/bin` is not yet available on `PATH`.

Verify:

```bash
pipx --version
```

---

## Install the approved pre-commit version

Install the same version used by the central CI:

```bash
pipx install pre-commit==4.6.2
```

Verify:

```bash
pre-commit --version
```

Expected:

```text
pre-commit 4.6.2
```

Do not routinely upgrade `pre-commit` independently on developer machines.

A version change should first be reviewed and tested in the central `aperion-robotics/.github` repository and then rolled out to developers.

If another version is already installed through pipx, align it explicitly:

```bash
pipx install --force pre-commit==4.6.2
```

---

# Aperion central configuration

The usual upstream `pre-commit` pattern is to place a `.pre-commit-config.yaml` in each repository.

Aperion intentionally uses a central organization baseline instead, so the same generic repository-hygiene policy can be maintained in one place.

The central configuration is:

```text
aperion-robotics/.github
└── ci/precommit/baseline.yaml
```

`pre-commit` supports an alternate configuration path through `--config`.

This central configuration is only the generic organization baseline.
Repository-specific or ROS-specific validation remains the responsibility of the corresponding project and CI workflow.

---

## Install the central configuration locally

Create the Aperion configuration directory:

```bash
mkdir -p ~/.config/aperion
```

Clone the central repository once:

```bash
git clone \
  https://github.com/aperion-robotics/.github.git \
  ~/.config/aperion/dot-github
```

If it already exists, update it with:

```bash
git -C ~/.config/aperion/dot-github pull --ff-only
```

The expected configuration file is:

```text
~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

---

## Validate the central configuration

Before installing hooks, validate the configuration:

```bash
pre-commit validate-config \
  ~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

A successful validation produces no error.

---

# Install the Git hook in a repository

From the root of an Aperion repository:

```bash
pre-commit install \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  --install-hooks
```

This installs:

```text
.git/hooks/pre-commit
```

and prepares the hook environments immediately.

Verify:

```bash
test -x .git/hooks/pre-commit && echo "pre-commit hook installed"
```

The hook must be installed once for each local repository clone.

The future Aperion developer bootstrap tooling will automate this step.

---

# What happens during `git commit`

After installation:

```bash
git commit
```

automatically runs the baseline against the **staged files** involved in the commit.

This is the normal daily developer workflow.

Do not run `--all-files` on every commit.

The normal pre-commit hook is intentionally fast and should inspect only the relevant staged changes.

---

## When a hook modifies a file

Some hooks automatically fix simple problems such as:

- trailing whitespace
- missing final newline
- line endings

If a commit reports:

```text
files were modified by this hook
```

inspect the changes:

```bash
git diff
```

stage the corrected files again:

```bash
git add <files>
```

and repeat the commit:

```bash
git commit
```

This behavior is expected.

---

# Manual checks

## Check staged files

To manually reproduce what the Git hook normally checks:

```bash
pre-commit run \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

---

## Check the complete repository

Use this during initial adoption, cleanup, or before a significant pull request:

```bash
pre-commit run \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  --all-files \
  --show-diff-on-failure
```

Do not treat `--all-files` as the required command for every small commit.

---

## Check only branch changes

To check files changed between the default branch and the current HEAD:

```bash
git fetch origin

pre-commit run \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  --from-ref origin/main \
  --to-ref HEAD \
  --show-diff-on-failure
```

Replace `origin/main` if the repository uses another default branch.

This mode is close to the central CI behavior, which validates pull-request changes rather than forcing an immediate full-repository cleanup of legacy code.

---

# Updating the central configuration

Developers should update their local copy with:

```bash
git -C ~/.config/aperion/dot-github pull --ff-only
```

Do **not** run:

```bash
pre-commit autoupdate
```

against the central Aperion configuration from a product repository or local developer workflow.

Hook-version updates are organization policy changes and must be performed through a reviewed pull request to:

```text
aperion-robotics/.github
```

The central configuration should be updated, validated, tested, and merged before developers consume the new versions.

---

# ROS 2 local validation

The generic pre-commit baseline does not replace ROS 2 linting.

For Jazzy:

```bash
source /opt/ros/jazzy/setup.bash
```

## C/C++

Check formatting:

```bash
ament_uncrustify src include
```

Apply formatting deliberately:

```bash
ament_uncrustify --reformat src include
```

## Python

Run the ROS Python checks when applicable:

```bash
ament_flake8 .
ament_pep257 .
```

## Package/workspace validation

Run:

```bash
colcon build
colcon test
colcon test-result --verbose
```

Package-level `ament_lint_auto` / `ament_lint_common` and GitHub CI remain authoritative.

---

# ROS 1 local validation

Do not apply the ROS 2 formatters automatically to ROS 1 repositories.

For ROS 1:

- preserve established repository formatting
- use package-level `roslint` where configured
- use the repository's supported catkin workflow
- run tests in the correct ROS distribution environment

Typical Noetic development:

```bash
source /opt/ros/noetic/setup.bash

catkin build
catkin test
```

Melodic should normally be developed and validated in its supported legacy environment or an Aperion container/devcontainer.

Do not blindly run modern Python 3-only tools against Melodic Python 2 code.

---

# What not to do

## Do not use `sudo pip`

Do not install pre-commit with:

```bash
sudo pip install pre-commit
```

The developer tool should remain isolated from the system Python.

Use `pipx`.

---

## Do not modify the central baseline from product repositories

Do not locally edit:

```text
~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

to make a product repository pass.

If an organization rule needs to change, change it through a reviewed PR in the central `.github` repository.

If a repository needs a legitimate exception, document and review that exception explicitly.

---

## Do not routinely bypass hooks

Avoid:

```bash
git commit --no-verify
```

The GitHub CI will still enforce the organization checks, but bypassing local feedback wastes review and CI time.

If one specific hook must be skipped temporarily for a documented reason, prefer:

```bash
SKIP=<hook-id> git commit
```

rather than disabling every Git hook.

Any exception should be rare and explained in the pull request when relevant.

---

## Do not globally install Git hooks for every Git repository

Do not configure pre-commit to execute automatically in every unrelated Git repository on the workstation.

Install the Aperion hook only in Aperion-managed repository clones.

---

## Do not add ROS builds to the pre-commit hook

Do not put:

```text
catkin build
colcon build
simulation
CodeQL
full static analysis
```

inside the normal pre-commit stage.

The local commit hook must stay fast.

Heavy validation belongs to:

```text
local explicit validation
        ↓
GitHub CI
        ↓
nightly / integration CI
```

---

# Recommended daily workflow

```text
edit
  ↓
editor diagnostics / safe formatting
  ↓
git add
  ↓
git commit
  ↓
central pre-commit baseline on staged files
  ↓
local ROS build/tests when appropriate
  ↓
git push
  ↓
pull request
  ↓
authoritative GitHub CI
```

Before a significant pull request, optionally run:

```bash
pre-commit run \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  --all-files \
  --show-diff-on-failure
```

---

# Troubleshooting

## `pre-commit: command not found`

Check:

```bash
pipx list
```

Then:

```bash
pipx ensurepath
```

and open a new shell.

---

## Central configuration is missing

Check:

```bash
test -f ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  && echo "configuration found"
```

If missing:

```bash
git clone \
  https://github.com/aperion-robotics/.github.git \
  ~/.config/aperion/dot-github
```

---

## Hook environments are stale or broken

First try:

```bash
pre-commit clean
```

Then reinstall hook environments:

```bash
pre-commit install-hooks \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

---

## Remove unused cached hook environments

Occasionally:

```bash
pre-commit gc
```

---

# Principle

Pre-commit is a fast developer feedback layer.

It is not the complete quality system.

```text
Editor
   ↓
pre-commit
   ↓
ROS lint / build / tests
   ↓
GitHub CI
   ↓
review
   ↓
merge
```

The same central baseline should behave consistently on developer machines and in CI.
