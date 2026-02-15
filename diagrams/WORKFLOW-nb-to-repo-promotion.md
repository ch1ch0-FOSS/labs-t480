## Promotion Workflow Diagram
    - `nb` to repo promotion

```
┌─────────────────────────────────────────────────────────────┐
│ nb workspace (operational, iterative)                       │
│ ~/.nb/t480/adr_example.md                                   │
└────────────────┬────────────────────────────────────────────┘
                 │
                 │ Meets promotion criteria?
                 │ (finalized, complete, stable)
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Run: scripts/nb-promote.sh t480:adr_example.md              │
│                                                             │
│ 1. Creates branch: nb-promote/example                       │
│ 2. Copies file to ADR/ADR-NNN-example.md                    │
│ 3. Commits to branch                                        │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Review & edit (optional)                                    │
│ vim ADR/ADR-NNN-example.md                                  │
│ git commit -m "docs: review and update"                     │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Merge to main                                               │
│ git checkout main && git merge nb-promote/example           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Mark in nb with promotion metadata                          │
│ nb t480:adr_example.md --edit                               │
│ (Append: promoted date, path, commit)                       │
└─────────────────────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ Git repo (version-controlled, public portfolio)             │
│ ~/projects/labs/t480/ADR/ADR-NNN-example.md                 │
└─────────────────────────────────────────────────────────────┘
```
