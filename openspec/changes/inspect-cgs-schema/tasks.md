## 1. Phase 1 — Discovery

- [ ] 1.1 Query `information_schema.tables` to list all tables in `igp_ontwikkel_cgs_owner` with table types
- [ ] 1.2 Run row count queries (`SELECT count(*)`) for each table and compile results sorted descending
- [ ] 1.3 Analyze table name prefixes and patterns to identify domain groupings (adapter*, cmis*, ebms*, log*, etc.)
- [ ] 1.4 Flag audit tables (`_aud` suffix) and system tables (`revinfo`, `cgssetting`) separately
- [ ] 1.5 Write discovery results to a structured markdown summary

## 2. Phase 2 — Structure

- [ ] 2.1 Query `information_schema.columns` for all tables: column name, data type, is_nullable, column_default, ordinal_position
- [ ] 2.2 Query `information_schema.table_constraints` and `key_column_usage` to extract primary keys per table
- [ ] 2.3 Extract unique constraints per table from `information_schema.table_constraints`
- [ ] 2.4 Compile per-table structure catalog with columns, PKs, and unique constraints

## 3. Phase 3 — Relationships

- [ ] 3.1 Query all FK constraints: source table/column → target table/column, constraint name
- [ ] 3.2 Identify junction/bridge tables (composite PK where all columns are FKs)
- [ ] 3.3 Build directed FK dependency graph (nodes = tables, edges = FK references)
- [ ] 3.4 Identify root/reference tables (tables only referenced by others, no outgoing FKs)

## 4. Phase 4 — Visualization & Output

- [ ] 4.1 Generate a full Mermaid `erDiagram` with all tables and FK relationships
- [ ] 4.2 Generate per-domain Mermaid ER diagrams for readability (adapter, service, CMIS, ebMS, logging, etc.)
- [ ] 4.3 Produce domain-grouped table summary with domain assignment rationale
- [ ] 4.4 Create ArchiMate Technology Layer data objects for each table via MCP server
- [ ] 4.5 Create ArchiMate associations for FK relationships between data objects
- [ ] 4.6 Verify no duplicate ArchiMate elements were created (find existing before creating)
