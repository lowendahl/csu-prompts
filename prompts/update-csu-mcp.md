---
title: Update csu-mcp and migrate scope.md to the shared layout
description: Pull the latest csu-mcp from main, retire the old per-branch scope.md, and re-create the shared scope at ~/.copilot/scope.md using the v2 front-matter (tpids/territories/subregion/date window/exclude_segments).
---

I want my local `csu-mcp` to be on the latest `main` and switched over to the **shared scope file** layout (`~/.copilot/scope.md`) that csu-mcp / msx-mcp / esxp-mcp / CSU-Compass all read from. The old per-branch `peter/scoped-customers` style is deprecated. I am not a developer — make all code/config changes yourself, don't ask me to confirm code-level decisions, just tell me what you did at the end.

Do the following end-to-end:

1. **Locate the repo.** `cd C:\repos\csu-mcp` (or wherever `/csu-setup` cloned it — search for it if not there).

2. **Preserve any existing scope.** If a `scope.md` exists at the repo root, read it and remember the values (tpids, territories, date window, exclude_segments, account names). Print the parsed values so I can sanity-check them later.

3. **Get clean.** `git status`. If there are uncommitted changes on the working tree, stash them as `pre-update-csu-mcp-<date>`. If a local branch like `peter/scoped-customers` (or any `*/scoped-customers`) is currently checked out, switch to `main` first.

4. **Update main.**
   - `git fetch origin --prune`
   - `git checkout main`
   - `git pull --ff-only origin main`
   - If there are local commits on `main` that aren't upstream, ask me before rewriting anything; otherwise proceed.

5. **Retire the old scoped branch.** If a local `*/scoped-customers` branch exists, delete it (`git branch -D <name>`). It is no longer needed — scope now lives outside the repo.

6. **Drop the in-repo scope.md.** If `scope.md` exists at the repo root, delete it (`Remove-Item .\scope.md`). It's gitignored so this is just a local cleanup. The repo's own `csu_mcp/scope.py` loader will now find the shared file at `~/.copilot/scope.md` instead.

7. **Create the shared scope file** at `%USERPROFILE%\.copilot\scope.md` if it doesn't exist yet. Use the template at the bottom of this prompt. If you preserved values in step 2, **port them into the new file** (map old field names to new ones — see mapping below). If `~/.copilot/scope.md` already exists, leave it alone but print its path and current parsed contents.

   Field mapping from old → new:
   - `tpids` → `tpids` (unchanged)
   - `territories` (free text like "Sweden CSU") → `territories` as **dotted-glob list** (e.g. `NE.SE.EC.*`, `NE.SE.Ent.PS`). If you can't confidently translate, leave the list empty and add a TODO comment for me.
   - `date_from` / `date_to` → `date_from` / `date_to` (unchanged, ISO YYYY-MM-DD)
   - `exclude_segments` → `exclude_segments` (unchanged)
   - `include_account_names` / `exclude_account_names` → same
   - New field `subregion` (e.g. `"Sweden - Enterprise"`) → set if obvious from the old territories, otherwise leave commented out.

8. **Sync deps and run tests.**
   - `uv sync`
   - `uv run pytest -q` if tests exist. Fix anything you broke. If a test depends on `scope.md` at the repo root, switch it to the shared path or set `CSU_SCOPE_FILE` in the test.

9. **Restart the csu-mcp MCP server in Clawpilot** and verify it picks up the new shared scope. Call the `scope_status` tool and confirm:
   - `active: true`
   - `path` ends with `\.copilot\scope.md`
   - the tpids / territories / subregion / date window match what's in the file.

10. **Sanity query.** Run a small recipe like `list_my_accounts` (or equivalent) and confirm the result is filtered by the new shared scope. Print the count and the first 3 account names.

11. **At the end, print a summary** containing:
    - Latest `main` commit SHA in csu-mcp
    - Path to the active scope file (`~/.copilot/scope.md`)
    - Whether values were ported from an old `scope.md` (yes/no, what)
    - Old branches deleted
    - `scope_status` JSON
    - One-line reminder: "Edit `~/.copilot/scope.md`, save, and say 'reload the csu-mcp scope' to apply."

Do not push anything. Do not commit. This is purely a local update + migration.

### Template for `~/.copilot/scope.md` (create with this shape, prefilled with my values where you can)

```markdown
---
# csu-mcp / msx-mcp / esxp-mcp / CSU-Compass shared scope.
# Only this machine sees this file. Edit, save, then reload.

# TPIDs in scope. Numeric MSX TPIDs.
tpids:
  - 10606116        # example — replace with your accounts
  - 0000000

# Territories. Dotted-glob list (preferred) — '*' means one-or-more chars.
# Examples:
#   NE.SE.EC.*     -> all children of Sweden Enterprise Commercial
#   NE.SE.Ent.PS   -> exact match, no wildcard
territories:
  - NE.SE.EC.*
  - NE.SE.Ent.PS

# Optional raw regex escape hatch, OR'd with the globs above.
territory_regex: ''

# Subregion the recipes default to when they accept a `subregion` param.
subregion: "Sweden - Enterprise"

# Date window. ISO YYYY-MM-DD. Leave a side blank for "no limit".
date_from: 2026-01-01
date_to:   2026-12-31

# Sub-segments / motions / industries to EXCLUDE entirely (case-insensitive substring).
exclude_segments:
  - Digital Natives
  - SMC
  - Education

# Optional explicit overrides
include_account_names: []
exclude_account_names: []
---

# Notes

Free-form notes for yourself. The loader ignores anything below the front-matter.
```

After you're done, remind me: this file lives at `%USERPROFILE%\.copilot\scope.md`. Open it in any editor (Notepad, VS Code, MD Viewer), edit lists, save, and say "reload the csu-mcp scope". The same file is read by msx-mcp, esxp-mcp, and the CSU-Compass data-pipeline — one edit constrains all of them.
