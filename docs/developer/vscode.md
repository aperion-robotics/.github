# Visual Studio Code

Recommended Visual Studio Code setup for Aperion Robotics development.

The goal is to catch syntax, formatting, whitespace, configuration, and workflow issues as early as possible while keeping GitHub CI as the authoritative validation layer.

VS Code is a supported development environment, not a mandatory one.

## Recommended extensions

Install the baseline extensions:

```bash
code --install-extension editorconfig.editorconfig
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.cmake-tools
code --install-extension ms-python.python
code --install-extension redhat.vscode-yaml
code --install-extension redhat.vscode-xml
code --install-extension GitHub.vscode-github-actions
code --install-extension timonwong.shellcheck
```

Recommended for ROS 2 Python development:

```bash
code --install-extension ms-python.autopep8
```

Optional ROS integration:

```bash
code --install-extension ms-iot.vscode-ros
```

Optional ROS 2 format-on-save support:

```bash
code --install-extension emeraldwalk.RunOnSave
```

Do not install an additional C++ formatter globally unless it is explicitly configured to use the same ROS 2 formatting rules as CI.

## Why these extensions

| Extension | Purpose |
|---|---|
| `editorconfig.editorconfig` | line endings, indentation, final newline, whitespace |
| `ms-vscode.cpptools` | C/C++ IntelliSense, navigation, diagnostics |
| `ms-vscode.cmake-tools` | CMake configure/build integration and diagnostics |
| `ms-python.python` | Python language support |
| `ms-python.autopep8` | optional ROS 2 Python formatting convenience |
| `redhat.vscode-yaml` | YAML validation |
| `redhat.vscode-xml` | XML validation for `package.xml`, URDF, launch XML |
| `GitHub.vscode-github-actions` | GitHub Actions schema validation and completion |
| `timonwong.shellcheck` | shell-script diagnostics |
| `ms-iot.vscode-ros` | optional ROS workspace integration |
| `emeraldwalk.RunOnSave` | optional external command execution after save |

## Base user settings

These settings are safe to use globally:

```json
{
  "files.eol": "\n",
  "files.insertFinalNewline": true,
  "files.trimTrailingWhitespace": true,
  "editor.formatOnSave": false,
  "yaml.validate": true,
  "xml.validation.enabled": true,
  "shellcheck.enable": true,
  "shellcheck.run": "onType"
}
```

Do not configure a global C/C++ formatter.

Do not configure a global Python formatter.

Language-specific formatting should be enabled at workspace level so ROS 1 and ROS 2 repositories can use different policies safely.

Repository `.editorconfig` settings should be treated as the first source of truth for whitespace, indentation, line endings, and final-newline behavior.

# ROS 2 Jazzy workspace

The primary ROS 2 target is:

- Ubuntu 24.04 Noble
- ROS 2 Jazzy

For ROS 2 C/C++ formatting, use the ROS-provided `ament_uncrustify`.

Do not use `clang-format` as a competing formatter unless the repository has explicitly adopted it.

## ROS 2 workspace settings

Create:

```text
.vscode/settings.json
```

with:

```json
{
  "ros.distro": "jazzy",
  "[python]": {
    "editor.defaultFormatter": "ms-python.autopep8",
    "editor.formatOnSave": true
  },
  "autopep8.args": [
    "--max-line-length",
    "99"
  ]
}
```

This keeps Python auto-formatting local to ROS 2 workspaces instead of applying it to ROS 1 repositories.

## ROS 2 C/C++ formatting

Check formatting:

```bash
source /opt/ros/jazzy/setup.bash
ament_uncrustify <file>
```

Apply formatting:

```bash
source /opt/ros/jazzy/setup.bash
ament_uncrustify --reformat <file>
```

The package test suite and GitHub CI remain authoritative.

## Recommended `.vscode/tasks.json`

Create:

```text
.vscode/tasks.json
```

with:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Aperion: Format current ROS2 C/C++ file",
      "type": "shell",
      "command": "bash",
      "args": [
        "-lc",
        "source /opt/ros/jazzy/setup.bash && ament_uncrustify --reformat \"${file}\""
      ],
      "problemMatcher": []
    },
    {
      "label": "Aperion: Check current ROS2 C/C++ file",
      "type": "shell",
      "command": "bash",
      "args": [
        "-lc",
        "source /opt/ros/jazzy/setup.bash && ament_uncrustify \"${file}\""
      ],
      "problemMatcher": []
    },
    {
      "label": "Aperion: ROS2 Python flake8",
      "type": "shell",
      "command": "bash",
      "args": [
        "-lc",
        "source /opt/ros/jazzy/setup.bash && ament_flake8 \"${file}\""
      ],
      "problemMatcher": []
    },
    {
      "label": "Aperion: ROS2 Python pep257",
      "type": "shell",
      "command": "bash",
      "args": [
        "-lc",
        "source /opt/ros/jazzy/setup.bash && ament_pep257 \"${file}\""
      ],
      "problemMatcher": []
    },
    {
      "label": "Aperion: Run baseline pre-commit",
      "type": "shell",
      "command": "bash",
      "args": [
        "-lc",
        "pre-commit run --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml --all-files"
      ],
      "problemMatcher": []
    }
  ]
}
```

Run tasks from:

```text
Terminal
-> Run Task
```

## Optional ROS 2 format-on-save

Automatic C/C++ formatting on save should remain optional.

Only enable it in ROS 2-only workspaces.

Install:

```bash
code --install-extension emeraldwalk.RunOnSave
```

Then add to the ROS 2 workspace `.vscode/settings.json`:

```json
{
  "emeraldwalk.runonsave": {
    "commands": [
      {
        "match": "\\.(c|cc|cpp|cxx|h|hh|hpp|hxx)$",
        "cmd": "bash -lc 'source /opt/ros/jazzy/setup.bash && ament_uncrustify --reformat \"${file}\"'"
      }
    ]
  }
}
```

Do not place this in global VS Code user settings.

Manual task-based formatting is preferred during the initial rollout because it is more explicit and easier to troubleshoot.

## ROS 2 Python

`autopep8` is a convenience formatter, not the authoritative CI policy.

Validate Python with the ROS tools:

```bash
source /opt/ros/jazzy/setup.bash
ament_flake8 path/to/python
ament_pep257 path/to/python
```

or run the full package tests:

```bash
colcon test
colcon test-result --verbose
```

A file may be auto-formatted successfully and still fail `ament_flake8` or `ament_pep257`.

## GitHub Actions

Use:

```bash
code --install-extension GitHub.vscode-github-actions
```

for workflow completion and schema validation.

For the central Aperion `.github` repository, command-line validation remains:

```bash
actionlint .github/workflows/*.yml
```

## YAML

Use the Red Hat YAML extension for validation.

Recommended:

```json
{
  "yaml.validate": true
}
```

Do not enable mandatory YAML format-on-save globally.

The objective is to detect invalid YAML, not automatically rewrite ROS configuration files or GitHub workflows.

## XML

Use the Red Hat XML extension.

Recommended:

```json
{
  "xml.validation.enabled": true
}
```

Useful for:

- `package.xml`
- URDF
- Xacro XML
- ROS 1 XML launch files

## Shell scripts

Install ShellCheck:

```bash
sudo apt install shellcheck
```

Recommended VS Code settings:

```json
{
  "shellcheck.enable": true,
  "shellcheck.run": "onType"
}
```

# ROS 1 development

ROS 1 Melodic and Noetic repositories are legacy compatibility targets.

The priority is to preserve existing behavior while improving quality without creating unnecessary formatting churn.

Use a ROS 1-specific workspace configuration.

Example for Noetic:

```json
{
  "ros.distro": "noetic"
}
```

For Melodic, use the corresponding legacy ROS environment or Aperion container/devcontainer.

## ROS 1 — what not to do

Do **not** apply ROS 2 formatting rules automatically to ROS 1 repositories.

### Do not enable ROS 2 `ament_uncrustify` format-on-save

Do not use:

```bash
ament_uncrustify --reformat
```

against ROS 1 source trees unless a repository has explicitly adopted those rules.

ROS 1 repositories may have an established formatting history that differs from ROS 2 conventions.

### Do not configure a global C++ formatter

Avoid global settings such as:

```json
{
  "[cpp]": {
    "editor.formatOnSave": true
  }
}
```

when the formatter is `clang-format`, Uncrustify, or another formatter whose configuration is not explicitly defined by the ROS 1 repository.

Large formatting-only diffs make reviews harder and create unnecessary merge conflicts.

### Do not enable ROS 2 Python auto-formatting globally

Do not place this in global user settings:

```json
{
  "[python]": {
    "editor.defaultFormatter": "ms-python.autopep8",
    "editor.formatOnSave": true
  }
}
```

because it will also affect ROS 1 repositories.

This is particularly important for ROS Melodic, where Python 2 code may still exist.

### Do not assume Melodic Python is Python 3

ROS Melodic commonly contains Python 2 code.

Do not automatically run modern Python 3-only tools over Melodic source files.

Use the repository's supported Python version and existing test/lint setup.

### Do not replace existing `roslint` policy with ROS 2 lint rules

If a ROS 1 package already uses:

```cmake
roslint_cpp()
roslint_python()
```

keep those checks unless there is an explicit migration plan.

The migration to a new formatter should be a deliberate engineering change, not an accidental side effect of editor configuration.

### Do not mass-format legacy repositories

Avoid commits where functional changes and thousands of formatting changes are mixed together.

If formatting modernization is required:

```text
format-only PR
        ↓
review
        ↓
merge
        ↓
functional PR
```

### Do not develop Melodic directly against an incompatible host environment

Melodic targets Ubuntu 18.04-era dependencies and Python 2.

Prefer a container/devcontainer rather than attempting to retrofit all legacy dependencies onto a modern Ubuntu workstation.

### Do not assume ROS 1 and ROS 2 can share one `.vscode/settings.json`

Keep workspace-level configuration separate.

For example:

```text
aristos_ros1/
└── .vscode/settings.json

aristos_ros2/
└── .vscode/settings.json
```

Do not create a single workspace config that mixes:

```text
ros.distro = noetic
```

with:

```text
ament_uncrustify
ROS2 Python format-on-save
Jazzy environment setup
```

## ROS 1 recommended behavior

Use VS Code mainly for:

- C/C++ IntelliSense
- Python language support
- CMake diagnostics
- YAML/XML validation
- ShellCheck
- EditorConfig
- repository navigation

Use ROS 1 package tooling for authoritative validation:

```text
catkin build
catkin test
roslint
catkin_lint
industrial_ci
```

depending on the repository.

# Before opening a pull request

Run the organization baseline:

```bash
pre-commit run   --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml   --all-files
```

For ROS 2:

```bash
source /opt/ros/jazzy/setup.bash
colcon build
colcon test
colcon test-result --verbose
```

For ROS 1, run the repository's supported catkin build and test procedure in the correct ROS environment.

# Development principle

```text
VS Code diagnostics
        ↓
editor-safe fixes
        ↓
ROS-specific formatter/linter
        ↓
pre-commit
        ↓
local build + tests
        ↓
GitHub CI
        ↓
review
        ↓
merge
```

VS Code should make it easier to pass CI.

It must not define a different coding standard from CI.
