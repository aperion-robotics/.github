# Aperion Robotics - GitHub CI and Repository Standards

This repository contains the shared GitHub configuration and CI standards used across Aperion Robotics repositories.

The goal is to keep CI, repository rules, security settings and developer guidelines consistent across ARISTOS, BlueBOT, shared libraries and infrastructure repositories.

> **Important**
>
> This repository is public because some GitHub organization features rely on it. Do not store credentials, private infrastructure configuration, customer data, robot secrets, certificates, VPN material, production tokens or other confidential information here.

---

## 1. CI architecture

Aperion uses three layers to control CI and repository governance:

```text
Repository custom properties
            |
            v
Organization rulesets
            |
            v
Central workflows in aperion-robotics/.github
            |
            v
Pull request checks / merge gates
```

Repositories do **not** need to duplicate the central workflows.

Repository custom properties decide which rulesets apply. The rulesets then decide which CI and security checks are required before merge.

Example:

```text
ci_managed       = true
ros1_noetic      = true
ros2_jazzy       = false
codeql_required  = true
        |
        v
Required on PR:
  - branch / PR governance
  - Aperion Baseline
  - ROS1 Noetic CI
  - Dependency Review
  - CodeQL
```

ROS distribution properties are independent because, during migration, a repository may need both ROS 1 and ROS 2 CI enabled.

---

## 2. Central workflows

Central GitHub Actions workflows live under:

```text
.github/workflows/
```

| Workflow | Purpose | Intended target |
|---|---|---|
| `baseline.yml` | Generic repository hygiene | `ci_managed = true` |
| `ros1-melodic.yml` | ROS 1 Melodic build, test and static analysis | `ros1_melodic = true` |
| `ros1-noetic.yml` | ROS 1 Noetic build, test and static analysis | `ros1_noetic = true` |
| `ros2-jazzy.yml` | ROS 2 Jazzy build and test | `ros2_jazzy = true` |
| `dependency-review.yml` | Blocks introduction of dependencies with known high-severity vulnerabilities | managed repositories where Dependency Review is enabled |

Third-party Actions are pinned to immutable commit SHAs. Required container images are digest-pinned where applicable.

---

## 3. Organization custom properties

Configured under:

```text
Organization Settings
→ Repository
→ Custom properties
```

| Property | Type | Values | Purpose |
|---|---|---|---|
| `ci_managed` | Boolean | `true`, `false` | Enables Aperion central CI |
| `product` | Single select | `aristos`, `bluebot`, `shared`, `infrastructure`, `other` | Repository ownership/domain |
| `quality_profile` | Single select | `production`, `development`, `experimental`, `legacy` | Engineering maturity/support level |
| `ros1_melodic` | Boolean | `true`, `false` | Enables ROS 1 Melodic CI |
| `ros1_noetic` | Boolean | `true`, `false` | Enables ROS 1 Noetic CI |
| `ros2_jazzy` | Boolean | `true`, `false` | Enables ROS 2 Jazzy CI |
| `security_tier` | Single select | `standard`, `product`, `critical` | Security importance |
| `codeql_required` | Boolean | `true`, `false` | Makes CodeQL a required merge gate |

Example ARISTOS Noetic production repository:

```text
ci_managed       = true
product          = aristos
quality_profile  = production
ros1_melodic     = false
ros1_noetic      = true
ros2_jazzy       = false
security_tier    = product
codeql_required  = true
```

Example ROS1 → ROS2 migration repository:

```text
ci_managed       = true
product          = aristos
quality_profile  = development
ros1_noetic      = true
ros2_jazzy       = true
security_tier    = product
codeql_required  = true
```

Central `.github` repository:

```text
ci_managed       = true
product          = infrastructure
quality_profile  = production
ros1_melodic     = false
ros1_noetic      = false
ros2_jazzy       = false
security_tier    = critical
codeql_required  = false
```

Public upstream forks / mirrors should normally remain `ci_managed = false` unless Aperion intentionally owns and maintains them as product repositories.

---

## 4. Organization rulesets

Rulesets are configured under:

```text
Organization Settings
→ Repository
→ Rulesets
```

Rulesets are additive, so a repository can be covered by more than one ruleset.

### `protect-default-branch-all-repos`

Applies to the default branch.

Current rules:

- deletion blocked
- non-fast-forward updates / force pushes blocked
- pull requests required
- minimum approving reviews: **1**
- stale approvals dismissed after new pushes
- review conversations must be resolved
- unattributed changes require additional approval
- allowed merge methods:
  - merge
  - squash
  - rebase
- GitHub Code Quality severity threshold: `errors`
- Copilot code review:
  - draft PR review enabled
  - review-on-push disabled
- no bypass actors

CodeQL is intentionally **not** required by this universal ruleset.

### `ci-baseline-managed-repositories`

Target:

```text
ci_managed = true
```

Branch target:

```text
Default branch
```

Required workflow:

```text
aperion-robotics/.github
refs/heads/main
.github/workflows/baseline.yml
```

### `ci-ros1-melodic`

