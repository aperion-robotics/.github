# Aperion Robotics Developer Environment

This directory documents the recommended local development setup for Aperion Robotics repositories.

The objective is simple: catch formatting, syntax, repository-hygiene, and common ROS issues as early as possible, while keeping GitHub CI as the authoritative validation layer.

## Supported editors

- Visual Studio Code
- Vim / Neovim

Editor-specific behavior must never become the only place where a rule is enforced.

## Validation layers

```text
Editor
  |
  |-- syntax / language diagnostics
  |-- whitespace / final newline
  |-- optional format-on-save
  v
Local pre-commit
  |
  |-- generic repository hygiene
  v
ROS-specific local checks
  |
  |-- ROS 1: package tests / roslint / catkin tooling
  |-- ROS 2: ament lint / colcon test
  v
GitHub CI
  |
  |-- authoritative build
  |-- tests
  |-- static analysis
  |-- security checks
  v
Merge
```

## ROS 2 Jazzy

Primary target:

- Ubuntu 24.04 Noble
- ROS 2 Jazzy

For ROS 2 C/C++ formatting use the ROS-provided formatter:

```bash
ament_uncrustify <path>
ament_uncrustify --reformat <path>
```

ROS 2 Python should ultimately pass the package's ament tests, including `ament_flake8` and `ament_pep257` when declared.

## ROS 1 Melodic / Noetic

ROS 1 Melodic and Noetic are maintained as legacy compatibility targets.

Do not automatically apply ROS 2 formatting rules to ROS 1 repositories.

- ROS Melodic uses Python 2 by default.
- ROS Noetic uses Python 3 by default.
- Large automatic formatting changes should be avoided in legacy repositories.
- Existing roslint, package tests, and repository-specific conventions should be preserved.
- Formatting-only migrations should be made as separate, reviewed changes.

## Common workstation tools

```bash
sudo apt update
sudo apt install -y git curl jq pipx shellcheck
pipx ensurepath
pipx install pre-commit
```
For ROS 2 Jazzy:

```bash
source /opt/ros/jazzy/setup.bash
```

## Documentation

- [pre-commit.md](pre-commit.md)
- [editorconfig.md](editorconfig.md)
- [vscode.md](vscode.md)
- [vim.md](vim.md)

Passing editor checks does not mean a change is ready to merge. GitHub CI remains authoritative.
