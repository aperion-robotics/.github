# Repository CI Files

Consumer repositories contain **no workflows**. They influence the central ROS workflows only through files under
`.ci/`, one pair per workflow (`ros1-melodic`, `ros1-noetic`, `ros2-lyrical`):

| File                   | Purpose                                                                |
| ---------------------- | ---------------------------------------------------------------------- |
| `.ci/<workflow>.repos` | Source dependencies in vcstool format, e.g. other Aperion ROS packages |
| `.ci/<workflow>.env`   | Allowlisted options, one `KEY=VALUE` per line, `#` comments            |

Both files are optional. Without a `.repos` file the GitHub App token and import steps are skipped.

## Source dependencies (`.repos`)

```yaml
repositories:
  aperion_ci_lyrical_dep:
    type: git
    url: https://github.com/aperion-robotics/ci-pilot-ros2-lyrical-dep.git
    version: main
```

- Every `aperion-robotics` repository in the manifest must be listed in
  [`ci/source-deps/allowed-repositories.txt`](https://github.com/aperion-robotics/.github/blob/main/ci/source-deps/allowed-repositories.txt). Add it through a pull request to the central repository, otherwise the workflow fails before the build.
- The GitHub App token is scoped to exactly the referenced repositories and exists only in the import step.
- SSH URLs (`git@github.com:...`) are fetched over HTTPS. Public repositories do not need an allowlist entry.
- ROS 2 builds and tests only the repository's own packages. Dependencies are just built, not triggered for testing.

## Options (`.env`)

| Workflow                      | Allowed keys                                                                                                                           |
| ----------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| `ros1-melodic`, `ros1-noetic` | `ROSDEP_SKIP_KEYS`, `ADDITIONAL_DEBS`, `CMAKE_ARGS`, `TARGET_CMAKE_ARGS`, `UPSTREAM_CMAKE_ARGS`, `CATKIN_LINT_ARGS`, `CLANG_TIDY_ARGS` |
| `ros2-lyrical`                | `ROSDEP_SKIP_KEYS`, `CMAKE_ARGS`                                                                                                       |

Values are a single line of letters, digits, spaces and `_ . , : = / + * @ -`. Anything else leads to a failed workflow.
Prefer fixing the rosdep key in `package.xml` over `ROSDEP_SKIP_KEYS`.

Example:

```text
# .ci/ros2-lyrical.env
CMAKE_ARGS=-DCMAKE_BUILD_TYPE=RelWithDebInfo
```

## Repository hygiene for CI files

- Tend `.ci/` like code. Assign it an owner in `.github/CODEOWNERS`, respect formatting.
- The ROS workflows create `.aperion-ci/` and `aperion-upstream/` (for ROS1) inside the checkout. Do not forget to add them in `.gitignore`.
- Currently, ROS 1 and ROS 2 packages cannot share a repository, since both workflows resolve every `package.xml`. Separate them to different branches or repositories.

The reference repositories `ci-pilot-*` contain various examples. Study them.
