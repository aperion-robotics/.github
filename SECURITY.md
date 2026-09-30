# Security Policy

Security is treated as part of the software development lifecycle at Aperion
Robotics.

Please do not report security vulnerabilities through public GitHub issues,
discussions, or pull requests.

## Reporting a vulnerability

For public repositories that have GitHub Private Vulnerability Reporting
enabled, use **Security -> Report a vulnerability**.

For all other cases, report the vulnerability privately by email:

**info@aperionrobotics.com**

Use the subject:

`Security Vulnerability Report`

Please include, where possible:

- affected repository or product
- affected version or commit
- description of the vulnerability
- steps required to reproduce it
- potential security impact
- proof-of-concept material, if available
- suggested remediation, if known

Do not include active credentials, production secrets, or sensitive customer
data unless explicitly requested through a secure channel.

## Response process

Aperion Robotics will:

1. acknowledge receipt of the report
2. perform an initial technical and security triage
3. determine affected products and versions
4. assess severity and potential impact
5. develop and validate a remediation
6. coordinate disclosure and release of the fix when appropriate

We aim to acknowledge security reports within **2 business days**.

## Coordinated disclosure

Please allow Aperion Robotics reasonable time to investigate and remediate a
reported vulnerability before public disclosure.

For vulnerabilities affecting upstream ROS or third-party software, Aperion
Robotics may coordinate with the relevant upstream security team.

Our vulnerability handling process follows the principles of ROS REP-2006
coordinated vulnerability disclosure.

## Supported software

Security support is focused on currently maintained Aperion Robotics software.

ROS 1 Melodic and ROS 1 Noetic are end-of-life upstream distributions.
Repositories that still depend on these distributions are maintained as legacy
compatibility targets while migration to supported ROS 2 platforms continues.

ROS 2 Jazzy is the primary supported ROS 2 production target.

## Secrets and credentials

Credentials, tokens, private keys, passwords, certificates, and production
configuration containing secrets must never be committed to Git repositories.

Secrets must be stored using approved secret-management mechanisms such as
GitHub Actions secrets, protected GitHub Environments, or the relevant
production secret-management system.

If a real credential is accidentally committed, removing it from Git is not
sufficient. The credential must also be rotated or revoked immediately.
