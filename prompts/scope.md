---
title: Scope csu-mcp to my customers
description: Creates a local branch of csu-mcp with a scope.md file controlling which TPIDs, territories, dates and segments the MCP returns.
---

I want to create a local working branch of `csu-mcp` so I can scope the customer list down to just the accounts, territories and date ranges I care about, without affecting anyone else. I am not a developer — please make all code changes yourself without asking me to confirm code-level decisions. Just tell me what you did at the end.

Do the following end-to-end:

1. `cd C:\repos\csu-mcp` (or wherever `/csu-setup` cloned it — find it if not there).
2. `git fetch origin` and make sure `main` is clean. If there are uncommitted changes, stash them with a clear name.
3. Create and check out a new local branch `peter/scoped-customers` off `main` (substitute my own name if I'm not Peter).
4. Create a file `scope.md` at the repo root using the template at the bottom of this prompt. Pre-fill it with placeholders and clear comments so I can edit it later.
5. Add `scope.md` to `.gitignore` so my personal scope is never committed or pushed.
6. Implement a small loader module (e.g. `csu_mcp/scope.py`) that:
   - Parses `scope.md` (front-matter YAML + simple lists under headings is fine — pick whichever is easiest to parse robustly).
   - Exposes helpers like `in_scope_tpid(tpid)`, `in_scope_territory(name)`, `in_scope_date(dt)`, `is_excluded_segment(seg)`.
   - If `scope.md` is missing or empty, behavior is unchanged (everything passes).
7. Wire the loader into every MCP tool that returns accounts, opportunities, milestones, RAIDs, CSPs, or any per-customer data, so results are filtered by the scope before being returned. Apply the date filter to anything with a meaningful date (close date, milestone due, opportunity stage date, etc.). Apply the out-of-scope filter to drop anything matching an excluded sub-segment / industry / motion (e.g. Digital Natives).
8. Run `uv sync` and whatever tests exist (`uv run pytest` if present). Fix anything you broke.
9. Restart the `csu-mcp` MCP server in Clawpilot and verify it's healthy by listing my accounts — the result should now be filtered to my scope.
10. At the end, print: the absolute path to `scope.md`, the branch name, a one-line summary of which tools are now scope-aware, and a sample query I can run to confirm filtering works.

### Template for `scope.md` (create this file, pre-filled with these comments and placeholders)

```markdown
---
# csu-mcp local scope — edit this file to change what your MCP returns.
# Only this machine sees this file (it is gitignored).

# TPIDs you want IN scope. Numeric MSX TPIDs, one per line.
# Find a TPID by asking Clawpilot: "what's the TPID for <customer name>?"
tpids:
  - 10606116   # example: Husqvarna HQ — replace with your accounts
  - 0000000    # add more, remove the examples

# Territories you cover. Free-text, matched case-insensitively.
territories:
  - Sweden CSU
  - Nordics Manufacturing

# Date window. Anything with a date outside this range is filtered out.
# Use ISO dates (YYYY-MM-DD). Leave blank for "no limit on that side".
date_from: 2026-01-01
date_to:   2026-12-31

# Sub-segments / motions / industries to EXCLUDE entirely, even if a TPID matches.
# Case-insensitive substring match against the account's sub-segment / industry.
exclude_segments:
  - Digital Natives
  - SMC
  - Education

# Optional: explicit account names to also include (in case a TPID is unknown).
include_account_names:
  - ""   # e.g. "Volvo Cars"

# Optional: explicit account names to always exclude, even if their TPID is in `tpids`.
exclude_account_names:
  - ""
---

# Notes

Free-form notes for yourself about why this scope looks the way it does.
The MCP ignores anything below the front-matter.
```

Do not push the branch. Do not commit `scope.md`. Make all code changes yourself.

After you're done, remind me how to edit `scope.md` later: it lives at `C:\repos\csu-mcp\scope.md`, I open it in any editor (Notepad, VS Code, MD Viewer), edit the lists, save, and say "reload the csu-mcp scope" to apply.
