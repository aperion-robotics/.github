# CI Policy and Merge Gates

Shared configuration lives in [aperion-robotics/.github](https://github.com/aperion-robotics/.github). **Custom properties** select organization rulesets; **rulesets** select required checks. Workflows do not need copying into consumer repositories.

| Gate | Coverage |
|---|---|
| Aperion Baseline | YAML/JSON/TOML/XML, whitespace/newlines, secrets, large/forbidden files, conflict markers |
| ROS1 Melodic and Noetic | `rosdep`, `catkin_tools`, tests, `catkin_lint`, `clang-tidy`; Noetic Python error checks |
| ROS2 Lyrical | `rosdep`, `colcon`, package unit tests and `ament` lint |
| Dependency Review | Introduction of dependencies with known vulnerabilities (configured severity threshold) |
| CodeQL | Code-scanning results enforced in repositories with `codeql_required=true`, **only when actual scanning is configured** |
| PR governance | Conventional Commit PR title, approvals, resolved comments and required status checks |

## Repository properties

- `ci_managed=true` enables the shared baseline and dependency checks.
- `ros1_melodic`, `ros1_noetic`, `ros2_lyrical` select distribution-specific checks independently.
- `codeql_required=true` selects the CodeQL results ruleset; it does not execute the scanner itself.
- `ci_pilot=true` identifies the dedicated CI validation repositories when pilot rulesets are configured.

ROS1 and ROS2 properties may both be enabled during migration. Pilot rulesets and production rulesets must **not overlap** in a way that runs two revisions of the same required workflow. Defaults are protected: changes go via PR and review.

## Baseline is not a ROS formatter

The shared pre-commit baseline is intended to be fast. It is not a replacement for `roslint`, `ament_uncrustify`, `ament_flake8`, `catkin`, or `colcon`.

See the [central README](https://github.com/aperion-robotics/.github/blob/main/README.md) for the current rule values and thresholds.
