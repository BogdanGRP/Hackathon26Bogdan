## 1. Phase 1 — Discovery

- [ ] 1.1 Query `information_schema.tables` to list all tables in `igp_ontwikkel_platform_owner` with table types
- [ ] 1.2 Run row count queries (`SELECT count(*)`) for each of the 22 tables and compile results sorted descending
- [ ] 1.3 Analyze table name patterns to identify domain groupings (identity/access, job execution, MAU, install/migration, standalone config)
- [ ] 1.4 Flag cross-cutting technical columns (`changecounter`, `factorysetting`) that appear across tables — exclude from ArchiMate model
- [ ] 1.5 Write discovery results to a structured markdown summary

## 2. Phase 2 — Structure

- [ ] 2.1 Query `information_schema.columns` for all 22 tables: column name, data type, is_nullable, column_default, ordinal_position
- [ ] 2.2 Query `information_schema.table_constraints` and `key_column_usage` to extract primary keys per table
- [ ] 2.3 Extract unique constraints per table from `information_schema.table_constraints`
- [ ] 2.4 Compile per-table structure catalog with columns, PKs, and unique constraints

## 3. Phase 3 — Relationships

- [ ] 3.1 Query `information_schema.referential_constraints` + `key_column_usage` + `constraint_column_usage` to extract all FK constraints (expected: 9 rows)
- [ ] 3.2 Verify the 9 known FKs are returned: `jobactionlog→jobexecutionlog`, `jobexecutionlog→taskdefinition`, `logrecord→postinstallresult`, `maulogging→mauplanning`, `roleldapgroupdn→ldapconfiguration`, `roleldapgroupdn→roletable`, `rolepermissionmapping→permissiontable`, `rolepermissionmapping→roletable`, `taskdefinition→taskgroupdefinition`
- [ ] 3.3 Build directed FK dependency graph (nodes = tables, edges = FK references labeled with FK column name)
- [ ] 3.4 Identify root/reference tables (tables with no outgoing FKs)

## 4. Phase 4 — Visualization & Output

- [ ] 4.1 Generate a full Mermaid `erDiagram` with all 22 tables and their logical FK relationships (single diagram — schema is small enough)
- [ ] 4.2 Annotate diagram with domain group labels for each cluster of tables
- [ ] 4.3 Produce domain-grouped table summary with domain assignment rationale
- [ ] 4.4 Create ArchiMate Technology Layer data objects for each table via MCP server (exclude `changecounter`/`factorysetting` as properties)
- [ ] 4.5 Create ArchiMate associations for FK relationships between data objects — label with the FK column name (e.g., "role_id")
- [ ] 4.6 Verify no duplicate ArchiMate elements were created (use `find_elements` before creating)
- [ ] 4.7 Write output to `openspec/specs/platform-schema-overview.md` and `openspec/specs/platform-schema-tables.md`
