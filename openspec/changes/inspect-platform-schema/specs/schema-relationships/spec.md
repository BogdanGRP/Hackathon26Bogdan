## ADDED Requirements

### Requirement: Extract DB-level FK constraints
The system SHALL query `information_schema.referential_constraints`, `information_schema.key_column_usage`, and `information_schema.constraint_column_usage` to extract all 9 FK constraints enforced in the `igp_ontwikkel_platform_owner` schema.

#### Scenario: FK constraint listing
- **WHEN** relationship inspection is executed
- **THEN** all 9 FK constraints are returned with source table, source column, target table, target column, and constraint name

#### Scenario: Complete FK coverage
- **WHEN** FK extraction is complete
- **THEN** the 9 known constraints are present: `jobactionlog→jobexecutionlog`, `jobexecutionlog→taskdefinition`, `logrecord→postinstallresult`, `maulogging→mauplanning`, `roleldapgroupdn→ldapconfiguration`, `roleldapgroupdn→roletable`, `rolepermissionmapping→permissiontable`, `rolepermissionmapping→roletable`, `taskdefinition→taskgroupdefinition`

### Requirement: Build FK dependency graph
The system SHALL construct a directed graph of FK relationships showing which tables reference which, with edge labels using source column names.

#### Scenario: Graph construction
- **WHEN** all FK constraints have been extracted
- **THEN** a directed graph is produced where nodes are tables and edges are FK relationships labeled with the FK column name

#### Scenario: Identify root tables
- **WHEN** the FK graph is analyzed
- **THEN** tables with no outgoing FKs (only referenced by others) are identified as root/reference tables
