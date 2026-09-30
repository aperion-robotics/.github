# EditorConfig

EditorConfig provides a common first layer of editor behavior independent of VS Code, Vim, Neovim, or Emacs.

It helps prevent:

- inconsistent line endings
- missing final newline
- trailing whitespace
- inconsistent indentation

## Aperion baseline .editorconfig, aligned with ROS tooling conventions

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{c,cc,cpp,cxx,h,hh,hpp,hxx}]
indent_style = space
indent_size = 2

[*.py]
indent_style = space
indent_size = 4

[*.{yaml,yml}]
indent_style = space
indent_size = 2

[*.xml]
indent_style = space
indent_size = 2

[*.json]
indent_style = space
indent_size = 2

[*.toml]
indent_style = space
indent_size = 2

[CMakeLists.txt]
indent_style = space
indent_size = 2

[*.cmake]
indent_style = space
indent_size = 2

[*.sh]
indent_style = space
indent_size = 4

[Makefile]
indent_style = tab
```

## Important limitation

EditorConfig is not a C++ or Python style authority.

For ROS 2:
- C/C++ formatting and style validation: `ament_uncrustify`
- Python style validation: `ament_flake8`
- Python docstring validation: `ament_pep257`

These checks are normally integrated into the package test suite through `ament_lint_auto` / `ament_lint_common`.

For ROS 1 legacy repositories, retain the established repository style and package-level `roslint` policy.


## VS Code
Install the EditorConfig extension:
```bash
code --install-extension editorconfig.editorconfig
```

## Vim
Vim 9.1 and newer include the EditorConfig plugin in the standard runtime. For older Vim versions, install:

```vim
Plug 'editorconfig/editorconfig-vim'
```

## Neovim
Neovim 0.9 and newer provide built-in EditorConfig support, enabled by default. No additional plugin is required.
