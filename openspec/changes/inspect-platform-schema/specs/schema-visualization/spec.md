## ADDED Requirements

### Requirement: Generate ER-style relationship diagram
The system SHALL produce an ER diagram in Mermaid `erDiagram` syntax showing all 22 tables and their logical FK relationships in a single diagram.

#### Scenario: Full ER diagram
- **WHEN** the visualization phase is executed with all logical FK data
- **THEN** a Mermaid erDiagram is generated with all 22 tables as entities and logical FK relationships as labeled edges

#### Scenario: Diagram annotated with domain groups
- **WHEN** the ER diagram is produced
- **THEN** tables are visually grouped or annotated by their functional domain (Identity & Access, Job Execution, MAU, Install / Migration, Standalone Config)

### Requirement: Group tables by domain
The system SHALL assign each table to one of 5 functional domains, producing a domain-grouped summary.

#### Scenario: Domain assignment
- **WHEN** all 22 tables have been analyzed
- **THEN** each table is assigned to exactly one of: Identity & Access, Job Execution, Auto Update (MAU), Install / Migration, Standalone Config

### Requirement: Produce structured output for ArchiMate ingestion
The system SHALL create ArchiMate Technology Layer elements (data objects) for each table and ArchiMate relationships for each inferred logical FK, using the ArchiMate MCP server.

#### Scenario: Create ArchiMate data objects
- **WHEN** ArchiMate ingestion is triggered
- **THEN** each table is represented as an ArchiMate Technology Layer data object with properties for row count and domain group

#### Scenario: Create ArchiMate relationships for logical FKs
- **WHEN** ArchiMate data objects exist for all tables
- **THEN** each inferred FK is represented as an ArchiMate association labeled "logical FK (inferred)"

#### Scenario: Avoid duplicate elements
- **WHEN** an ArchiMate element for a table already exists in the model
- **THEN** the existing element is updated rather than duplicated (use `find_elements` before creating)