Target:

```text
ros1_melodic = true
```

Required workflow:

```text
.github/workflows/ros1-melodic.yml
```

### `ci-ros1-noetic`

Target:

```text
ros1_noetic = true
```

Required workflow:

```text
.github/workflows/ros1-noetic.yml
```

### `ci-ros2-jazzy`

Target:

```text
ros2_jazzy = true
```

Required workflow:

```text
.github/workflows/ros2-jazzy.yml
```

### `security-codeql-required`

Target:

```text
codeql_required = true
```

Branch target:

```text
Default branch
```

Rule:

```text
Require code scanning results
Tool: CodeQL
Security alerts threshold: critical
Analysis alerts threshold: errors
```

### Dependency Review ruleset

Target:

```text
ci_managed = true
```

Required workflow:

```text
.github/workflows/dependency-review.yml
```

Current Dependency Review policy:

```text
fail-on-severity: high
vulnerability-check: true
license-check: false
show-openssf-scorecard: true
```

---

## 5. Security configuration

Canonical organization security configuration:

```text
Aperion-Baseline-Private
```

Configured under:

```text
Organization Settings
→ Security and quality
→ Advanced Security
→ Configurations
```

### Secret Protection

```text
Secret Protection                 Enabled
Secret scanning                   Enabled
AI-detected secrets               Enabled
Push protection                   Enabled
Validity checks                   Disabled
Generic patterns                  Disabled
Prevent direct alert dismissals   Disabled
```

Current push-protection bypass policy:

```text
Anyone with write access
```

This should be reviewed periodically and tightened if a narrower security/admin bypass model becomes practical.

### Code Security

```text
Code Security                     Enabled
Code scanning default setup       Enabled
Runner type                       Standard
Prevent direct alert dismissals   Disabled
```

### Dependency scanning

```text
Dependency graph                  Enabled
Automatic dependency submission   Not set
Dependabot alerts                 Enabled
Dependabot security updates       Enabled
Prevent direct alert dismissals   Disabled
```

### Vulnerability reporting

```text
Private vulnerability reporting   Enabled
```

### Policy

```text
Default for new repositories      Private and Internal
Enforce configuration             Don't enforce
```

Security features and merge requirements are kept separate:

```text
Security configuration
    → enables capabilities

Repository properties + rulesets
    → decide which results block merging
```

---

## 6. Generic repository baseline

Configuration:

```text
ci/precommit/baseline.yaml
```

The baseline does not include ROS-specific formatting rules.

Checks include:

- files larger than **20 MB**
- filename case conflicts
- merge-conflict markers
- broken symlinks
- YAML syntax
- JSON syntax
- TOML syntax
- XML syntax
- private-key detection
- final newline consistency
- LF line endings
- trailing whitespace

Excluded paths:

```text
third_party/
vendor/
external/
.aperion-ci/
```

Consumer repositories use the approved baseline from:

```text
aperion-robotics/.github@main
```

The central `.github` repository self-tests its GitHub Actions workflows with `actionlint`.

---

## 7. Local pre-commit workflow

Approved version:

```text
pre-commit 4.6.2
```

Install:

```bash
sudo apt update
sudo apt install -y pipx

pipx ensurepath
pipx install pre-commit==4.6.2
```

Clone the central configuration:

```bash
mkdir -p ~/.config/aperion

git clone   https://github.com/aperion-robotics/.github.git   ~/.config/aperion/dot-github
```

Update it:

```bash
git -C ~/.config/aperion/dot-github pull --ff-only
```

Install the hook in an Aperion repository:

```bash
pre-commit install   --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml   --install-hooks
```

Run manually:

```bash
pre-commit run   --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

Run against all files:

```bash
pre-commit run   --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml   --all-files   --show-diff-on-failure
```

Run only against branch changes:

```bash
git fetch origin

pre-commit run   --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml   --from-ref origin/main   --to-ref HEAD   --show-diff-on-failure
```

Replace `origin/main` if the repository uses another default branch.

If hooks modify files:

```bash
git diff
git add <fixed-files>
```

Then run the check or commit again.

See [docs/developer/pre-commit.md](docs/developer/pre-commit.md).

---

## 8. ROS 1 policy

ROS 1 Melodic and ROS 1 Noetic are EOL upstream distributions. We keep them as legacy compatibility targets while the migration to ROS 2 continues.

### Melodic

Uses:

```text
ros-industrial/industrial_ci
```

with:

```text
ROS_DISTRO=melodic
ROS_REPO=main
BUILDER=catkin_tools
```

Checks include:

- dependency installation through `rosdep`
- catkin build
- package tests
- installation validation
- `catkin_lint`
- `clang-tidy`
- verbose tests

Melodic Python 2 compatibility must be preserved where still required.

### Noetic

Uses:

```text
ros-industrial/industrial_ci
```

with:

```text
ROS_DISTRO=noetic
ROS_REPO=main
BUILDER=catkin_tools
```

Checks include:

- dependency installation through `rosdep`
- catkin build
- package tests
- installation validation
- `catkin_lint`
- `clang-tidy`
- Python pylint error checks
- verbose tests

Pylint is intentionally limited to:

```text
--errors-only
```

Existing package-level `roslint` checks remain supported.

Large formatting-only changes to legacy ROS 1 repositories should be avoided unless explicitly approved.

---

## 9. ROS 2 Jazzy policy

Primary ROS 2 production target:

```text
Ubuntu 24.04 Noble
ROS 2 Jazzy
```

CI implementation:

```text
ros-tooling/action-ros-ci
```

The workflow:

- creates a clean ROS workspace
- installs declared dependencies through `rosdep`
- builds with `colcon`
- runs package tests
- executes package-level ament lint tests

ROS 2 packages should normally declare:

```xml
<test_depend>ament_lint_auto</test_depend>
<test_depend>ament_lint_common</test_depend>
```

CMake packages should normally use:

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()
```

