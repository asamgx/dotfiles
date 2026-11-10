#!/usr/bin/env node
// Claude Code status line: git info on the first line, session stats on the second.
// Reads the status line JSON from stdin; only shells out to git, no network.
//
//   branch:main ↑1 | !2 +1 ?3
//   Opus 5.5 | effort:high | 5h:[#-------]9%(0h45m) wk:[##------]23%(3d15h) | session:1h13m | ctx:[#---------]14% | 🔧37 🤖3

import { execFileSync } from "node:child_process";
import { closeSync, mkdirSync, openSync, readFileSync, readSync, statSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const c = {
  dim: (s) => `\x1b[2m${s}\x1b[0m`,
  bold: (s) => `\x1b[1m${s}\x1b[0m`,
  cyan: (s) => `\x1b[36m${s}\x1b[0m`,
  green: (s) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s) => `\x1b[33m${s}\x1b[0m`,
  red: (s) => `\x1b[31m${s}\x1b[0m`,
};
const SEP = c.dim(" | ");

function byLevel(pct, warn, crit) {
  return pct >= crit ? c.red : pct >= warn ? c.yellow : c.green;
}

function bar(pct, width, color) {
  const filled = Math.max(0, Math.min(width, Math.round((pct / 100) * width)));
  return `[${color("#".repeat(filled))}${c.dim("-".repeat(width - filled))}]`;
}

function until(epochSeconds) {
  const mins = Math.max(0, Math.round((epochSeconds * 1000 - Date.now()) / 60000));
  if (mins >= 1440) return `${Math.floor(mins / 1440)}d${Math.floor((mins % 1440) / 60)}h`;
  return `${Math.floor(mins / 60)}h${mins % 60}m`;
}

function gitLine(cwd) {
  let out;
  try {
    out = execFileSync("git", ["status", "--porcelain=v2", "--branch"], {
      cwd,
      encoding: "utf8",
      timeout: 1000,
      stdio: ["ignore", "pipe", "ignore"],
    });
  } catch {
    return null;
  }
  let branch = "";
  let ab = "";
  let staged = 0;
  let modified = 0;
  let untracked = 0;
  for (const line of out.split("\n")) {
    if (line.startsWith("# branch.head ")) branch = line.slice(14);
    else if (line.startsWith("# branch.ab ")) {
      const [ahead, behind] = line.slice(12).split(" ").map((n) => Math.abs(Number(n)));
      ab = `${ahead ? ` ↑${ahead}` : ""}${behind ? ` ↓${behind}` : ""}`;
    } else if (line.startsWith("1 ") || line.startsWith("2 ") || line.startsWith("u ")) {
      const xy = line.split(" ")[1];
      if (xy[0] !== ".") staged++;
      if (xy[1] !== ".") modified++;
    } else if (line.startsWith("? ")) untracked++;
  }
  const status = [
    modified && c.yellow(`!${modified}`),
    staged && c.green(`+${staged}`),
    untracked && c.dim(`?${untracked}`),
  ].filter(Boolean);
  const head = `${c.dim("branch:")}${c.cyan(branch)}${ab && c.dim(ab)}`;
  return status.length ? head + SEP + status.join(" ") : head;
}

// Counts tool and agent calls in the transcript. Only the bytes appended since
// the last refresh are read; the running totals are cached per session.
function callCounts(sessionId, transcriptPath) {
  if (!sessionId || !transcriptPath) return null;
  const dir = join(tmpdir(), "claude-statusline");
  const cacheFile = join(dir, `${sessionId}.json`);
  let cache = { offset: 0, tools: 0, agents: 0 };
  try {
    cache = JSON.parse(readFileSync(cacheFile, "utf8"));
  } catch {}
  let size;
  try {
    size = statSync(transcriptPath).size;
  } catch {
    return null;
  }
  if (size < cache.offset) cache = { offset: 0, tools: 0, agents: 0 };
  if (size > cache.offset) {
    const buf = Buffer.alloc(size - cache.offset);
    const fd = openSync(transcriptPath, "r");
    readSync(fd, buf, 0, buf.length, cache.offset);
    closeSync(fd);
    const text = buf.toString("utf8");
    // Stop at the last complete line so a half-written entry is re-read next time.
    const end = text.lastIndexOf("\n") + 1;
    for (const line of text.slice(0, end).split("\n")) {
      if (!line.includes('"tool_use"')) continue;
      let entry;
      try {
        entry = JSON.parse(line);
      } catch {
        continue;
      }
      for (const part of entry.message?.content ?? []) {
        if (part.type !== "tool_use") continue;
        if (part.name === "Agent" || part.name === "Task") cache.agents++;
        else cache.tools++;
      }
    }
    cache.offset += Buffer.byteLength(text.slice(0, end));
    try {
      mkdirSync(dir, { recursive: true });
      writeFileSync(cacheFile, JSON.stringify(cache));
    } catch {}
  }
  return cache;
}

function mainLine(input) {
  const parts = [];

  const model = input.model?.display_name?.replace(/\s*\(.*\)$/, "");
  if (model) parts.push(c.bold(model) + (input.fast_mode ? c.yellow(" fast") : ""));

  if (input.effort?.level) parts.push(`${c.dim("effort:")}${input.effort.level}`);

  const limits = [];
  for (const [key, label] of [["five_hour", "5h"], ["seven_day", "wk"]]) {
    const limit = input.rate_limits?.[key];
    if (limit?.used_percentage == null) continue;
    const pct = Math.round(limit.used_percentage);
    const color = byLevel(pct, 70, 90);
    const reset = limit.resets_at ? c.dim(`(${until(limit.resets_at)})`) : "";
    limits.push(`${c.dim(`${label}:`)}${bar(pct, 8, color)}${color(`${pct}%`)}${reset}`);
  }
  if (limits.length) parts.push(limits.join(" "));

  const ms = input.cost?.total_duration_ms;
  if (ms != null) {
    const mins = Math.round(ms / 60000);
    parts.push(`${c.dim("session:")}${mins >= 60 ? `${Math.floor(mins / 60)}h${mins % 60}m` : `${mins}m`}`);
  }

  const ctx = input.context_window?.used_percentage;
  if (ctx != null) {
    const pct = Math.round(ctx);
    const color = byLevel(pct, 70, 85);
    parts.push(`${c.dim("ctx:")}${bar(pct, 10, color)}${color(`${pct}%`)}`);
  }

  const counts = callCounts(input.session_id, input.transcript_path);
  if (counts && (counts.tools || counts.agents)) parts.push(`🔧${counts.tools} 🤖${counts.agents}`);

  return parts.join(SEP);
}

let input = {};
try {
  input = JSON.parse(readFileSync(0, "utf8"));
} catch {}

const cwd = input.workspace?.current_dir ?? input.cwd ?? process.cwd();
const lines = [gitLine(cwd), mainLine(input)].filter(Boolean);
process.stdout.write(lines.join("\n"));
