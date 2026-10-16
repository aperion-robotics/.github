# Daily Git and Pull Request Workflow

1. Create a feature/fix branch; avoid direct pushes to protected default branches.
2. Edit in VS Code, use diagnostics and safe workspace-specific formatting.
3. Run the appropriate ROS build/tests locally when possible.
4. Stage and commit on host; pre-commit checks staged files.
5. Push and create PR; provide problem summary, implementation and verification.
6. Resolve CI failures and review comments; secure the required approval.
7. Merge only after required workflows and applicable code-scanning rules pass.

## Conventional Commit PR titles

```text
feat: add GNSS recovery behavior
fix: handle RTK timeout
refactor: simplify motor state handling
test: cover navigation watchdog
docs: document development setup
ci: add ROS2 static analysis
```

Rules (commitlint): Start with a lowercase type chosen between `build`, `ci`, `chore`, `docs`, `feat`, `fix`, `perf`, `refactor`, `revert`, `style` and `test`. You can optionally scope it (e.g. `fix(move_base_flex): ...`). The subject should not contain a trailing period and be a maximum of 100 characters. Breaking changes as `feat!: ...` or a `BREAKING CHANGE:` footer. The title check is blocking on `production` quality. Each individual commit is linted with the same rules as an advisory check, so keep them in the same format when merging without squash. More info on [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/#specification).

Describe any changes to topics, services, actions, parameters, TF frames and hardware or robot-safety implications. Do not commit keys, passwords, production credentials, customer data or unapproved rosbags.

**Further reading:** [Contribution guidelines](https://github.com/aperion-robotics/.github/blob/main/CONTRIBUTING.md).
