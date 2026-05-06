# csu-prompts

Shared Clawpilot prompts for the CSU team. Each `.md` file in [`prompts/`](prompts/) is a self-contained prompt that can be executed via the [`/prompt`](#install) skill.

## Install

One-time install of the `/prompt` skill:

```powershell
iwr https://raw.githubusercontent.com/lowendahl/csu-prompts/main/install.ps1 -UseBasicParsing | iex
```

## Usage

```
/prompt list             # see what's available
/prompt scope            # fetch & execute prompts/scope.md
/prompt show scope       # preview without executing
/prompt <full raw url>   # ad-hoc: fetch any raw md
```

## Add a prompt

1. Drop a new `*.md` file into `prompts/`.
2. Optional YAML front-matter for nicer `/prompt list` output:
   ```yaml
   ---
   title: Scope csu-mcp to my customers
   description: Branches csu-mcp and adds a scope.md filter
   ---
   ```
3. The rest of the file is executed verbatim as the next chat instruction.

Keep prompts **generic** — no real customer names, TPIDs, or secrets. The repo is public.
