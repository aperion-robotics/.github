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
ros2_lyrical     = false
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

| Workflow                | Purpose                                                                      | Intended target       |
| ----------------------- | ---------------------------------------------------------------------------- | --------------------- |
| `baseline.yml`          | Generic repository hygiene                                                   | `ci_managed = true`   |
| `ros1-melodic.yml`      | ROS 1 Melodic build, test and static analysis                                | `ros1_melodic = true` |
| `ros1-noetic.yml`       | ROS 1 Noetic build, test and static analysis                                 | `ros1_noetic = true`  |
| `ros2-lyrical.yml`      | ROS 2 Lyrical build and test                                                 | `ros2_lyrical = true` |
| `dependency-review.yml` | Blocks introduction of dependencies with known high-severity vulnerabilities | `ci_managed = true`   |
| `pr-title.yml`          | Pull request title follows Conventional Commits (squash commit message)      | `ci_managed = true`   |
| `ci-self-test.yml`      | Validates the central CI itself (runs only in this repository)               | this repository       |

Third-party Actions are pinned to immutable commit SHAs. Required container images are digest-pinned where applicable.

Every workflow that reads files from this repository (scripts, allowlists, configurations) checks it out at
`APERION_CI_REF`, which must equal the ref the organization rulesets require. See [section 12](#12-changing-central-ci).

---

## 3. Organization custom properties

Configured under:

```text
Organization Settings
→ Repository
→ Custom properties
```

| Property          | Type          | Values                                                    | Purpose                            |
| ----------------- | ------------- | --------------------------------------------------------- | ---------------------------------- |
| `ci_managed`      | Boolean       | `true`, `false`                                           | Enables Aperion central CI         |
| `product`         | Single select | `aristos`, `bluebot`, `shared`, `infrastructure`, `other` | Repository ownership/domain        |
| `quality_profile` | Single select | `production`, `development`, `experimental`, `legacy`     | Engineering maturity/support level |
| `ros1_melodic`    | Boolean       | `true`, `false`                                           | Enables ROS 1 Melodic CI           |
| `ros1_noetic`     | Boolean       | `true`, `false`                                           | Enables ROS 1 Noetic CI            |
| `ros2_lyrical`    | Boolean       | `true`, `false`                                           | Enables ROS 2 Lyrical CI           |
| `security_tier`   | Single select | `standard`, `product`, `critical`                         | Security importance                |
| `codeql_required` | Boolean       | `true`, `false`                                           | Makes CodeQL a required merge gate |
| `ci_pilot`        | Boolean       | `true`, `false`                                           | Receives central CI changes first  |

Example ARISTOS Noetic production repository:

```text
ci_managed       = true
product          = aristos
quality_profile  = production
ros1_melodic     = false
ros1_noetic      = true
ros2_lyrical     = false
security_tier    = product
codeql_required  = true
```

Example ROS1 → ROS2 migration repository:

```text
ci_managed       = true
product          = aristos
quality_profile  = development
ros1_noetic      = true
ros2_lyrical     = true
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
ros2_lyrical     = false
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

Required workflows:

```text
aperion-robotics/.github
refs/heads/main
.github/workflows/baseline.yml
.github/workflows/pr-title.yml
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

### `ci-ros2-lyrical`

Target:

```text
ros2_lyrical = true
```

Required workflow:

```text
.github/workflows/ros2-lyrical.yml
```

### `ci-pilot-*`

Target:

```text
ci_pilot = true
```

Same required workflows as the rulesets above, but pointing at the branch (or release candidate tag) of a
central CI change under test. See [section 12](#12-changing-central-ci).

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
- forbidden files (`.env`, private keys, keystores, OS/editor artifacts)
- rosbag recordings (`.bag`, `.mcap`, `.db3`) outside `test/`, `tests/`, `test_data/` or `testdata/` directories
- final newline consistency
- LF line endings
- trailing whitespace

The baseline workflow also scans new commits for secrets (TruffleHog) and lints the commits of the
pull request against Conventional Commits (advisory). The blocking commit message check is the pull
request title (`pr-title.yml`), which becomes the squash commit message; it is advisory for the
`experimental` and `legacy` profiles. See [CONTRIBUTING.md](CONTRIBUTING.md#commit-messages).

Advisory hooks (`typos`, `actionlint`, `zizmor`) block only when `quality_profile = production`;
otherwise their findings are listed in the job summary.

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

The central `.github` repository validates its own workflows, scripts and configurations with
`ci-self-test.yml` (actionlint, zizmor, shellcheck, script tests, pre-commit and commitlint configuration).

---

## 7. Local pre-commit workflow

Approved version:

```text
pre-commit 4.6.2
```

pre-commit 4.6.2 needs Python 3.10 or newer and git 2.31 or newer. Ubuntu 18.04 (Melodic) and 20.04 (Noetic)
have neither, so install and run pre-commit on the host (Ubuntu 22.04 or newer) and commit from there, also
when you build inside a ROS 1 container.

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

git clone \
  https://github.com/aperion-robotics/.github.git \
  ~/.config/aperion/dot-github
```

Update it:

```bash
git -C ~/.config/aperion/dot-github pull --ff-only
```

Install the hook in an Aperion repository:

```bash
pre-commit install \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  --install-hooks
```

Run manually:

```bash
pre-commit run \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

Run against all files:

```bash
pre-commit run \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  --all-files \
  --show-diff-on-failure
```

Run only against branch changes:

```bash
git fetch origin

pre-commit run \
  --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml \
  --from-ref origin/main \
  --to-ref HEAD \
  --show-diff-on-failure
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

For EOL distributions industrial_ci builds against the final snapshot: the `snapshots.ros.org` apt repository
and the rosdistro tag of the EOL date (e.g. `melodic/2023-06-27`). Python 2 rosdep keys therefore still resolve,
and `ROS_REPO` is not set.

ROS 1 builds cache compiler output (ccache) per pull request, so later pushes to the same pull request
rebuild faster.

### Melodic

Uses:

```text
ros-industrial/industrial_ci
```

with:

```text
ROS_DISTRO=melodic
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

### Repository CI files

ROS repositories may add, per workflow (`ros1-melodic`, `ros1-noetic`, `ros2-lyrical`):

| File                   | Purpose                                                                            |
| ---------------------- | ---------------------------------------------------------------------------------- |
| `.ci/<workflow>.repos` | Source dependencies (vcstool format), e.g. other Aperion ROS packages              |
| `.ci/<workflow>.env`   | Allowlisted options, one `KEY=VALUE` per line, `#` comments                        |

Private source dependencies:

- every `aperion-robotics` repository referenced by the manifest must be listed in
  [`ci/source-deps/allowed-repositories.txt`](ci/source-deps/allowed-repositories.txt); add it through a pull
  request to this repository
- the CI GitHub App token is created only for the referenced repositories, exists only in the import step and
  never reaches the build or the tests
- SSH URLs (`git@github.com:...`) are fetched over HTTPS

Options accepted in `.ci/<workflow>.env`:

| Workflow       | Keys                                                                                                                |
| -------------- | ------------------------------------------------------------------------------------------------------------------- |
| `ros1-*`       | `ROSDEP_SKIP_KEYS`, `ADDITIONAL_DEBS`, `CMAKE_ARGS`, `TARGET_CMAKE_ARGS`, `UPSTREAM_CMAKE_ARGS`, `CATKIN_LINT_ARGS`, `CLANG_TIDY_ARGS` |
| `ros2-lyrical` | `ROSDEP_SKIP_KEYS`, `CMAKE_ARGS`                                                                                    |

Values are a single line of letters, digits, spaces and `_ . , : = / + * @ -`. Prefer fixing `package.xml`
to use the correct rosdep key over skipping keys, for example:

```text
# .ci/ros1-melodic.env - only for dependencies without any rosdep key
ROSDEP_SKIP_KEYS=some-vendor-sdk
ADDITIONAL_DEBS=libsome-vendor-sdk-dev
```

Changes to `.ci/` affect what CI checks; review them like code (CODEOWNERS recommended).

---

## 9. ROS 2 Lyrical policy

Primary ROS 2 production target:

```text
Ubuntu 26.04 Resolute
ROS 2 Lyrical
```

CI implementation:

```text
ros-tooling/action-ros-ci
```

The workflow:

- creates a clean ROS workspace
- installs declared dependencies through `rosdep`
- builds with `colcon` up to the repository's packages
- runs the tests of the repository's packages (source dependencies are built, not tested)
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

`ament_lint_common` includes `ament_copyright`, which fails on files without a recognized license header.
Proprietary packages either add the agreed company header or exclude that linter explicitly:

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  list(APPEND AMENT_LINT_AUTO_EXCLUDE ament_cmake_copyright)
  ament_lint_auto_find_test_dependencies()
endif()
```

Unlike the ROS 1 workflows, the ROS 2 workflow does not run clang-tidy yet.

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
   +-- Pull Request Title
   +-- Dependency Review
   +-- ROS1 Melodic CI      if ros1_melodic = true
   +-- ROS1 Noetic CI       if ros1_noetic = true
   +-- ROS2 Lyrical CI      if ros2_lyrical = true
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
7. be tested on representative pilot repositories before broad rollout (see below)
8. update this README and relevant developer documentation when organization policy changes

Direct commits to `main` are not allowed.

### Testing central CI changes

Rulesets run a required workflow from the ref they point at. Consequences:

- On pull requests to this repository, the required `Aperion Baseline` and `Pull Request Title` checks run the
  workflows of `main`, not the ones under review. `ci-self-test.yml` is not required by an organization ruleset
  and runs the version under review; make it a required status check of this repository.
- The ROS workflows skip this repository. Validate them on pilot repositories:
  1. set `ci_pilot = true` on a few representative repositories (for example a Melodic package with private
     source dependencies, a Noetic package and a ROS 2 package)
  2. point the `ci-pilot-*` rulesets at the branch of the central pull request
  3. open a pull request on each pilot repository and link the runs from the central pull request
  4. merge the central pull request only after the pilot runs pass

### Versioning

Today the rulesets and `APERION_CI_REF` both use `main`, so every merge changes the gates of all managed
repositories at once. Recommended next step: release tags (`v1.2.0`). In the release commit set
`APERION_CI_REF` to the new tag, tag it, then move the rulesets to the tag; the pilot rulesets keep following
the branch under test.

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
ROS 2 Lyrical
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
