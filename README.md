# agent-test

Repro repository for GitHub Copilot cloud agent behavior with job containers.
The repo now also carries its own build/test container definition so the setup
is not hidden behind another repository's GHCR image.

## Purpose

This repository isolates one question:

- Does a Copilot cloud agent session show live session output when
  `.github/workflows/copilot-setup-steps.yml` uses a real job `container:`?

It also contains:

- a repo-local GHCR build workflow for the container image used by the repro
- a normal Actions workflow using the same container so regular Actions logs
  can be compared against Copilot session logs

## Investigation Notes

Detailed background, observed behavior, tested hypotheses, and next steps are
captured in [docs/copilot-container-log-investigation.md](docs/copilot-container-log-investigation.md).

## Included Workflows

- `.github/workflows/ghcr-build-test-container.yml`
  Builds and optionally pushes `ghcr.io/emmtrix/agent-test-build-test` from
  `docker/build-test-container/`.
- `.github/workflows/copilot-setup-steps.yml`
  Copilot setup workflow using
  `container: ghcr.io/emmtrix/agent-test-build-test:latest`.
- `.github/workflows/container-smoke.yml`
  Normal Actions workflow using the same runner and container.

## Suggested Repro

1. Start a Copilot coding agent session against this repository.
2. Ask the agent to make a tiny visible change such as adding one line to
   `notes.txt`.
3. Check whether the Copilot session UI shows live output.
4. Compare that with the normal Actions run logs from `container-smoke.yml`.

## Current Container Setup

- build definition lives in `docker/build-test-container/`
- GHCR image name: `ghcr.io/emmtrix/agent-test-build-test`
- Copilot workflow uses `ubuntu-latest` plus the repo-owned image
- normal Actions smoke test also uses `ubuntu-latest` plus the same repo-owned image

This keeps the image definition inside the repro so container changes can be
tracked and rebuilt from this repository alone.
