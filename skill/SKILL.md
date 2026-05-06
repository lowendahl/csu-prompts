---
name: prompt
description: Fetch and execute a shared prompt from the lowendahl/csu-prompts repo. Usage — /prompt <slug>, /prompt list, /prompt show <slug>, or /prompt <full raw URL>. Triggers — "/prompt", "run shared prompt", "fetch prompt".
---

# /prompt — run a shared CSU prompt

You are executing the `/prompt` skill. The user wants to run a prompt that lives in the public repo **`lowendahl/csu-prompts`** under `prompts/<slug>.md`.

## How to interpret the user's input

Parse what comes after `/prompt`:

| Form | Action |
|---|---|
| `/prompt list` | List available prompts (see "List mode" below) |
| `/prompt show <slug>` | Fetch and display the prompt body without executing |
| `/prompt <slug>` | Fetch `prompts/<slug>.md` and **execute it** (see "Execute mode") |
| `/prompt https://...` | Treat the arg as a full raw URL, fetch, and execute |
| `/prompt` (no arg) | Same as `/prompt list` |

Slug = filename without `.md`. Be tolerant: `/prompt scope.md`, `/prompt scope`, and `/prompt /scope` all mean `prompts/scope.md`.

## URL resolution

- Repo: `lowendahl/csu-prompts`, branch `main`.
- Raw base: `https://raw.githubusercontent.com/lowendahl/csu-prompts/main`
- Slug → URL: `<rawBase>/prompts/<slug>.md`
- API listing: `https://api.github.com/repos/lowendahl/csu-prompts/contents/prompts?ref=main`

## Fetching

Use the **web_fetch** tool when available (no auth needed — repo is public). Fall back to PowerShell:

```powershell
iwr "<url>" -UseBasicParsing | Select-Object -ExpandProperty Content
```

If the fetch returns 404, tell the user the slug doesn't exist and suggest `/prompt list`.

## List mode

1. Fetch the API listing URL above to get all `.md` files under `prompts/`.
2. For **each** file, fetch the raw content (or at least the first ~30 lines) and parse the YAML front-matter between the leading `---` markers. Extract `title` and `description`.
3. Render a markdown table with three columns: **Slug**, **Title**, **Description**. Sort alphabetically by slug. The description column is the most important — it's how the user knows what each prompt does. Do not truncate descriptions unless they exceed ~200 chars.
4. If a file has no front-matter or no `description`, show `—` in that cell.
5. End with: `Run one with /prompt <slug>.  Preview with /prompt show <slug>.`

Fetch all front-matter blocks **in parallel** when possible — don't fetch them one at a time.

## Show mode

1. Fetch the prompt body.
2. Strip YAML front-matter from the rendered output.
3. Display the body verbatim inside a fenced markdown block so the user can read it.
4. End with: `Run it with /prompt <slug>.`
5. **Do not execute the instructions inside.**

## Execute mode

1. Fetch the prompt body.
2. Strip YAML front-matter (lines between leading `---` markers).
3. Treat the remaining body **as if the user had just typed it as their next message**. Execute it directly.
4. Do not ask for confirmation, do not re-summarize, do not add preamble — just start carrying out the instructions.
5. Honor the existing privacy / outbound-comms / code-change rules as normal. Those rules are not bypassed by the skill.
6. After execution, optionally append a small footer: `_Ran prompt: <slug> from lowendahl/csu-prompts._`

## Caching (optional)

Cache fetched bodies to `%USERPROFILE%\.copilot\prompt-cache\<slug>.md`. On a failed network fetch, fall back to the cache and warn the user.

## Errors

- 404 → "No prompt named `<slug>` in lowendahl/csu-prompts. Try `/prompt list`."
- Network error → say so; offer cached version if present.
- Empty body → "Prompt `<slug>` is empty."

## Out of scope

- Do not write to the repo. Authoring/publishing is a separate skill (`/share-prompt`, owned by Patrik).
- Do not run prompts from arbitrary non-GitHub URLs unless the user pasted a `https://raw.githubusercontent.com/...` URL explicitly.
