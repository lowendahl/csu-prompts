---
title: Push Peter's Electron dashboard to private GHE
description: Guides Peter through publishing the current Electron dashboard codebase to a private GitHub Enterprise repository as an initial snapshot.
---

You are helping Peter publish the current Electron dashboard codebase to a repository in his private GitHub Enterprise account. Your goal is to push what is in the working folder now as a safe initial snapshot, without rewriting history, leaking secrets, or changing application behavior.

First collect or confirm these values:

- Local project path for the Electron dashboard.
- GitHub Enterprise host, for example `github.example.com`.
- Repository owner or organization in Peter's private GHE account.
- Repository name.
- Whether the GHE repository already exists. If it does, ask for the clone URL or confirm you can create/use it with `gh`.

Follow this workflow:

1. Open the local project path and inspect the repository state.
   - If it is already a Git repository, run `git status --short --branch` and identify the current branch.
   - If it is not a Git repository, run `git init` and set the default branch to `main`.
   - Do not run destructive commands such as `git reset --hard`, `git clean`, or force pushes.

2. Check for obvious sensitive or generated content before staging.
   - Review `.gitignore` and make sure typical Electron/Node outputs are ignored, including `node_modules/`, `dist/`, `out/`, `build/`, `.env`, `.env.*`, logs, caches, and local IDE files.
   - If `.env` files, certificates, tokens, private keys, connection strings, or other secrets are present, stop and ask Peter what to exclude before committing.
   - If no `.gitignore` exists, create a standard Electron/Node `.gitignore` before staging.

3. Prepare the private GHE remote.
   - Check auth with `gh auth status -h <ghe-host>`.
   - If not authenticated, ask Peter to run or approve `gh auth login -h <ghe-host>`.
   - If the repository does not exist and Peter confirms creation, create it as private with `GH_HOST=<ghe-host> gh repo create <owner>/<repo> --private --source . --remote origin`.
   - If the repository already exists, add or update `origin` to the private GHE URL Peter provides. Prefer SSH if Peter already uses SSH; otherwise use HTTPS.

4. Commit the current dashboard snapshot.
   - Run `git status --short` and show Peter the files that will be included.
   - Stage intended files with `git add .`.
   - Run a final staged check with `git status --short` and, when useful, `git diff --cached --stat`.
   - Commit with a clear message such as `Initial Electron dashboard snapshot`.
   - If there is nothing to commit, say so and continue to the push step if the branch has commits that are not on the remote.

5. Push to the private GHE repository.
   - Push the current branch with upstream tracking, normally `git push -u origin main`.
   - If the current branch is not `main`, either push the current branch as-is or ask Peter before renaming it.
   - Do not force push. If the remote has unrelated history, stop and explain the situation before choosing merge, rebase, or a fresh repo.

6. Finish with the result.
   - Provide the private GHE repository URL.
   - State the branch pushed and commit SHA.
   - Mention any files intentionally excluded, especially environment files or generated build outputs.
