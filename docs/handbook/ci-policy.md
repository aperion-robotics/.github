# CI Policy and Merge Gates

Shared configuration lives in [aperion-robotics/.github](https://github.com/aperion-robotics/.github). **Custom properties** select organization rulesets; **rulesets** select required checks. Workflows do not need copying into consumer repositories.

| Gate                    | Coverage                                                                                                                                                                                                                                            |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Aperion Baseline        | YAML/JSON/TOML/XML, whitespace/newlines, large/forbidden files, rosbag recordings outside test directories, conflict markers, private keys, TruffleHog secret scan of new commits, advisory `typos`, `actionlint`, `zizmor` and commit-message lint |
| ROS1 Melodic and Noetic | `rosdep`, `catkin_tools`, tests, `catkin_lint`, `clang-tidy`; Noetic Python error checks                                                                                                                                                            |
| ROS2 Lyrical            | `rosdep`, `colcon`, package unit tests and `ament` lint                                                                                                                                                                                             |
| Dependency Review       | Introduction of dependencies with known vulnerabilities (configured severity threshold)                                                                                                                                                             |
| CodeQL                  | Code-scanning results enforced in repositories with `codeql_required=true`, **only when actual scanning is configured**                                                                                                                             |
| PR governance           | Conventional Commit PR title, approvals, resolved comments and required status checks                                                                                                                                                               |

## Repository properties

- `ci_managed=true` enables the shared baseline and dependency checks.
- `ros1_melodic`, `ros1_noetic`, `ros2_lyrical` select distribution-specific checks independently.
- `codeql_required=true` selects the CodeQL results ruleset; it does not execute the scanner itself.
- `ci_pilot=true` identifies the dedicated CI validation repositories when pilot rulesets are configured.
- `quality_profile` sets the strictness: `production` makes the advisory hooks (`typos`, `actionlint`, `zizmor`) blocking,
  `experimental` and `legacy` turn the PR title check into a warning, `development` (default) is in between.
- `product` sets the owner (`aristos`, `bluebot`, `shared`, `infrastructure`, `other`).
  \-`security_tier` highlights security importance.

Use **one ROS generation per repository**: several ROS1 distributions may be enabled together, but not ROS1 and ROS2, because both workflows resolve every `package.xml`. Migrate to ROS2 in a separate repository or on a branch that switches the properties when merged. Pilot rulesets and production rulesets must **not overlap** in a way that runs two revisions of the same required workflow. Defaults are protected: changes go via PR and review.

## Baseline is not a ROS formatter

The shared pre-commit baseline is intended to be fast. It is not a replacement for `roslint`, `ament_uncrustify`, `ament_flake8`, `catkin`, or `colcon`.

Repositories adjust the ROS workflows only through [repository CI files](repository-ci-files.md).

See the [central README](https://github.com/aperion-robotics/.github/blob/main/README.md) for the current rule values and thresholds.
