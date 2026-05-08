## Context

The CGS (Configuratie Generieke Services) system is a service bus / integration broker that routes messages between municipal applications. Its configuration is stored in a PostgreSQL database (`igp_ontwikkel`, schema `igp_ontwikkel_cgs_owner`) with 46 tables organized across ~8 functional domains (adapters, services, channels, messaging, CMIS, ebMS, logging, orchestration).

We have read-only access via a PostgreSQL MCP server and an ArchiMate MCP server for model ingestion. Existing reference docs (`cgs-schema-overview.md`, `cgs-schema-tables.md`) provide a partial baseline but were manually assembled. This design formalizes a repeatable 4-phase inspection process.

## Goals / Non-Goals

**Goals:**
- Systematic 4-phase inspection: Discovery → Structure → Relationships → Visualization
- Produce machine-readable outputs at each phase (SQL result sets, structured markdown, Mermaid ER diagrams)
- Generate ArchiMate-ready output that can be ingested into the architecture model via the ArchiMate MCP server
- Leverage the PostgreSQL MCP server (`mcp_postgresql_query`) for all live database queries
- Keep all outputs version-controlled in the repo

**Non-Goals:**
- Modifying any database data or schema (read-only inspection only)
- Replacing existing CGS application documentation
- Automating continuous schema drift detection (this is a point-in-time inspection)
- Inspecting schemas other than `igp_ontwikkel_cgs_owner`

## Decisions

### 1. Use PostgreSQL information_schema for metadata extraction
**Decision:** Query `information_schema.tables`, `information_schema.columns`, `information_schema.table_constraints`, and `information_schema.key_column_usage` rather than pg_catalog directly.
**Rationale:** information_schema is SQL-standard, more readable, and sufficient for our needs. pg_catalog would be needed for advanced features (partitioning, inheritance) which don't apply here.

### 2. Use Mermaid for ER diagrams
**Decision:** Generate ER diagrams in Mermaid `erDiagram` syntax.
**Rationale:** Mermaid renders natively in GitHub/GitLab markdown, requires no external tooling, and is text-based (version-controllable). Alternatives like PlantUML or dbdiagram.io would add dependencies.

### 3. ArchiMate ingestion via MCP server
**Decision:** Use the ArchiMate MCP server tools (`mcp_archimate_*`) to create Technology Layer data objects representing tables and their relationships.
**Rationale:** Direct MCP integration avoids manual model editing and ensures the architecture model stays synchronized with the database reality.

### 4. Domain grouping by table name prefix and FK clustering
**Decision:** Group tables by name prefix patterns (e.g., `ebms*`, `cmis*`, `log*`, `adapter*`) first, then refine using FK relationship clustering.
**Rationale:** CGS tables follow consistent naming conventions that naturally align with functional domains. FK clustering catches tables that belong to a domain without sharing its prefix.

## Risks / Trade-offs

- **[Stale data]** → Schema snapshot is point-in-time; document the inspection date prominently in all outputs
- **[Large query results]** → Some tables have hundreds of rows; limit row-count queries and avoid `SELECT *` on data tables
- **[ArchiMate model conflicts]** → If elements already exist in the model, creation will fail → use `find_elements` to check before creating, update if needed
- **[FK graph complexity]** → 66 FK constraints across 46 tables may produce a cluttered diagram → split ER diagrams by domain group for readability