C++ targets should enable:

```cmake
target_compile_options(
  my_target
  PRIVATE
    -Wall
    -Wextra
    -Wpedantic
)
```

Warnings are not globally promoted to errors at this stage.

Coverage is currently disabled and should be introduced later as a dedicated quality gate.

---

## 10. Pull-request merge model

A typical managed product repository may require:

```text
Pull request
   |
   +-- 1 approval
   +-- review conversations resolved
   +-- Aperion Baseline
   +-- Dependency Review
   +-- ROS1 Melodic CI      if ros1_melodic = true
   +-- ROS1 Noetic CI       if ros1_noetic = true
   +-- ROS2 Jazzy CI        if ros2_jazzy = true
   +-- CodeQL               if codeql_required = true
   |
   v
 Merge
```

Existing PRs opened before a new required-workflow ruleset was activated may display:

```text
Expected - Waiting for workflow to run
```

Trigger a new synchronization event, for example:

```bash
git commit --allow-empty -m "ci: retrigger required workflows"
git push
```

Do not disable organization rules merely to unblock an old PR without first understanding the missing event or failing check.

---

## 11. CI rollout policy

Recommended rollout order:

```text
1. central .github repository
2. pilot ARISTOS repositories
3. active ARISTOS production repositories
4. shared production libraries
5. BlueBOT repositories
6. development / experimental repositories
7. legacy repositories
```

Public upstream forks and mirrors should normally remain:

```text
ci_managed = false
```

until Aperion intentionally takes ownership.

Some legacy repositories will expose existing technical debt when CI is enabled.

The preferred approach is:

```text
fix or explicitly document the repository-specific issue
```

rather than weakening the organization-wide policy for every repository.

---

## 12. Changing central CI

Changes to this repository can affect many repositories across Aperion Robotics.

All central CI changes must:

1. be made through a pull request
2. pass central validation
3. receive the required review
4. preserve least-privilege GitHub Actions permissions
5. keep third-party Actions pinned to immutable SHAs
6. keep required container images pinned by digest where applicable
7. be tested on representative pilot repositories before broad rollout
8. update this README and relevant developer documentation when organization policy changes

Direct commits to `main` are not allowed.

> Organization rulesets, custom properties and Advanced Security configurations are **not stored in this Git repository**. Keep this README updated when organization-level settings change.

---

## 13. Developer documentation

Documentation lives under:

```text
docs/developer/
```

Current guides:

- [Developer documentation index](docs/developer/README.md)
- [Pre-commit setup](docs/developer/pre-commit.md)
- [EditorConfig](docs/developer/editorconfig.md)
- [VS Code setup](docs/developer/vscode.md)
- [CONTRIBUTING.md](CONTRIBUTING.md)
- [SECURITY.md](SECURITY.md)

---

## 14. Engineering principles

General rules:

- centralize policy where it improves consistency
- keep repository classification explicit
- separate generic hygiene from ROS-specific validation
- preserve legacy ROS compatibility without freezing engineering standards
- use ROS-native lint/build tooling where practical
- keep GitHub Actions permissions minimal
- pin third-party CI dependencies
- avoid organization-wide exceptions for repository-specific technical debt
- keep local developer feedback fast
- use CI as the authoritative merge gate
- keep simulation, HIL, performance and long-running validation in dedicated integration layers

Validation hierarchy:

```text
Editor
   ↓
pre-commit
   ↓
local ROS build / tests
   ↓
pull request
   ↓
organization-required GitHub CI
   ↓
review
   ↓
merge
   ↓
integration / simulation / HIL / release validation
```

---

## 15. Current CI foundation

Current CI/security setup covers:

```text
Repository hygiene
ROS 1 Melodic
ROS 1 Noetic
ROS 2 Jazzy
Dependency vulnerability review
CodeQL merge enforcement where required
Dependabot
Secret scanning
Push protection
PR governance
```

Possible next steps:

- coverage thresholds
- sanitizers
- nightly full-workspace validation
- simulation tests
- hardware-in-the-loop tests
- performance regression tests
- SBOM generation
- artifact provenance / attestations
- release-specific deployment validation
