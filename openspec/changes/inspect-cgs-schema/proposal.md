## Why

We need a systematic, repeatable process to inspect the CGS database schema and produce structured documentation that feeds into ArchiMate architecture models. Currently, schema knowledge is scattered and manually gathered. A phased inspection plan ensures complete coverage — from table discovery through relationships to visual ER diagrams — and produces outputs that can be directly ingested by ArchiMate tooling for architecture governance.

## What Changes

- Introduce a 4-phase database schema inspection workflow (Discovery → Structure → Relationships → Visualization)
- Phase 1: List all tables, count rows, identify naming patterns and natural groupings
- Phase 2: Extract column definitions, types, nullability, defaults, primary keys, and unique constraints per table
- Phase 3: Map all foreign key constraints, identify junction/bridge tables, build an FK dependency graph
- Phase 4: Generate ER-style relationship diagrams, group tables by domain, produce structured output for ArchiMate ingestion
- Output artifacts: schema overview doc, detailed table catalog, FK graph, ER diagram, ArchiMate-ready export

## Capabilities

### New Capabilities
- `schema-discovery`: Phase 1 — list tables, row counts, name pattern analysis, and domain grouping
- `schema-structure`: Phase 2 — column-level detail extraction (types, nullability, defaults, PKs, unique constraints)
- `schema-relationships`: Phase 3 — FK constraint mapping, junction table identification, FK graph construction
- `schema-visualization`: Phase 4 — ER diagram generation, domain grouping, structured output for ArchiMate ingestion

### Modified Capabilities
<!-- No existing capabilities are being modified -->

## Impact

- **Database access**: Requires read-only access to the `igp_ontwikkel_cgs_owner` schema on `igp_ontwikkel` (localhost:5432)
- **Tooling**: Uses PostgreSQL MCP server for live queries, ArchiMate MCP server for model ingestion
- **Existing specs**: Builds on existing `cgs-schema-overview.md` and `cgs-schema-tables.md` reference docs in `openspec/specs/`
- **Output consumers**: ArchiMate architecture model (`architecture/mks-connections.archimate`), team documentation
