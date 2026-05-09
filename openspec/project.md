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
