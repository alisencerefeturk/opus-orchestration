# opus-orchestration

A [Claude Code](https://claude.com/claude-code) skill and agent presets for running a **Claude Pro + ChatGPT Plus** stack cost-effectively: Opus orchestrates, and cheaper models do the work.

> **Claude Code only.** This needs Claude Code as the host. It won't work if you load it in Codex, Antigravity, or other agents. See [Compatibility](#compatibility).

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

### Option A: let Claude Code install it (easiest)

Paste this into a Claude Code session:

````text
Install the opus-orchestration skill from https://github.com/alisencerefeturk/opus-orchestration for me:

1. Clone the repo to ~/opus-orchestration. If that folder already exists and is this repo, run `git pull` in it instead.
2. Run ./install.sh from the repo. It symlinks the skill, the agent presets, and statusline.sh into ~/.claude and backs up any existing files first.
3. Add "statusLine": {"type": "command", "command": "~/.claude/statusline.sh"} to ~/.claude/settings.json. Merge it and keep every other setting as is. If a different statusLine is already configured, show it to me and ask before replacing it.
4. Check the prerequisites and report each one: `python3 --version`, `codex --version`, and whether Codex is logged in (`codex login status`). If something is missing, tell me how to fix it, but don't install it yourself.
5. Tell me to restart Claude Code, then summarize what was installed and anything I still need to do by hand.
````

### Option B: manual

```bash
git clone https://github.com/alisencerefeturk/opus-orchestration.git
cd opus-orchestration
./install.sh
```

`install.sh` symlinks the files into `~/.claude`, moving any existing files to `~/.claude/backups/opus-orchestration-<timestamp>/` first. Because they are symlinks, edits from either side show up in `git diff`.

Then enable the status line in `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh" }
```

## Compatibility

| Host | Works? | Why |
|---|---|---|
| **Claude Code** (CLI, desktop, IDE extensions) | ✅ | This is what it was built for. |
| **OpenAI Codex CLI / ChatGPT** | ❌ | In this setup Codex is a worker that Claude Code calls, not the host. |
| **Google Antigravity, Cursor, other agents** | ❌ | They have no equivalent of the Claude Code features listed below. |

The policy relies on four Claude Code features:

- the `Agent` tool and `~/.claude/agents/` presets, for dispatching `sonnet-worker` and `haiku-worker`;
- the `statusLine` hook, which provides `rate_limits` for live quota checks;
- Opus running as the top-level session model;
- Claude Code's skill loader.

Another agent might be able to read `SKILL.md` as plain text, but it can't apply the routing. The general ideas carry over to other stacks: a scarce orchestrator, cheap default workers, one-level delegation, and routing gated on quota. The implementation doesn't.

## Adapting it

Model IDs, quota thresholds (60% / 70% / 85%), and benchmark numbers reflect one account as of September 2026. Check `codex` → `/model` for the IDs available to you, and tune the thresholds to your own usage.

## License

MIT — see [LICENSE](LICENSE).
