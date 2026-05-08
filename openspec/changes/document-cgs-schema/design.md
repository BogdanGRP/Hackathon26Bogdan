## Context

The `inspect-cgs-schema` change completed a full technical extraction of the CGS database schema (`igp_ontwikkel_cgs_owner`, 46 tables, 66 FK constraints). This produced three raw reference files:
- `cgs-schema-overview.md` — table listing, row counts, domain grouping ASCII diagram
- `cgs-schema-tables.md` — column-level detail for every table
- `cgs-schema-er-diagram.md` — Mermaid ER diagrams (full + per-domain) and FK graph

These are machine-derived facts. What's missing is a *documentation layer* that interprets the schema in business terms — explaining what each table means in the context of a municipal service bus, how tables collaborate to route messages, and why certain structural patterns exist (audit tables, junction tables, self-references).

## Goals / Non-Goals

**Goals:**
- Produce a single comprehensive documentation file (`openspec/specs/cgs-schema-docs.md`) that a developer or architect can read end-to-end
- Cover all 30 core tables (excluding 6 audit tables and 1 revinfo system table, which are documented briefly)
- For each table: business purpose, semantic column descriptions, relationship rationale
- Include a domain narrative section explaining the end-to-end message flow through CGS
- Use the existing raw specs as source data — do not re-query the database

**Non-Goals:**
- No ArchiMate model changes (separate future step)
- No code generation or schema migration scripts
- Not a replacement for the raw reference files — this complements them
- No coverage of tables outside the `igp_ontwikkel_cgs_owner` schema

## Decisions

### 1. Single documentation file vs. per-domain files
**Decision:** One file, organized by domain sections with a table of contents.
**Rationale:** The CGS schema is small enough (46 tables) that splitting into multiple files adds navigation overhead without improving readability. A single file with anchor links is more convenient for search and onboarding.
**Alternative considered:** Per-domain files (adapter-docs.md, logging-docs.md, etc.) — rejected because cross-domain references would require jumping between files.

### 2. Document structure: narrative-first vs. table-first
**Decision:** Lead with a domain narrative (end-to-end flow), then provide per-table detail sections.
**Rationale:** Readers need the big picture first ("how does a message flow through CGS?") before diving into individual table definitions. The narrative provides context that makes table-level documentation meaningful.

### 3. Semantic column documentation scope
**Decision:** Document only key/meaningful columns per table, not every column.
**Rationale:** Many columns are self-evident (id, name, version). Focus on columns whose purpose is non-obvious: FK references, type discriminators, configuration fields, and domain-specific semantics.

## Risks / Trade-offs

- **[Interpretation accuracy]** → Semantic meaning is inferred from column names, FK patterns, and row data, not from source code or official docs → clearly label interpretations as "inferred from schema structure"
- **[Staleness]** → Documentation is point-in-time (2026-05-08) → include generation date in header; re-run inspect-cgs-schema to refresh
- **[Single file size]** → May become large → mitigated by table of contents and domain grouping with anchor links
