## ADDED Requirements

### Requirement: List all tables in the schema
The system SHALL query all tables in the `igp_ontwikkel_cgs_owner` schema and return a complete list with table names and table types (BASE TABLE vs VIEW).

#### Scenario: Complete table listing
- **WHEN** the discovery phase is executed against the CGS schema
- **THEN** a list of all 46 tables is returned with their names and types

### Requirement: Count rows per table
The system SHALL count the number of rows in each table to distinguish active/populated tables from empty lookup/config tables.

#### Scenario: Row counts for all tables
- **WHEN** row counts are requested
- **THEN** each table's row count is returned, sorted descending by count

#### Scenario: Identify empty tables
- **WHEN** row counts are analyzed
- **THEN** tables with zero rows are flagged as empty/unused

### Requirement: Identify table name patterns and groupings
The system SHALL analyze table name prefixes and patterns to identify natural domain groupings (e.g., `ebms*`, `cmis*`, `log*`, `adapter*`, `*_aud`).

#### Scenario: Group tables by prefix
- **WHEN** table names are analyzed for patterns
- **THEN** tables are grouped into functional domains based on shared prefixes and naming conventions

#### Scenario: Identify audit tables
- **WHEN** table names are scanned
- **THEN** tables ending in `_aud` are identified as audit/history tables and grouped separately
