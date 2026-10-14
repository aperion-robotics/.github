# ROS1 Development — Melodic / Noetic

ROS1 Melodic targets the Ubuntu 18.04/Python2-era environment; Noetic targets Ubuntu 20.04/Python3. Both are legacy compatibility targets.

| Host (recommended) | Matching ROS1 container |
|---|---|
| VS Code, Git, pre-commit 4.6.2, PR work | `rosdep`, `catkin_tools`, `roslint`, unit tests, ROS runtime |

Keep Git commits on the host if you want the host-installed pre-commit hook to execute; mount the source into the container for ROS builds/tests.

## Noetic validation (inside its workspace/container)

```bash
source /opt/ros/noetic/setup.bash
cd /path/to/catkin_ws
catkin build
catkin test
catkin_test_results --verbose
```

## Melodic validation (inside its workspace/container)

```bash
source /opt/ros/melodic/setup.bash
cd /path/to/catkin_ws
catkin build
catkin run_tests
catkin_test_results --verbose
```

`industrial_ci` is authoritative in CI and also runs `catkin_lint` and `clang-tidy`, with Python error checks for Noetic. Respect existing package-level `roslint` tests.

**Do not** mass-apply `ament_uncrustify`, modern Python formatters or large formatting-only changes to legacy ROS1 code. Maintain Python2 compatibility where required.
