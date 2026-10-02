# Contributing

Thank you for helping. The most useful contributions are reports from real use: a step in the README that did not work, a command the guard blocked although it was harmless, or one it let through although it was not.

## Issues

Open an issue with one of the templates. For a guard decision, include the exact command, what you expected (blocked or allowed), what happened, and your OS. For anything security-related, follow [SECURITY.md](SECURITY.md) instead.

## Pull requests

This repository is published from a private source repository by a script that checks every file before it goes out. Pull requests are therefore not merged here directly. If you open one, we read it, carry good changes over by hand, and credit you in the release notes. Small, focused changes are the easiest to carry over.

## Before you propose a change to a hook

Run the test matrices and keep them passing:

```bash
cd blueprint/hooks
bash block-dangerous-commands.matrix.sh ./block-dangerous-commands.sh
bash defer-to-project.matrix.sh
```

For a change to the command guard, add a case to `block-dangerous-commands.matrix.sh` that fails before your change and passes after it.

## Style

Plain words for non-developers. Short sentences. No hype. Every example (company, person, number) is fictional.

By contributing you agree that your contribution is licensed under the MIT licence of this repository, and to follow the [code of conduct](CODE_OF_CONDUCT.md).
