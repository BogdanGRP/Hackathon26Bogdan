# Config Graph Visualization — Hackathon Master Plan (OpenSpec Edition)
> PostgreSQL MCP + ArchiMate MCP + AI Agent | Team of 4 | 2 Days | OpenSpec

---

## 0. Why OpenSpec for This Project

OpenSpec is brownfield-first and lightweight by design. It does not impose a
phase-locked planning → implementation waterfall. Instead it uses a fluid
proposal → specs → design → tasks → apply → archive cycle that you can interrupt,
resume, and run in parallel across team members — which is exactly what a 2-day
hackathon with 4 people needs.

Critically, your project produces no traditional application code. Its artifacts are
prompt files, MCP config, and context markdown. OpenSpec's spec-driven approach
treats any artifact — not just source code — as a deliverable, making it a natural fit.

---

## 1. Install & Bootstrap (Day 0 — do before the hackathon)

```bash
# Install globally — one time per machine
npm install -g @fission-ai/openspec@latest

# Run inside your repo root
cd config-graph
openspec init
```

During `openspec init` you will be prompted for your AI tool. All 4 devs select
**Claude Code**. This generates:

```
openspec/
├── project.md          ← THE most important file — fill this in immediately
├── specs/              ← living specifications (empty at start)
└── changes/            ← active change proposals (one per work item)

.claude/
└── skills/             ← OpenSpec slash commands wired into Claude Code
    ├── opsx-propose.md
    ├── opsx-apply.md
    ├── opsx-archive.md
    └── openspec/AGENTS.md
```

Enable the expanded workflow for the team (gives you /opsx:new, /opsx:ff,
/opsx:verify, /opsx:sync):

```bash
openspec config profile
# select: expanded
openspec update
```

---

## 2. project.md — Fill This In Before Writing a Single Prompt

This is OpenSpec's equivalent of AGENTS.md and FIRE's constitution combined.
Every proposal, design doc, and task file the AI generates will be anchored to it.

```markdown
# Config Graph Visualization — Project Constitution

## What this project is
A prompt-engineering + MCP orchestration module. There is NO application source
code in this repository. All deliverables are markdown prompt files, JSON MCP
config files, and bash scripts.

## Goal
Connect a read-only PostgreSQL MCP (config schema only) to an ArchiMate MCP
(fanievh plugin running in Archi desktop) via an AI agent that reads the DB schema
and writes a correct, idempotent ArchiMate model of config entity relationships.

## Stack
- PostgreSQL MCP: read-only connection, config schema only
- ArchiMate MCP: fanievh/archi-mcp-server plugin in Archi 5.x
- AI model: Claude Sonnet via Claude Code
- Scripts: Bash (POSIX)
- Config: JSON
- No Java, no frontend, no application code

## Hard rules — enforced in every generated artifact
- NEVER use write tools on the Postgres MCP (INSERT/UPDATE/DELETE/DROP forbidden)
- NEVER modify ArchiMate elements tagged "manual"
- NEVER expose DB credentials in any file tracked by git
- NEVER create duplicate elements in Archi — always search before create
- NEVER cross schema boundaries — only query the config schema
- All prompts live in agent/prompts/ — never inline prompts in scripts
- All semantic context lives in agent/context/ — never hardcode table meanings

## Repository layout
agent/prompts/      → agent prompt files (one per task)
agent/context/      → schema-hints.md, domain-groups.md
mcp/postgres/       → Postgres MCP config (gitignored — contains credentials)
mcp/archi/          → Archi MCP config
scripts/            → smoke test and reset scripts
openspec/           → all OpenSpec artifacts (committed to git)

## Definition of done for any change
- [ ] Prompt files follow the Goal/Inputs/Steps/Output Format structure
- [ ] Smoke test script exits 0
- [ ] Agent run produces valid summary JSON with errors: []
- [ ] Running the agent twice produces identical output (idempotency verified)
```

---

## 3. Change Structure (One Change Per Work Item)

OpenSpec organizes work into **changes**. Each change produces four artifacts
before any implementation starts. For this project the four changes map to the
four work items.

