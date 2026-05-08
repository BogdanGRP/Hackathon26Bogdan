## ADDED Requirements

### Requirement: Domain narrative section
The documentation SHALL include a domain narrative section that explains the end-to-end message flow through CGS, covering how a service request enters the system, gets routed through channels, transformed, and delivered to target applications.

#### Scenario: Reader understands message flow
- **WHEN** a developer reads the domain narrative section
- **THEN** they can trace a service request from application → serviceusage → servicedefinition → channeldefinition → adapterendpoint → endpointconfiguration and understand each step's role

### Requirement: Per-table business documentation
The documentation SHALL provide a business-level description for each of the 30 core CGS tables, explaining what real-world concept it represents in the service bus domain.

#### Scenario: Table purpose is clear
- **WHEN** a reader looks up any core table in the documentation
- **THEN** they find a plain-language description of what the table represents (e.g., "servicedefinition represents a service in the CGS service catalog that applications can subscribe to")

#### Scenario: Audit and system tables are covered briefly
- **WHEN** a reader looks up an audit table (`_aud`) or system table (`revinfo`, `cgssetting`)
- **THEN** they find a brief explanation of its purpose and relationship to its parent table

### Requirement: Semantic column descriptions
The documentation SHALL describe key columns per table — focusing on columns whose purpose is non-obvious from the name alone: FK references, type discriminators, configuration fields, and domain-specific semantics.

#### Scenario: FK column meaning explained
- **WHEN** a table has a foreign key column
- **THEN** the documentation explains the business meaning of that relationship (e.g., "application_id: the municipal application that owns this certificate, used for TLS authentication")

#### Scenario: Self-evident columns omitted
- **WHEN** a column's purpose is obvious from its name and type (e.g., `id`, `name`, `version`)
- **THEN** the documentation does not include a redundant description for that column

### Requirement: Relationship rationale
The documentation SHALL explain each FK relationship in business terms — not just "table A references table B" but *why* that relationship exists and what it means in the CGS domain.

#### Scenario: Relationship meaning documented
- **WHEN** a reader examines a relationship between two tables
- **THEN** they find an explanation like "serviceusage bridges application and servicedefinition because an application must be explicitly registered to consume a service"

#### Scenario: Junction table purpose explained
- **WHEN** a junction/bridge table is documented
- **THEN** the many-to-many relationship it represents is explained with both sides named

### Requirement: Domain grouping with rationale
The documentation SHALL organize tables by domain group (Service Bus Core, Adapter/Endpoint, CMIS, ebMS, Logging, Validation, Message/Transformation, Application, System) with a brief rationale for each grouping.

#### Scenario: Domain group has introduction
- **WHEN** a reader navigates to a domain group section
- **THEN** they find an introductory paragraph explaining what that domain covers and how it fits into the CGS system

### Requirement: Table of contents with anchor links
The documentation file SHALL include a table of contents at the top with anchor links to each domain section and each table.

#### Scenario: Navigate to specific table
- **WHEN** a reader clicks a table name in the table of contents
- **THEN** they are taken directly to that table's documentation section
