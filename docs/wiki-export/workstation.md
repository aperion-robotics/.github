# Workstation and Pre-commit

**Install VS Code, Git and pre-commit on the Ubuntu host** for both ROS1 and ROS2. Build and test ROS1 code inside the matching container. The approved `pre-commit==4.6.2` needs Python 3.10+ and Git 2.31+, so it is not suitable for stock Melodic/Noetic containers.

## 1. Install host tools

```bash
sudo apt update
sudo apt install -y git curl jq pipx shellcheck
pipx ensurepath
# Open a new terminal if ~/.local/bin is not on PATH
pipx install pre-commit==4.6.2
pre-commit --version
```

## 2. Obtain the central pre-commit configuration

After central CI PR #3 is merged, use `main`:

```bash
mkdir -p ~/.config/aperion
git clone https://github.com/aperion-robotics/.github.git ~/.config/aperion/dot-github
pre-commit validate-config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml
```

If you already cloned it:

```bash
git -C ~/.config/aperion/dot-github pull --ff-only
```

Before merge, maintainers evaluating the candidate may explicitly use `ci/final-ci-configuration`; it is **not** the general rollout ref.

## 3. Install the hook per local repository

```bash
cd /path/to/aperion-repository
pre-commit install --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml --install-hooks
test -x .git/hooks/pre-commit && echo 'Aperion pre-commit hook installed'
```

When `git commit` is executed **on the host**, the hook checks staged files. A container-only commit may bypass the host hook.

## 4. Manual checks

```bash
# Staged changes
pre-commit run --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml

# Whole repository — occasional adoption/review check
pre-commit run --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml --all-files --show-diff-on-failure

# Changes against default branch
git fetch origin
pre-commit run --config ~/.config/aperion/dot-github/ci/precommit/baseline.yaml --from-ref origin/main --to-ref HEAD --show-diff-on-failure
```

Replace `origin/main` if needed. If a hook edits files, inspect `git diff`, stage the result again and retry commit. Avoid `sudo pip install`, `git commit --no-verify` and `pre-commit autoupdate` without central review.

**Further reading:** [pre-commit developer reference](https://github.com/aperion-robotics/.github/blob/main/docs/developer/pre-commit.md).