```
openspec/changes/
├── WI-01-postgres-mcp/
│   ├── proposal.md     ← what & why
│   ├── specs/
│   │   └── spec.md     ← requirements + scenarios
│   ├── design.md       ← technical decisions
│   └── tasks.md        ← atomic implementation checklist
│
├── WI-02-schema-hints/
│   ├── proposal.md
│   ├── specs/spec.md
│   ├── design.md
│   └── tasks.md
│
├── WI-03-transform-prompt/
│   ├── proposal.md
│   ├── specs/spec.md
│   ├── design.md
│   └── tasks.md
│
└── WI-04-archi-mcp-explainer/
    ├── proposal.md
    ├── specs/spec.md
    ├── design.md
    └── tasks.md
```

---

## 4. The OpenSpec Cycle Per Change

Each work item goes through this exact flow:

```
/opsx:propose "description of change"
       ↓
  AI generates proposal.md + specs/ + design.md + tasks.md
       ↓
  Human reviews ALL FOUR artifacts — correct misalignments NOW
  (This is where you catch wrong architectural decisions before any work)
       ↓
/opsx:apply
       ↓
  AI executes tasks.md line by line
  (for this project: creates prompt files, config files, scripts)
       ↓
/opsx:verify
       ↓
  AI checks tasks.md completion status, flags any incomplete tasks
       ↓
/opsx:archive
       ↓
  Change moves to openspec/changes/archive/
  Specs merge into openspec/specs/ as living documentation
```

---

## 5. Work Items — Full Spec

---

### WI-01 — PostgreSQL MCP Setup
**Owner: Dev A**

```
/opsx:propose "Set up read-only PostgreSQL MCP connection scoped to the config
schema. Create DB role, configure MCP server, write smoke test script that
verifies the agent can query information_schema and FK constraints."
```

Expected tasks.md after proposal review:

```markdown
# Tasks: WI-01 PostgreSQL MCP Setup

## Phase 1 — Database
- [ ] 1.1 Write SQL to create ai_graph_reader role (LOGIN, no write privileges)
- [ ] 1.2 Grant CONNECT on database to ai_graph_reader
- [ ] 1.3 Grant USAGE on config schema to ai_graph_reader
- [ ] 1.4 Grant SELECT on all tables in config schema
- [ ] 1.5 Explicitly REVOKE INSERT/UPDATE/DELETE from ai_graph_reader
- [ ] 1.6 Document the role creation SQL in scripts/create-db-role.sql

## Phase 2 — MCP Config
- [ ] 2.1 Create mcp/postgres/config.json with connection string for ai_graph_reader
- [ ] 2.2 Add mcp/postgres/config.json to .gitignore
- [ ] 2.3 Create mcp/postgres/config.example.json with placeholder values (committed)

## Phase 3 — Smoke Test
- [ ] 3.1 Write scripts/verify-postgres-mcp.sh
- [ ] 3.2 Test queries: information_schema.tables WHERE table_schema = 'config'
- [ ] 3.3 Test queries: information_schema.referential_constraints
- [ ] 3.4 Verify no write tools are accessible in the agent session
- [ ] 3.5 Script must exit 0 on success, non-zero with clear error message on failure

## Acceptance criteria
- [ ] verify-postgres-mcp.sh exits 0
- [ ] Query returns > 0 tables
- [ ] FK constraint query returns results
- [ ] No credentials appear in any committed file
```

---

### WI-02 — Schema Hints & Domain Groups
**Owner: Dev B**

```
/opsx:propose "Create agent/context/schema-hints.md mapping all config schema
table names to human-readable display names and ArchiMate element types.
Create agent/context/domain-groups.md grouping tables into functional views.
Flag PII tables for exclusion."
```

Expected spec.md requirements:

```markdown
# Spec: Schema Context Files

## Requirement: Complete table coverage
Every table in the config schema MUST appear in schema-hints.md as either
a mapped entry or an explicit EXCLUDE with reason.

#### Scenario: Table in schema, in hints
- GIVEN a table exists in information_schema.tables for schema 'config'
- WHEN schema-hints.md is read
- THEN an entry exists for that table name

#### Scenario: PII table excluded
- GIVEN a table contains personally identifiable information
- WHEN schema-hints.md is read
- THEN the entry is marked [EXCLUDE — PII] with no further mapping

## Requirement: Domain grouping
Tables MUST be grouped into at least 3 functional domain groups in
domain-groups.md, matching the application's feature organization.

## Requirement: ArchiMate type annotation
Each non-excluded table MUST have an assigned ArchiMate element type:
ApplicationComponent (default), DataObject (reference/lookup), or
ApplicationInterface (API/integration tables).
```

