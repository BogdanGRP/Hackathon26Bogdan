## ADDED Requirements

### Requirement: List all tables in the schema
The system SHALL query all tables in the `igp_ontwikkel_platform_owner` schema and return a complete list with table names and table types (BASE TABLE vs VIEW).

#### Scenario: Complete table listing
- **WHEN** the discovery phase is executed against the Platform Owner schema
- **THEN** a list of all 22 tables is returned with their names and types

### Requirement: Count rows per table
The system SHALL count the number of rows in each table to distinguish active/populated tables from empty lookup/config tables.

#### Scenario: Row counts for all tables
- **WHEN** row counts are requested
- **THEN** each table's row count is returned, sorted descending by count

#### Scenario: Identify empty tables
- **WHEN** row counts are analyzed
- **THEN** tables with zero rows are flagged as empty/unused

### Requirement: Identify table name patterns and domain groupings
The system SHALL analyze table names to identify functional domain groupings: Identity & Access, Job Execution, Auto Update (MAU), Install / Migration, and Standalone Config.

#### Scenario: Assign tables to domains
- **WHEN** table names are analyzed for patterns
- **THEN** each of the 22 tables is assigned to exactly one functional domain

#### Scenario: Flag cross-cutting technical columns
- **WHEN** column names are scanned across all tables
- **THEN** `changecounter` and `factorysetting` are identified as cross-cutting ORM/technical columns and flagged for exclusion from ArchiMate output
