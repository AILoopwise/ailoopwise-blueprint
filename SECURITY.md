# Security policy

The blueprint installs hooks that run before every command Claude Code executes, so a weakness here can matter on someone's machine. Thank you for reporting it privately.

## Reporting a vulnerability

- **Preferred:** GitHub's private reporting. Open the **Security** tab of this repository and choose **Report a vulnerability**.
- **Or by e-mail:** hello@ailoopwise.com, subject "Security: AILoopwise Blueprint".

Please do not open a public issue for a vulnerability.

Useful in a report:

- the file and, if you can, the line;
- for the command guard: the exact command, what you expected (blocked or allowed) and what happened, plus your OS and `bash --version`;
- whether `jq` was installed.

## What counts

- a dangerous command the guard lets through, or a way to switch a guard off;
- an install or sync step that overwrites, deletes or exposes a user's files or settings;
- anything that makes the blueprint run code from a folder the user did not set up with it;
- secrets or personal data in this repository.

## What to expect

We confirm a report within 7 days, and tell you whether and when it will be fixed. Fixes ship as a new release, and the release notes say what changed. There is no bug bounty.

## Supported versions

Only the latest release gets fixes. Update with the steps in the README ("How do I update?").