---

### WI-03 — Schema-to-ArchiMate Transform Prompt
**Owner: Dev C**

```
/opsx:propose "Build agent/prompts/schema-to-archimate.md — the core prompt
that reads config schema via PostgreSQL MCP and writes a complete ArchiMate
Application Layer model via Archi MCP. Must be idempotent: search before create,
update if exists, never duplicate. Output summary JSON."
```

This is the highest-risk change. Review ALL four artifacts carefully before /opsx:apply.

Key items to verify in design.md before applying:
- Idempotency strategy (search-before-create with normalized Title Case names)
- Token budget chunking strategy (by domain group if schema > 80 tables)
- Circular FK handling (create all elements first, then relationships)
- Summary JSON schema agreed upfront

Expected tasks.md structure:

```markdown
# Tasks: WI-03 Transform Prompt

## Phase 1 — Prompt structure
- [ ] 1.1 Create agent/prompts/schema-to-archimate.md with Goal section
- [ ] 1.2 Write Inputs section (Postgres MCP + context files)
- [ ] 1.3 Write Steps section (query → normalize → search → create/update → layout)
- [ ] 1.4 Write Output Format section (summary JSON schema)

## Phase 2 — Idempotency logic
- [ ] 2.1 Add search-before-create instruction with Title Case normalization rule
- [ ] 2.2 Add update-if-found instruction (description field only)
- [ ] 2.3 Add relationship deduplication instruction

## Phase 3 — Edge case handling
- [ ] 3.1 Add circular FK detection instruction (flag in summary, do not skip)
- [ ] 3.2 Add hub table detection (> 5 FKs → dedicated sub-view)
- [ ] 3.3 Add orphan table handling (no FKs → Standalone Entities view)
- [ ] 3.4 Add token budget chunking by domain group

## Phase 4 — Validation
- [ ] 4.1 Write scripts/verify-idempotency.sh (runs prompt twice, diffs Archi model)
- [ ] 4.2 Run prompt on single domain group (smoke test before full schema)
- [ ] 4.3 Run prompt on full schema, verify summary JSON errors: []
```

---

### WI-04 — Archi MCP + Explainer
**Owner: Dev D**

```
/opsx:propose "Install and verify fanievh/archi-mcp-server plugin in Archi.
Write scripts/verify-archi-mcp.sh. Build agent/prompts/explainer.md that takes
a view name and returns plain English explanation of the domain, setup sequence,
and common misconfiguration risks. Wire full end-to-end pipeline."
```

Expected tasks.md:

```markdown
# Tasks: WI-04 Archi MCP + Explainer

## Phase 1 — Archi MCP verification
- [ ] 1.1 Install fanievh/archi-mcp-server plugin in Archi 5.x
- [ ] 1.2 Create mcp/archi/config.json (gitignored)
- [ ] 1.3 Write scripts/verify-archi-mcp.sh
      (create test element → verify it exists → delete it → exit 0)

## Phase 2 — Explainer prompt
- [ ] 2.1 Create agent/prompts/explainer.md with Goal section
- [ ] 2.2 Write Inputs section (view name OR element list + Archi MCP)
- [ ] 2.3 Write Output Format: 1) domain summary 2) setup order 3) common mistakes
- [ ] 2.4 Test explainer on at least 2 domain views

## Phase 3 — End-to-end wiring
- [ ] 3.1 Write scripts/run-full-pipeline.sh (verify both MCPs → transform → explainer)
- [ ] 3.2 Write scripts/reset-archi-model.sh (delete only "generated"-tagged elements)
- [ ] 3.3 Run full pipeline on complete config schema
- [ ] 3.4 Verify runtime < 3 minutes on full schema

## Phase 4 — Demo prep
- [ ] 4.1 Verify reset script works (run pipeline → reset → run again)
- [ ] 4.2 Document demo steps in docs/runbook.md
```

---

## 6. Team Split & Collaboration Map

This is the most critical part. The wrong split wastes an entire day.
The key insight is: **Dev A and Dev B must deliver their outputs
by Day 1 noon for Dev C and Dev D to be unblocked.**

---

### Roles

| Dev | OpenSpec Role | Work Item | What they own |
|---|---|---|---|
| **Dev A** | Infrastructure Lead | WI-01 | DB role + Postgres MCP + smoke test |
| **Dev B** | Domain Expert | WI-02 | schema-hints.md + domain-groups.md |
| **Dev C** | Prompt Engineer | WI-03 | Core transform prompt (highest complexity) |
| **Dev D** | Integration Lead | WI-04 | Archi MCP + explainer + end-to-end |

