# CKS Prep 2026

Hands-on CKS practice labs based on the two YouTube playlists below and checked
against the current CNCF CKS curriculum.

- 2026 playlist: https://www.youtube.com/playlist?list=PLyKswBedEWujChLpKK6zFj0S4MOUaxqR3
- Killer Shell playlist: https://www.youtube.com/playlist?list=PLpbwBK0ptssx38770vYNwZEuCeGNw54CH
- Official curriculum: https://github.com/cncf/curriculum

This repository uses the same simple convention as CKA-PREP-2026. Every lab
folder contains:

- `LabSetUp.bash` - creates or resets the practice scenario.
- `Questions.bash` - prints the task and source video.
- `SolutionNotes.bash` - prints a concise solution and verification steps.

The questions are paraphrased practice scenarios. They are not exam dumps and
must not be treated as a prediction of live exam content.

## Quick Start

Use a disposable cluster such as the Killercoda Kubernetes playground. Some
host-security labs require a kubeadm-style control plane or a purpose-built
environment; check `ENVIRONMENTS.md` before starting.

```bash
git clone https://github.com/BradleyDavel/CKS-PREP-2026.git
cd CKS-PREP-2026
source scripts/aliases.sh

qlist
q1
q2
s1
qrandom
```

This loads `q1` through `q27` for questions and `s1` through `s27` for
solutions in the current terminal. To install the aliases for future Bash
sessions:

```bash
bash scripts/install-aliases.sh
source ~/.bashrc
```

You can still use the runner directly:

```bash
bash scripts/run-question.sh list
bash scripts/run-question.sh 4
bash scripts/run-question.sh "Question-13 Metadata-NetworkPolicy"
bash scripts/run-question.sh random
```

The runner applies the setup and prints the task. Reveal the answer only when
needed:

```bash
bash "Question-13 Metadata-NetworkPolicy/SolutionNotes.bash"
```

## Tracks

- `Question-01` through `Question-22`: complete Killer Shell playlist track.
- `Question-23` through `Question-27`: scenarios publicly verifiable from the
  newer 2026 playlist as of June 15, 2026.

Several videos in the newer playlist are private. They are intentionally not
reconstructed from guesses. Add them only when their scenario details become
public and can be validated.

## Exam Coverage

The current official CKS domains are:

| Domain | Weight |
|---|---:|
| Cluster Setup | 15% |
| Cluster Hardening | 15% |
| System Hardening | 10% |
| Minimize Microservice Vulnerabilities | 20% |
| Supply Chain Security | 20% |
| Monitoring, Logging and Runtime Security | 20% |

See `CURRICULUM-MAP.md` for lab-to-domain coverage. The exam is broader than
any single playlist, so the map also calls out areas that deserve extra study.

## Question Aliases

```bash
source scripts/aliases.sh
```

Examples:

```bash
q1       # Run Question 1 setup and print the task
q13      # Run Question 13
s1       # Show the solution for Question 1
s13      # Show the solution for Question 13
qlist    # List all questions and environment levels
qrandom  # Pick a random question
```

The aliases use the actual clone location, so the repository does not have to
be stored under a particular home-directory path.
