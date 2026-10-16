# Aperion Robotics — Developer Handbook

A practical onboarding and CI handbook for the ARISTOS, BlueBOT and shared engineering repositories.

> **Rollout:** Central CI has passed Melodic, Noetic and Lyrical pilot tests; PR [#3](https://github.com/aperion-robotics/.github/pull/3) remains subject to review. Production activation is phased. Check the current central README for the live policy.

## Quick start

1. [Understand the CI policy](ci-policy.md).
2. [Prepare the workstation](workstation.md), including host-side pre-commit.
3. [Configure VS Code](vscode.md).
4. Use the [ROS1](ros1.md) or [ROS2](ros2.md) instructions.
5. Add [repository CI files](repository-ci-files.md) if the repository has source dependencies or needs CI options.
6. Follow the [PR checklist](pull-requests.md).

Reference repositories `ci-pilot-*` to study and understand most of the workflow requirements.

Central CI is authoritative; local checks shorten the feedback loop.