Dev B is ideally the person who knows the application domain best —
the one who knows what `cfg_feat_stg_lkp` actually means in business terms.
This is not a technical task. It is a domain knowledge task.

---

### Day 1 — Parallel Sprints With Two Hard Joins

```
TIME        DEV A                DEV B                DEV C                DEV D
─────────────────────────────────────────────────────────────────────────────────
08:30       ══════════════════ TEAM JOIN #0 — KICKOFF (30 min) ══════════════════
            openspec init together on shared repo. Fill project.md as a team.
            Each dev runs /opsx:propose for their change. Review proposals together.
            Agree on interfaces: GraphDTO shape, summary JSON schema, MCP config format.
─────────────────────────────────────────────────────────────────────────────────
09:00       SOLO SPRINT ─────────────────────────────────────────────────────────

            /opsx:apply WI-01    /opsx:apply WI-02    WAIT — blocked on       Install Archi
            Create DB role       Query all tables     WI-01 + WI-02           plugin
            Configure MCP        from Postgres MCP                            /opsx:apply WI-04
            Write smoke test     Map table names      Study fanievh           Phase 1 only
                                 Write domain groups  archi-mcp-server docs   Verify MCP
                                 (this takes longer   Write proposal for      connectivity
                                 than expected —      WI-03 artifacts
                                 allocate 3 hrs)      carefully
─────────────────────────────────────────────────────────────────────────────────
12:00       ══════════════════ TEAM JOIN #1 — INTEGRATION GATE (45 min) ═════════
            GATE: Dev A must have verify-postgres-mcp.sh exit 0
            GATE: Dev B must have schema-hints.md covering all tables
            
            Actions:
            - Dev A demos Postgres MCP to the team — everyone verifies they can query
            - Dev B walks through schema-hints.md — team corrects any wrong mappings
            - Dev C and Dev D pull latest, confirm they can read both context files
            - Agree on any last changes to domain groups before Dev C starts prompts
            - If either gate is NOT met → Dev C helps Dev A/B, Dev D continues solo
─────────────────────────────────────────────────────────────────────────────────
13:00       SOLO SPRINT ─────────────────────────────────────────────────────────

            Support Dev C/D      Refine schema-hints  /opsx:apply WI-03       /opsx:apply WI-04
            if MCP issues        based on feedback    Phase 1 + 2             Phase 2 + 3
            arise (on call)      Add missing tables   Build transform         Build explainer
                                 discovered by Dev C  prompt core             prompt
                                 during prompt work   Idempotency logic       Test on 1 view
─────────────────────────────────────────────────────────────────────────────────
17:00       ══════════════════ TEAM JOIN #2 — END-TO-END SMOKE (45 min) ═════════
            GATE: Single table flows end-to-end (Postgres → Agent → Archi)
            
            Actions:
            - Run full pipeline on ONE table from ONE domain group
            - Verify element appears in Archi with correct name and tag
            - Verify running it again produces 0 new elements (idempotency)
            - Dev C and Dev D identify blockers for Day 2
            - Update all tasks.md files with completion status
            - Each dev commits and pushes their change branch
            
            If gate NOT met: this is a critical risk — all 4 work together until
            single-table end-to-end works. Do not start Day 2 without this.
─────────────────────────────────────────────────────────────────────────────────
```

---

### Day 2 — Integration Focus With Progressive Joins

