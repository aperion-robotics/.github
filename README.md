# aperion-robotics/.github

Org-wide defaults for all repositories of Aperion Robotics. Nothing secret belongs here:
this repository is public so that its workflows can run in both public and private repositories.

## Contents

| Path | Purpose |
|---|---|
| `.github/workflows/common.yml` | Code style (pre-commit) and secret scan (gitleaks). Required on every repository. |
| `.github/workflows/ros1-ci.yml` | ROS 1 build and tests. Required where `ros_version = ros1`. |
| `.github/workflows/ros2-ci.yml` | ROS 2 build and tests. Required where `ros_version = ros2`. |
| `ci/pre-commit-config.yaml` | The org code style (ROS 2 conventions for C++ and Python). |
| `ci/.clang-format`, `ci/.flake8` | Official ROS 2 configs from `ament_lint`. |
| `SECURITY.md`, `pull_request_template.md` | Defaults for every repository without its own copy. |

The workflows are enforced by organization rulesets, not by files in each repository.
Which workflows apply is decided by the custom property `ros_version` (set by org owners).

## Per-repository settings

| Variable | Default | Example |
|---|---|---|
| `ROS1_DISTRO` | `melodic` | `gh variable set ROS1_DISTRO --repo aperion-robotics/<repo> --body melodic` |
| `ROS2_DISTRO` | `jazzy` | `gh variable set ROS2_DISTRO --repo aperion-robotics/<repo> --body jazzy` |

## Run the checks locally

From the root of any repository:

```bash
git clone https://github.com/aperion-robotics/.github .org-ci   # once
echo ".org-ci/" >> .git/info/exclude                             # once
pipx run pre-commit run --config .org-ci/ci/pre-commit-config.yaml \
  --from-ref origin/main --to-ref HEAD
```

Only the files changed in a pull request are checked, so existing code can adopt the style gradually.

## ROS 2 packages: one formatter only

The org style uses clang-format. In ROS 2 packages that use `ament_lint_auto`, disable
uncrustify so that the two formatters do not disagree:

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  list(APPEND AMENT_LINT_AUTO_EXCLUDE ament_cmake_uncrustify)
  ament_lint_auto_find_test_dependencies()
endif()
```

## Changing anything here

Changes go through a pull request like any other repository. A change to `main` applies to
every repository in the organization on its next pull request.
