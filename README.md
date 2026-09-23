# opus-orchestration

A [Claude Code](https://claude.com/claude-code) skill and agent presets for running a **Claude Pro + ChatGPT Plus** stack cost-effectively: Opus orchestrates, and cheaper models do the work.

| Tier | Where it runs | Role |
|---|---|---|
| **Opus** | main Claude Code session | Classifies tasks, writes specs, synthesizes results. The only dispatcher. |
| **Luna** (`gpt-6-luna`) | Codex CLI | Default executor for simple and medium work: bulk, research, exploration, scoped implementation. |
| **Sol** (`gpt-6-sol`) | Codex CLI | Precision execution against a complete spec. |
| **Astra** (`gpt-6-astra`) | Codex CLI | Hard reasoning only. It burns quota fastest. |
| **Sonnet** | `sonnet-worker` preset | Claude-side tools, second-opinion review, fallback when GPT fails. |
| **Haiku** | `haiku-worker` preset | Fallback only, for simple work when GPT is unavailable. |

Key ideas:

- **Delegation is one level deep.** Only Opus dispatches work, so every call is auditable.
- **Claude quota is read live.** `statusline.sh` writes it to `~/.claude/rate-limit-status.json` on every message, and Sonnet use is gated on it.
- **Routing follows data.** It is based on published benchmarks and a small Luna-vs-Sonnet head-to-head (see "Benchmark basis" and rule 5 in `SKILL.md`).

The tier labels in the skill are Turkish: **basit** = simple, **orta** = medium, **zor** = hard.

## Contents

```
skills/opus-orchestration/SKILL.md   the policy (loaded as a Claude Code skill)
agents/sonnet-worker.md              Sonnet preset
agents/haiku-worker.md               Haiku fallback preset
statusline/statusline.sh             statusLine hook that snapshots quota usage
install.sh                           symlinks everything into ~/.claude
```

## Install

Requirements: Claude Code on a Pro or Max plan (Pro/Max accounts are the only ones that expose `rate_limits`), [Codex CLI](https://github.com/openai/codex) signed in with ChatGPT, and Python 3.

```bash
git clone https://github.com/<you>/opus-orchestration.git
cd opus-orchestration
./install.sh
```

`install.sh` symlinks the files into `~/.claude`, moving any existing files aside to `*.bak.<timestamp>` first. Because they are symlinks, edits from either side show up in `git diff`.

Then enable the status line in `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

## Adapting it

Model IDs, quota thresholds (60% / 70% / 85%), and benchmark numbers reflect one account as of September 2026. Check `codex` → `/model` for the IDs available to you, and tune the thresholds to your own usage.
