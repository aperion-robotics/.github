# VS Code and EditorConfig

VS Code is supported but not mandatory. Use global settings for safe whitespace behavior and workspace settings for ROS-specific formatting.

## Recommended extensions

```bash
code --install-extension editorconfig.editorconfig
code --install-extension ms-vscode.cpptools
code --install-extension ms-vscode.cmake-tools
code --install-extension ms-python.python
code --install-extension redhat.vscode-yaml
code --install-extension redhat.vscode-xml
code --install-extension GitHub.vscode-github-actions
code --install-extension timonwong.shellcheck
# Optional ROS2 Python convenience and ROS integration
code --install-extension ms-python.autopep8
code --install-extension ms-iot.vscode-ros
```

## Global settings

In **Ctrl+Shift+P → Preferences: Open User Settings (JSON)**, merge:

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

Do not enable a global C++ formatter or Python format-on-save: ROS1 and ROS2 use different conventions. `.editorconfig` handles indentation, LF, trailing whitespace and final newline.

## ROS2-only workspace

For Python convenience formatting, create `.vscode/settings.json` in a **ROS2-only** workspace:

```json
{
  "ros.distro": "lyrical",
  "[python]": {
    "editor.defaultFormatter": "ms-python.autopep8",
    "editor.formatOnSave": true
  },
  "autopep8.args": ["--max-line-length", "99"]
}
```

`autopep8` is not equivalent to `ament_flake8` and `ament_pep257`. C++ should use the ROS2-provided `ament_uncrustify` intentionally, not competing automatic formatters. Prefer explicit VS Code tasks over format-on-save during initial rollout.

For ROS1, keep formatting conservative and preserve Python2 compatibility where applicable.

**Further reading:** [VS Code tasks and setup](https://github.com/aperion-robotics/.github/blob/main/docs/developer/vscode.md), [EditorConfig](https://github.com/aperion-robotics/.github/blob/main/docs/developer/editorconfig.md).
