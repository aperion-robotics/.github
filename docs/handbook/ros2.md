# ROS2 Development — Lyrical

Production migration target: ROS2 **Lyrical**, Ubuntu **26.04 Resolute**. Use an environment where the ROS2 tools are installed (host or appropriate development container).

```bash
source /opt/ros/lyrical/setup.bash
```

## C/C++ formatting

```bash
ament_uncrustify src include
# Deliberate reformat — inspect changes afterward
ament_uncrustify --reformat src include
git diff
```

## Python validation

```bash
ament_flake8 .
ament_pep257 .
```

## Build and tests

From the relevant workspace:

```bash
colcon build
colcon test
colcon test-result --verbose
```

ROS2 packages should declare appropriate `ament_lint_auto` / `ament_lint_common` test dependencies. The package test suite and central CI remain authoritative even if the editor format-on-save succeeds.

For proprietary repositories, follow approved company licensing policy. Do not insert an open-source license header solely to make a linter pass. Instead, exclude `ament_copyright` (it only accepts recognized license headers) and keep a plain copyright line, which `ament_cpplint` requires:

```cmake
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  list(APPEND AMENT_LINT_AUTO_EXCLUDE ament_cmake_copyright)
  ament_lint_auto_find_test_dependencies()
endif()
```

```cpp
// Copyright (c) 2026 Aperion Robotics S.A.
```

`ament_python` packages omit `test/test_copyright.py`.

Source dependencies and CI options are set in `.ci/ros2-lyrical.repos` / `.ci/ros2-lyrical.env` ([repository CI files](repository-ci-files.md)).
