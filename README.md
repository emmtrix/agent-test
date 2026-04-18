# agent-test

Minimal public repro repository for GitHub Copilot cloud agent behavior with
job containers on official GitHub-hosted runners.

## Purpose

This repository isolates one question:

- Does a Copilot cloud agent session show live session output when
  `.github/workflows/copilot-setup-steps.yml` uses a real job `container:`?

It also contains a normal Actions workflow using the same container so regular
Actions logs can be compared against Copilot session logs.

## Included Workflows

- `.github/workflows/copilot-setup-steps.yml`
  Minimal Copilot setup workflow with `runs-on: ubuntu-latest` and
  `container: mcr.microsoft.com/devcontainers/base:ubuntu-24.04`.
- `.github/workflows/container-smoke.yml`
  Normal Actions workflow using the same runner and container.

## Suggested Repro

1. Start a Copilot coding agent session against this repository.
2. Ask the agent to make a tiny visible change such as adding one line to
   `notes.txt`.
3. Check whether the Copilot session UI shows live output.
4. Compare that with the normal Actions run logs from `container-smoke.yml`.
