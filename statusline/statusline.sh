#!/usr/bin/env python3
import json
import os
import sys
import time

data = json.load(sys.stdin)

model = data.get("model", {}).get("display_name", "?")
ctx = data.get("context_window") or {}
ctx_pct = ctx.get("used_percentage")
rl = data.get("rate_limits") or {}
five_h = rl.get("five_hour") or {}
seven_d = rl.get("seven_day") or {}

snapshot = {
    "written_at": time.time(),
    "model": model,
    "context_used_percentage": ctx_pct,
    "rate_limits": {
        "five_hour": {
            "used_percentage": five_h.get("used_percentage"),
            "resets_at": five_h.get("resets_at"),
        },
        "seven_day": {
            "used_percentage": seven_d.get("used_percentage"),
            "resets_at": seven_d.get("resets_at"),
        },
    },
}

snapshot_path = os.path.expanduser("~/.claude/rate-limit-status.json")
try:
    tmp_path = snapshot_path + ".tmp"
    with open(tmp_path, "w") as f:
        json.dump(snapshot, f)
    os.replace(tmp_path, snapshot_path)
except OSError:
    pass

parts = [f"[{model}]"]
if ctx_pct is not None:
    parts.append(f"ctx {int(ctx_pct)}%")
if five_h.get("used_percentage") is not None:
    parts.append(f"5h {int(five_h['used_percentage'])}%")
if seven_d.get("used_percentage") is not None:
    parts.append(f"7d {int(seven_d['used_percentage'])}%")
print(" | ".join(parts))