```
TIME        DEV A                DEV B                DEV C                DEV D
─────────────────────────────────────────────────────────────────────────────────
09:00       SOLO SPRINT ─────────────────────────────────────────────────────────

            Handle any           Validate Day 1       /opsx:apply WI-03       /opsx:apply WI-04
            Postgres MCP         Archi output         Phase 3 + 4             Phase 3 + 4
            edge cases           quality — are        Edge case handling       End-to-end pipeline
            discovered           domain views         Token budget chunks     Reset script
            from full run        readable?            Full schema run         run-full-pipeline.sh
                                 Missing tables?
                                 Wrong groupings?
                                 Feed back to Dev C
─────────────────────────────────────────────────────────────────────────────────
12:00       ══════════════════ TEAM JOIN #3 — FULL SCHEMA RUN (60 min) ══════════
            GATE: Full schema runs without errors. Summary JSON shows errors: []
            
            Actions:
            - Run full pipeline together on the complete config schema
            - Review the generated ArchiMate model as a team
            - Identify any domain groups that look wrong → Dev B fixes hints
            - Test the explainer on 2 views → does it make sense to non-devs?
            - Assign demo polish tasks
            - /opsx:verify on all four changes — confirm task completion
─────────────────────────────────────────────────────────────────────────────────
13:00       ══════════════════ TEAM WORKS TOGETHER FOR REMAINDER ════════════════

            All 4 devs work as one team from here — no more solo sprints.

            13:00–14:30  Polish pass
                         - Fix any wrong ArchiMate element names
                         - Improve explainer output quality
                         - Fix layout in any cluttered views
                         - Verify reset script works for clean demo restarts

            14:30–15:30  /opsx:archive all four changes
                         - Run /opsx:verify on each change first
                         - Archive in dependency order: WI-01 → WI-02 → WI-03 → WI-04
                         - Verify specs merge correctly into openspec/specs/

            15:30–16:30  Demo rehearsal
                         - One person drives, three watch and give feedback
                         - Time the demo (target: under 6 minutes)
                         - Rehearse the reset between demo runs

            16:30        DEMO
─────────────────────────────────────────────────────────────────────────────────
```

---

## 7. When to Join Forces — Decision Rules

Not every join is scheduled. Use these rules throughout both days:

**Join immediately if:**
- Any smoke test script is failing after 30 minutes of solo debugging
- An agent is producing wrong ArchiMate element types and Dev B is the only one
  who knows why (domain knowledge bottleneck)
- Dev C's prompt produces duplicates — Dev D likely has Archi MCP insights that
  fix this faster than solo debugging
- Day 1 EOD gate is at risk of not being met

