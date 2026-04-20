# Copilot Container Log Investigation

This document records the current understanding behind this reproduction
repository.

## Current Repo Layout

This repro now includes a local copy of the build/test container definition
originally developed in `llvm-cpp2c`:

- `docker/build-test-container/Dockerfile`
- `docker/build-test-container/select-ubuntu-mirror.sh`
- `.github/workflows/ghcr-build-test-container.yml`

That makes the image provenance explicit inside this repo and allows changes to
the workflow container and the image build recipe to be tracked together.

## Goal

Determine whether GitHub Copilot cloud agent sessions lose visible session
output when `.github/workflows/copilot-setup-steps.yml` uses a real job
`container:` on an official GitHub-hosted runner.

## Why This Repo Exists

A larger production repository was made to work with Copilot plus a job
container, but remote Copilot agent sessions showed no visible output in the
session UI even though the session itself started and ran.

That larger setup had additional moving parts:

- a custom GHCR image
- a Blacksmith runner instead of `ubuntu-latest`
- custom container `options`
- bind mounts under `/home/runner`
- attempts to emulate GitHub runner assumptions inside the container

This repo strips the scenario down to the smallest practical version so the
question can be tested in isolation on official GitHub-hosted infrastructure.

## Current Repro Shape

Current workflow choices:

- Copilot workflow uses `runs-on: blacksmith-4vcpu-ubuntu-2404`
- Copilot workflow uses `container.image: ghcr.io/emmtrix/agent-test-build-test:latest`
- image build recipe lives in this repo under `docker/build-test-container/`
- image publishing workflow lives in `.github/workflows/ghcr-build-test-container.yml`
- normal comparison workflow still runs on `ubuntu-latest`

The normal comparison workflow `container-smoke.yml` uses the same runner and
container so standard Actions logging can be compared against Copilot session
logging.

## Observations From The Original Investigation

The original repository reached these states successfully:

- container initialization succeeded
- Copilot preparation succeeded
- firewall validation succeeded
- MCP server startup succeeded
- user-configured setup steps all succeeded inside the container

The problematic transition happened later, when the job entered:

- `Processing Request (Linux)`

At that point, the Copilot session UI showed no useful live output.

## Concrete Run Evidence

Observed in the original repository:

- workflow run: `24592941055`
- job: `71917366754`
- workflow name: `Running Copilot cloud agent`
- branch: `copilot/fix-reduced-test-case`

Important observation:

- GitHub's Actions job-logs endpoint for that job returned `404 BlobNotFound`
  while the job was in progress.

That strongly suggests the problem is not only that the session UI is empty.
It suggests the underlying log materialization/persistence path may already be
broken or missing for the Copilot processing phase.

## What Was Tried In The Original Repository

Several hypotheses were tested in the larger repository.

### 1. Broad `/home/runner` bind mount

Reasoning:

- Copilot helper scripts appeared to resolve paths through
  `/home/runner/_work/_temp/...` even with a job container active.

What was tried:

- bind-mounting `/home/runner:/home/runner`

Outcome:

- the containerized setup ran, but Copilot session output was still missing

### 2. Runner-like container environment

Reasoning:

- perhaps Copilot expected specific runner-like assumptions inside the image

What was tried:

- adding a `runner` user
- setting runner-like working directory behavior
- adding `iptables`
- setting `CONTAINER=true`
- adjusting image defaults

Outcome:

- no confirmed recovery of session output

### 3. UID / HOME / capability tuning

Reasoning:

- maybe temp files or log artifacts were created with the wrong ownership or
  helper processes needed extra privileges

What was tried:

- `--user 1001:1001`
- `HOME=/home/runner`
- `--cap-add=NET_ADMIN`
- `--cap-add=NET_RAW`

Outcome:

- no confirmed recovery of session output

### 4. Narrower mount instead of full `/home/runner`

Reasoning:

- a full bind mount may shadow too much of the hosted runner environment

What was tried:

- switching from `/home/runner:/home/runner` to a narrower `_work` mount

Outcome:

- still no confirmed recovery of session output

## Why The Dockerfile Is Probably Not The Main Issue

Public repositories exist whose `copilot-setup-steps.yml` uses a real
`container:` without any obvious Copilot-specific Dockerfile changes.

Examples observed during investigation:

- `justin/dotfiles`
- `raynigon/raylevation`
- `UCLA-PHP/school.epi.abm`
- `bitcoin-sv/bitcoin-sv`
- `intel/torch-xpu-ops`
- `talitahalboth/wip-tests`

Several of those workflows use simple off-the-shelf images or very light custom
images. That weakens the hypothesis that a special package, entrypoint, or
runner bootstrap inside the Dockerfile is required for Copilot session logs.

## Why The Container Build Files Live Here Now

This repo now keeps the container build recipe locally so:

- the workflow no longer depends on an opaque image owned by another repo
- image changes and Copilot workflow changes can be reviewed together
- GHCR pull failures can be separated from Dockerfile/build-definition changes
- the reproduction can be rebuilt from this repo alone

## Current Working Theory

The most likely interpretations at this point are:

1. Copilot cloud agent session logging has a GitHub-side defect for at least
   some containerized setups.
2. A job `container:` may still be partially unsupported or fragile for the
   session-log path even when setup steps themselves run successfully.
3. The issue is less likely to be caused by a missing package in the image and
   more likely to be caused by an incompatibility in GitHub's internal Copilot
   processing/logging path.

## Relevant External References

Useful references gathered during investigation:

- GitHub Docs, customize the agent environment:
  `https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/customize-the-agent-environment`
- GitHub Docs, troubleshoot the cloud agent:
  `https://docs.github.com/en/copilot/how-tos/use-copilot-agents/cloud-agent/troubleshoot-cloud-agent`
- GitHub changelog entry dated March 19, 2026 about more visibility into
  Copilot coding agent sessions:
  `https://github.blog/changelog/2026-03-19-more-visibility-into-copilot-coding-agent-sessions/`

The March 19, 2026 changelog is especially relevant because it explicitly
states that setup-step output should be visible in session logs.

## How To Use This Repo

Recommended test flow:

1. Start a Copilot coding agent session on this repository.
2. Ask the agent to make a tiny visible change, ideally in `notes.txt`.
3. Observe whether the session UI shows live output.
4. Run `container-smoke.yml` manually and compare the normal Actions logs.

## Suggested Next A/B Tests

If this minimal repro still shows no Copilot session output:

1. Remove `container:` entirely and confirm whether Copilot logs appear.
2. Swap the container image to another known public image while keeping the
   workflow otherwise identical.
3. Test a plain `ubuntu:24.04` image.
4. Test a devcontainer base image from a different family.

The key principle is to vary one axis at a time:

- with container vs without container
- image A vs image B
- no extra options vs one extra option

## Interpretation Guidance

If Copilot session logs are missing here too, despite:

- a container image definition that is versioned in the same repo
- normal Actions runs succeeding with the same image
- setup steps reaching completion inside the container

then the evidence against "your custom repo setup is the cause" becomes much
stronger.
