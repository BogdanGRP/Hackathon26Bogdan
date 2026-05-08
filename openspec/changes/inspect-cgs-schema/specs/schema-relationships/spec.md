## ADDED Requirements

### Requirement: Map all foreign key constraints
The system SHALL extract all foreign key constraints including source table, source column(s), target table, target column(s), and constraint name.

#### Scenario: FK constraint listing
- **WHEN** relationship inspection is executed
- **THEN** all 66 FK constraints are returned with source table, source column, target table, target column, and constraint name

### Requirement: Identify junction/bridge tables
The system SHALL identify junction tables (many-to-many) by detecting tables whose primary key is composed entirely of foreign key columns referencing two or more other tables.

#### Scenario: Junction table detected
- **WHEN** a table has a composite PK where all columns are FKs to different tables
- **THEN** the table is flagged as a junction/bridge table with references to the two parent tables

#### Scenario: No junction tables
- **WHEN** no tables match the junction table pattern
- **THEN** no junction tables are reported

### Requirement: Build FK dependency graph
The system SHALL construct a directed graph of FK relationships showing which tables reference which, with edge labels indicating the FK column(s).

#### Scenario: Graph construction
- **WHEN** all FK constraints have been extracted
- **THEN** a directed graph is produced where nodes are tables and edges are FK relationships with column labels

#### Scenario: Identify root tables
- **WHEN** the FK graph is analyzed
- **THEN** tables with no outgoing FKs (only referenced by others) are identified as root/reference tables
