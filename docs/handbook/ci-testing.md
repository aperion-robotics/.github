# CI Testing and Validation Playbook

Use disposable **private** pilot repositories to validate features on the PR branch before the central CI PR is merged.

## Pilot matrix

| Pilot | Expected result |
|---|---|
| `ci-pilot-ros1-melodic-app` + private `-dep` | Build, unit tests and lint PASS |
| `ci-pilot-ros1-noetic-app` + private `-dep` | Build, unit tests and lint PASS |
| `ci-pilot-ros2-lyrical-app` + private `-dep` | Build, unit tests and lint PASS |
| ROS2 Lyrical without `.ci/ros2-lyrical.repos` | PASS; App token/import steps SKIPPED |
| Deliberately failing GTest on separate PR | Required CI FAIL; merge BLOCKED |
| Dependency repo not in `ci/source-deps/allowed-repositories.txt` | FAIL before build (when allowlist changed) |
| CodeQL test repository | Supported languages detected, analyses published; thresholds enforced (if configuration changed) |
| Central `ci-self-test.yml` | PASS and REQUIRED |

## Pilot rulesets

Production rulesets must point to the approved central ref; pilot-only rulesets target their own pilot app repositories and reference the central feature branch. Confirm effective rulesets in **Settings → Rules → Rulesets**. All rulesets are additive.

## Running the tests

```bash
# Existing pilot PR checks (use the actual PR number if not #1)
for distro in ros1-melodic ros1-noetic ros2-lyrical; do
  gh pr checks 1 --repo "aperion-robotics/ci-pilot-${distro}-app"
done

# Central PR check (replace number when testing a future PR)
gh pr checks 3 --repo aperion-robotics/.github

# Inspect failure logs
gh run view <run-id> --repo aperion-robotics/<pilot-repository> --log-failed
```

## Negative testing

Introduce a deliberately failing unit test only on a **separate disposable PR**, confirm the required workflow fails and that GitHub blocks merge. Close the PR without merging. For CodeQL test cases, use controlled non-production samples and ensure the alert meets the actual configured merge-protection threshold.

## CodeQL verification

```bash
gh api repos/aperion-robotics/ci-pilot-codeql/languages
gh api repos/aperion-robotics/ci-pilot-codeql/code-scanning/analyses \
  --jq '[.[] | {category, tool: .tool.name, created_at}]'
```

A configured CodeQL scanner with `languages=[]` is not proof of successful analysis. Verify actual published C/C++ and Python analyses.

## Common failures and remedies

| Symptom | Check |
|---|---|
| GitHub App `Invalid keyData` | Org Actions secret contains the complete valid PEM private key; do not disclose it |
| `Cannot locate rosdep definition for [private_dep]` | Ensure the private package appears in an upstream workspace and has been built/installed |
| `undefined reference to main` in a pilot GTest | Link `gtest_main` or provide an explicit `main()` |
| `catkin_lint` missing `CATKIN_DEPENDS roscpp` | Declare ROS runtime dependencies in `catkin_package()` |
| ROS2 `ament_target_dependencies` missing | On Lyrical use exported modern CMake targets / `target_link_libraries()` |
| `target_link_libraries` plain/keyword conflict | Use a consistent signature for each CMake target |
| CodeQL `languages=[]` | Check supported sources exist on the **default branch** and that analyses were published |

## Recording evidence

Every central CI PR should link the exact pilot PR/run URLs, workflow ref/SHA, expected result, observed result, reviewer approval and rollback/rollout plan.
