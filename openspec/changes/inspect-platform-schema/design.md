## Context

The Platform Owner (`igp_ontwikkel_platform_owner`) schema is the infrastructure and operations backbone of the IGP platform. It manages identity & access (users, roles, permissions, LDAP), job scheduling and execution, auto-update (MAU), install/migration history, and standalone platform configuration. The schema contains 22 tables with **9 DB-level FK constraints** enforced via `information_schema.referential_constraints` (confirmed via PostgreSQL MCP on 2026-05-08).

We have read-only access via the PostgreSQL MCP server (user `hackathon`) and an ArchiMate MCP server for model ingestion. The schema has been partially documented in `schema-platform-owner.md` (DDL + domain map), which serves as the baseline for this inspection.

## Goals / Non-Goals

**Goals:**
- Systematic 4-phase inspection: Discovery → Structure → Relationships → Visualization
- Produce machine-readable outputs at each phase (SQL result sets, structured markdown, Mermaid ER diagrams)
- Generate ArchiMate-ready output that can be ingested into the architecture model via the ArchiMate MCP server
- Leverage the PostgreSQL MCP server for all live database queries
- Keep all outputs version-controlled in the repo
- Use DB-level FK constraints from `information_schema.referential_constraints` as the authoritative source for relationships

**Non-Goals:**
- Modifying any database data or schema (read-only inspection only)
- Replacing existing platform application documentation
- Automating continuous schema drift detection (this is a point-in-time inspection)
- Inspecting schemas other than `igp_ontwikkel_platform_owner`

## Decisions

### 1. Use PostgreSQL information_schema for metadata extraction
**Decision:** Query `information_schema.tables`, `information_schema.columns`, `information_schema.table_constraints`, and `information_schema.key_column_usage`.
**Rationale:** Same approach as `inspect-cgs-schema` for consistency. information_schema is SQL-standard and sufficient for our needs.

### 2. Use DB-level FK constraints as authoritative source
**Decision:** Query `information_schema.referential_constraints`, `information_schema.key_column_usage`, and `information_schema.constraint_column_usage` to extract the 9 confirmed FK constraints.
**Rationale:** FK constraints are enforced at the DB level (confirmed 2026-05-08 via PostgreSQL MCP). Using `information_schema` is consistent with `inspect-cgs-schema` and gives authoritative, guaranteed-accurate relationship data. No inference from `*_id` naming is needed.

### 3. Use Mermaid for ER diagrams
**Decision:** Generate ER diagrams in Mermaid `erDiagram` syntax.
**Rationale:** Same as `inspect-cgs-schema` — Mermaid renders natively in GitHub/GitLab markdown, is text-based, and version-controllable.

### 4. ArchiMate ingestion via MCP server
**Decision:** Use the ArchiMate MCP server tools (`mcp_archimate_*`) to create Technology Layer data objects representing tables and their relationships.
**Rationale:** Direct MCP integration ensures the architecture model stays synchronized with the database reality.

### 5. Domain grouping by functional area
**Decision:** Group the 22 tables into 5 functional domains: Identity & Access, Job Execution, Auto Update (MAU), Install / Migration, Standalone Config.
**Rationale:** These groupings are already identified in the `schema-platform-owner.md` domain map and align with the system's operational responsibilities. FK relationships largely stay within domain boundaries.

## Risks / Trade-offs

- **[Stale data]** → Schema snapshot is point-in-time; document the inspection date prominently in all outputs
- **[Small schema]** → 22 tables means the full ER diagram is readable as a single diagram (no need to split by domain), unlike the CGS schema
- **[ArchiMate model conflicts]** → If elements already exist in the model, use `find_elements` to check before creating, update if found
- **[Cross-cutting columns]** → `changecounter` and `factorysetting` appear on nearly every table; exclude from ArchiMate model as they are technical ORM artifacts, not domain concepts
- **[FK constraint names]** → Constraint names follow a generated pattern (e.g., `rolepermissionmappingc00`) — use source/target table+column as the human-readable label in diagrams and ArchiMate output
