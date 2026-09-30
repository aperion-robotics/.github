# Contributing to Aperion Robotics Repositories

All software changes should be developed through reviewed pull requests.

## Development workflow

Create a branch from the current default branch.

Use descriptive branch names, for example:

```text
feature/nav2-recovery
fix/gnss-timeout
refactor/localization-state
ci/jazzy-build
```

Make focused commits and avoid mixing unrelated changes in the same pull
request.

Direct commits to protected default branches are not allowed.

## Before opening a pull request

Run the relevant local checks and tests for the repository.

At minimum:

- ensure the project builds
- run available unit and integration tests
- run relevant lint checks
- verify that no credentials or secrets are included
- update dependency declarations when dependencies change

ROS dependencies must be declared correctly in `package.xml`.

## ROS 2 packages

ROS 2 packages should use:

```xml
<test_depend>ament_lint_auto</test_depend>
<test_depend>ament_lint_common</test_depend>
```

CMake packages should normally include:

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()
```

The authoritative validation is performed by `colcon test` in CI.

## ROS 1 packages

ROS 1 Melodic and Noetic repositories are legacy compatibility targets.

Avoid large formatting-only changes unless they are explicitly part of an
approved cleanup.

Existing `roslint`, catkin tests, and package-specific test infrastructure
should be preserved.

## Pull requests

Pull requests should explain:

- what is being changed
- why the change is required
- how it was tested
- any effects on ROS interfaces
- any safety or hardware impact
- any deployment or configuration changes

Changes to topics, services, actions, parameters, TF frames, message
definitions, hardware interfaces, or externally consumed APIs must be clearly
identified.

## Robotics validation

Depending on the change, validation may include:

- unit tests
- integration tests
- simulation
- rosbag replay
- hardware-in-the-loop testing
- testing on a robot

The appropriate level of validation depends on the risk and scope of the
change.

## Security

Never commit:

- credentials
- passwords
- tokens
- private keys
- production certificates
- customer secrets
- unapproved confidential data

If a real credential is accidentally committed, notify the responsible team
and rotate or revoke the credential immediately.

See `SECURITY.md` for vulnerability reporting.

## Generated and AI-assisted code

Generated or AI-assisted code is subject to the same engineering standards as
manually written code.

The engineer submitting the change remains responsible for understanding,
reviewing, testing, and maintaining the resulting implementation.