**Stay solo if:**
- Your task is clearly self-contained and not blocking anyone
- A join would interrupt someone mid-/opsx:apply (don't break agent context)
- The issue is a config problem that one person can fix in under 15 minutes

**Context hygiene rule (OpenSpec-specific):**
Before every /opsx:apply, clear your Claude Code context window. OpenSpec
benefits from a clean context — stale chat history from a previous task
causes the agent to make wrong assumptions about what already exists.

---

## 8. Git Strategy for 4 Parallel OpenSpec Changes

```
main
 └── feature/config-graph
      ├── feature/config-graph/WI-01-postgres-mcp     ← Dev A
      ├── feature/config-graph/WI-02-schema-hints     ← Dev B
      ├── feature/config-graph/WI-03-transform        ← Dev C
      └── feature/config-graph/WI-04-archi-explainer  ← Dev D
```

**Shared files — PR required, no direct commits:**
- openspec/project.md
- agent/context/schema-hints.md
- agent/context/domain-groups.md

**gitignore additions:**
```
mcp/postgres/config.json
mcp/archi/config.json
openspec/changes/*/runs/
```

**Merge order at Team Join #1:**
Dev A merges WI-01 branch → feature/config-graph first.
Dev B merges WI-02 branch → feature/config-graph second.
Dev C and Dev D pull feature/config-graph before starting work.

---

## 9. Edge Cases

### Schema-level

**Circular FK relationships**
Detection: build adjacency list from referential_constraints, run cycle check.
Handling: create all elements first, then relationships. Flag cycles in summary JSON
as circular_references: ["A→B→C→A"]. Never skip — cycles are valid ArchiMate.

**Tables with no FKs (orphan tables)**
Likely reference tables or legacy mistakes. Still create the ApplicationComponent.
Place in a "Standalone Entities" view. Add a warning tag in Archi.

**Hub tables (> 5 FKs)**
A junction table with many FKs creates a spider that is unreadable in the main view.
Detection: FK count > 5 for any single table.
Handling: include the element in the main view but suppress its associations there.
Create a dedicated sub-view named "{TableName} Relationships" with all its FKs.

**Schema changes between runs**
A table dropped since last run leaves a stale element in Archi.
Handling: after each run, compare "generated"-tagged Archi elements against the
current schema. Elements not in the schema get tagged "stale" and highlighted.
Never auto-delete — a human decides. Add this check to run-full-pipeline.sh.

**Unnamed FK constraints**
ORMs generate constraints like fk_28a7f3. Meaningless as a relationship label.
Detection: constraint name matches /^fk_[0-9a-f]{6,}$/.
Fallback: use the FK column name as the relationship label instead.

**Token budget exceeded**
A schema with 150+ tables will exceed context window in a single prompt pass.
Handling: WI-03 prompt must support --domain flag to chunk by domain group.
Run one agent session per domain group, not one for everything.

### Agent-level

**Duplicate element creation**
Root cause: search step skipped or case mismatch between search query and existing name.
Fix: normalize all element names to Title Case BEFORE searching AND before creating.
Add explicitly to the prompt: "Always normalize to Title Case before any Archi operation."

**Archi not open**
The fanievh plugin runs inside Archi desktop. If Archi is closed, MCP returns
connection refused. Rule: verify-archi-mcp.sh must pass before every agent session.
Add to project.md: "If Archi MCP returns connection refused, stop and alert human."

**Agent hallucinates table names**
Agent invents a table it thinks should exist. Prevention: prompt must instruct the
agent to ONLY use table names returned by the actual MCP query — never infer.

### Team-level

**Two devs running agents against Archi simultaneously**
Archi's MCP plugin operates on one open model. Concurrent writes will corrupt it.
Rule: only one agent session writes to Archi at a time. Enforce via calendar block
during Team Joins #2 and #3. Other devs use Archi in read-only mode.

**schema-hints.md conflict**
Both Dev B and Dev C edit schema-hints.md simultaneously.
Rule: schema-hints.md is PR-only. Dev C raises a PR comment if a table is wrong,
Dev B merges the fix. No direct commits from Dev C.

---

## 10. Production Roadmap

### Phase 1 — Stabilize (Sprint 1–2)
- Move Postgres MCP behind internal API gateway (direct DB exposure not prod-safe)
- Scheduled nightly agent run — schema changes auto-reflected
- Stale element human review queue
- Archi .archimate model committed to git after each agent run

### Phase 2 — Web Accessibility (Sprint 3–4)
The biggest production gap: Archi is a desktop tool.

Option A — Export pipeline (ship first):
Archi exports all views to SVG/HTML after each agent run. Post-process step
publishes to an internal static site. Simple, no new infra. Snapshots, not
interactive.

Option B — Web-native graph store (Phase 3):
Replace Archi write target with Neo4j. Same agent, different MCP output target.
Expose via a JSF page with vis.js rendering. Interactive and real-time. Larger
scope — do Option A first.

### Phase 3 — Intelligence Layer (Sprint 5–8)
- Change impact analysis: "I want to change cfg_feat_stage — what breaks?"
- Setup wizard generation: agent reads a Feature view, produces a step-by-step
  config checklist ordered by FK dependency
- Misconfiguration detection: compare live config values against the relationship
  model, flag inconsistencies

### Phase 4 — Governance (Sprint 9+)
- ArchiMate model changes via PR — agent changes are auto-PRs reviewed by arch team
- Per-team schema access control via MCP gateway
- Every agent run logged to openspec/specs/ as a timestamped spec delta

---

## 11. Demo Script (Day 2, 16:30)

```
1. [30s] Show the problem
   Navigate 3 config pages to configure one feature.
   "This is what our users do every day."

2. [30s] Show the raw schema
   Run: SELECT table_name FROM information_schema.tables WHERE table_schema = 'config'
   "40+ tables, FK soup. No one knows how they connect."

3. [20s] Show openspec/changes/ structure
   "Here's the spec we wrote before touching anything. Proposal, design, tasks."

4. [1min] Run the agent (or show pre-run output)
   Execute run-full-pipeline.sh. Show summary JSON: elements_created, errors: []

5. [1min] Show the ArchiMate model
   Open Archi. Show 3 domain views. "Every entity, every FK, from the live schema."

6. [1min] Run the explainer
   Select the Feature Lifecycle view.
   Ask: "Explain this domain and the correct setup sequence."
   Show the plain English output. "Our junior devs can now onboard themselves."

7. [30s] Idempotency
   Run the agent again. Show: elements_created: 0, elements_updated: 40, errors: []
   "It's safe to re-run after every schema change."

8. [30s] Future vision
   "Nightly sync. Web export. Change impact analysis. One sprint each."
```

---

*Config Graph Visualization — Hackathon Plan v2*
*Workflow: OpenSpec (spec-driven) | Team: 4 | Duration: 2 days*
*Replaces: specs.md FIRE flow edition*
