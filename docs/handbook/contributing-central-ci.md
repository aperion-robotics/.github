# Contributing to the Central CI Repository

Central CI lives at [`aperion-robotics/.github`](https://github.com/aperion-robotics/.github). Changes to workflows, common scripts, allowlists and policies affect many repositories; treat them as production engineering changes.

## 1. Propose a change

- Open a branch such as `ci/ros2-clang-tidy` and create a PR to `main`.
- Describe affected workflows and why the new check is required.
- Preserve least-privilege `permissions:` and pinned third-party Action SHAs.
- Do not introduce credentials or private robot information into this public repository.
- Update scripts, tests, README and this Handbook alongside behavior changes.

## 2. Validate centrally

- Run the `Central CI Self-Test` workflow and inspect the actionlint, zizmor, shellcheck, script-test and documentation results.
- Ensure its status check, `central CI definition self-test`, is a **required** merge check.
- After editing `docs/handbook/`, run `python3 scripts/docs/build_docs.py` (`mistune==3.3.4`) and commit the regenerated `docs/site/` and `docs/wiki-export/`. The self-test fails when they appear stale.
- Do not interpret ROS workflows skipped inside `.github` as ROS validation; they must be tested in pilot application repositories.

## 3. Configure isolated pilots

- Production rulesets remain on `refs/heads/main` (or the approved release ref).
- Only **pilot** rulesets point to the feature branch under test.
- Scope pilot rulesets to pilot repositories to avoid duplicate required checks from overlapping rulesets.
- Pilot repositories retain the appropriate `ci_managed`, `ci_pilot`, ROS distribution and `codeql_required` properties.
- All central workflows check out their configuration at `${{ github.workflow_sha }}`, so the tested workflow and the central configuration come from the same commit. Never hard-code `main` as a checkout ref.

## 4. Evidence before review approval

- Positive build, tests and linting on each affected ROS distro.
- Private dependency import where relevant, and no-manifest behavior where relevant.
- At least one **negative test** verifying that a real failure blocks merging when changing a merge gate.
- If security settings change, actual CodeQL analysis publication and enforcement tests.
- Record central commit SHA, pilot PR and run URLs, expected outcomes and any exceptions.

## 5. Merge and rollout

After approval and green required checks, merge the central PR, publish the wiki (`python3 scripts/docs/publish_wiki.py --publish`), restore the pilot refs to the approved production ref, run a post-merge smoke test and roll out gradually to real ARISTOS/BlueBOT repositories. Do not silently weaken organization rules to unblock a pilot.

See [CI Testing and Validation](ci-testing.md) for test matrix and commands.
