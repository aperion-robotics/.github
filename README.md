# Aperion Robotics - GitHub Engineering

This repository contains organization-wide GitHub configuration, CI workflows, security policy, contribution guidelines, and developer tooling documentation for Aperion Robotics.

This repository is intentionally public so GitHub can use its workflows and default community health files across both public and private organization repositories.

No credentials, private configuration, customer data, robot secrets, or production infrastructure information may be stored here.

## CI architecture

Aperion Robotics uses centralized GitHub Actions workflows combined with organization repository custom properties and organization rulesets.

The intended model is:

```text
Repository
    |
    +-- baseline CI
    |
    +-- ROS1 Melodic CI      if ros1_melodic = true
    |
    +-- ROS1 Noetic CI       if ros1_noetic = true
    |
    +-- ROS2 Jazzy CI        if ros2_jazzy = true
    |
    +-- dependency review
```

Repositories do not need to duplicate the central workflows. Organization rulesets determine which workflows are required.

## Central workflows

| Workflow | Purpose |
|---|---|
| `baseline.yml` | Generic repository hygiene checks |
| `ros1-melodic.yml` | ROS 1 Melodic build, test and static analysis using ROS-Industrial `industrial_ci` |
| `ros1-noetic.yml` | ROS 1 Noetic build, test and static analysis using ROS-Industrial `industrial_ci` |
| `ros2-jazzy.yml` | ROS 2 Jazzy build and test using `ros-tooling/action-ros-ci` |
| `dependency-review.yml` | Prevent introduction of dependencies with known high-severity vulnerabilities |

## Repository classification

Managed repositories are classified using organization custom properties.

Expected properties:

| Property | Type | Example values |
|---|---|---|
| `ci_managed` | Boolean | `true`, `false` |
| `product` | Single select | `aristos`, `bluebot`, `shared`, `infrastructure`, `other` |
| `quality_profile` | Single select | `production`, `development`, `experimental`, `legacy` |
| `ros1_melodic` | Boolean | `true`, `false` |
| `ros1_noetic` | Boolean | `true`, `false` |
| `ros2_jazzy` | Boolean | `true`, `false` |
| `security_tier` | Single select | `standard`, `product`, `critical` |

ROS distribution properties are independent because a repository may need to be validated against more than one ROS distribution.

## ROS 2 standard

The primary ROS 2 production target is:

- Ubuntu 24.04 Noble
- ROS 2 Jazzy

ROS 2 packages should declare the standard ROS lint dependencies:

```xml
<test_depend>ament_lint_auto</test_depend>
<test_depend>ament_lint_common</test_depend>
```

For CMake packages:

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()
```

This allows `colcon test` to execute the ROS-provided linting tools together
with package tests.

C++ targets should enable compiler warnings:

```cmake
target_compile_options(
  my_target
  PRIVATE
    -Wall
    -Wextra
    -Wpedantic
)
```

Warnings are not globally promoted to errors during the initial CI rollout.

## ROS 1 legacy policy

ROS 1 Melodic and ROS 1 Noetic are end-of-life upstream distributions.

They are therefore treated as legacy compatibility targets while software is migrated to ROS 2.

ROS 1 CI uses ROS-Industrial `industrial_ci` and includes:

- dependency installation through rosdep
- catkin build
- package tests
- installation validation
- catkin_lint
- clang-tidy

Existing package-level `roslint` tests remain supported.
Large-scale automatic reformatting of legacy ROS 1 code is intentionally avoided.

## Local baseline checks

The same generic repository checks used in CI can be run locally:

```bash
pipx run --spec pre-commit==4.6.2 \
  pre-commit run \
  --config ci/precommit/baseline.yaml \
  --all-files
```

GitHub Actions workflows can be validated with:

```bash
actionlint .github/workflows/*.yml
```
Developer workstation setup will be automated through the Aperion developer tooling repository.

## Security

Security controls are implemented using a combination of:

- GitHub Secret Scanning and Push Protection
- GitHub CodeQL / Code Scanning
- Dependabot alerts and security updates
- Dependency Review
- organization rulesets
- least-privilege GitHub Actions permissions

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## Changing organization CI

Changes to this repository affect multiple repositories across Aperion Robotics.

All changes must therefore:

1. be made through a pull request
2. pass the repository validation workflows
3. receive review
4. be tested on representative pilot repositories before broad rollout

Changes to central CI must never be committed directly to `main`.
