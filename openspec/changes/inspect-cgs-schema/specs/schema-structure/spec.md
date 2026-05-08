## ADDED Requirements

### Requirement: Extract column definitions per table
The system SHALL retrieve the full column list for each table including column name, data type, nullability, column default, and ordinal position.

#### Scenario: Column metadata for a table
- **WHEN** structure inspection is run for a given table
- **THEN** all columns are returned with name, type, is_nullable, column_default, and ordinal_position

### Requirement: Identify primary keys
The system SHALL identify the primary key column(s) for each table.

#### Scenario: Single-column primary key
- **WHEN** a table has a single-column primary key
- **THEN** the PK column and constraint name are returned

#### Scenario: Composite primary key
- **WHEN** a table has a multi-column primary key
- **THEN** all PK columns are returned with their ordinal positions within the key

### Requirement: Identify unique constraints
The system SHALL list all unique constraints for each table, including the columns they cover.

#### Scenario: Unique constraints listing
- **WHEN** structure inspection is run for a table with unique constraints
- **THEN** each unique constraint is returned with its name and constituent columns

#### Scenario: Table with no unique constraints
- **WHEN** a table has no unique constraints beyond the primary key
- **THEN** no unique constraints are listed for that table
