## ADDED Requirements

### Requirement: Generate ER-style relationship diagram
The system SHALL produce an ER diagram in Mermaid `erDiagram` syntax showing all tables and their FK relationships.

#### Scenario: Full ER diagram
- **WHEN** the visualization phase is executed with all FK data
- **THEN** a Mermaid erDiagram is generated with all tables as entities and FK relationships as labeled edges

#### Scenario: Per-domain ER diagram
- **WHEN** the full diagram is too complex for readability
- **THEN** separate Mermaid erDiagrams are generated per domain group (e.g., adapter domain, service domain, CMIS domain)

### Requirement: Group tables by domain
The system SHALL assign each table to a functional domain based on name prefix analysis and FK clustering, producing a domain-grouped summary.

#### Scenario: Domain assignment
- **WHEN** all tables have been analyzed for prefixes and FK relationships
- **THEN** each table is assigned to exactly one domain group with a rationale

### Requirement: Produce structured output for ArchiMate ingestion
The system SHALL create ArchiMate Technology Layer elements (data objects) for each table and ArchiMate relationships for each FK constraint, using the ArchiMate MCP server.

#### Scenario: Create ArchiMate data objects
- **WHEN** ArchiMate ingestion is triggered
- **THEN** each table is represented as an ArchiMate Technology Layer data object with properties for row count and domain group

#### Scenario: Create ArchiMate relationships
- **WHEN** ArchiMate data objects exist for all tables
- **THEN** FK constraints are represented as ArchiMate associations between the corresponding data objects

#### Scenario: Avoid duplicate elements
- **WHEN** an ArchiMate element for a table already exists in the model
- **THEN** the existing element is updated rather than duplicated
