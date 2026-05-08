## Canonical Element-Type Mapping Table

| Component Category | ArchiMate Element Type | Layer | MCP Tool Parameter |
|---|---|---|---|
| Deployable application (municipal, platform, SaaS, external registry) | `ApplicationComponent` | Application | `create_application_element` → `ApplicationComponent` |
| Logical integration service / API operation group | `ApplicationService` | Application | `create_application_element` → `ApplicationService` |
| Concrete endpoint / adapter / queue | `ApplicationInterface` | Application | `create_application_element` → `ApplicationInterface` |
| Organization (municipality, government body, citizen) | `BusinessActor` | Business | `create_business_element` → `BusinessActor` |
| Functional role (Case Worker, System Admin) | `BusinessRole` | Business | `create_business_element` → `BusinessRole` |
| Domain cluster / zone container | `Grouping` | Composite | `create_composite_element` → `Grouping` |
| Physical/virtual server or hosting environment | `Node` | Technology | `create_technology_element` → `Node` |
| Middleware runtime (ESB, container orchestrator) | `SystemSoftware` | Technology | `create_technology_element` → `SystemSoftware` |

> **MCP validation (2026-05-08)**: All element types above are confirmed available via the `mcp_archimate_*` tools. No custom stereotypes are supported by the MCP tooling — use a naming convention instead: prefix external systems with `[External]` (e.g., `[External] NHR`, `[External] KVK`).

> **External systems rationale**: National registries (NHR, KVK, BRP/GBA, AMP, CORV, PDOK) are modeled as `ApplicationComponent` — not `ApplicationService` — because they are autonomous deployable systems, not services we own. The `[External]` name prefix makes their boundary ownership explicit without requiring stereotype support.

## ADDED Requirements

### Requirement: Application category maps to ApplicationComponent
Every deployable application unit in the landscape (municipal domain apps, the integration platform, national registry systems, SaaS applications) SHALL be represented as an `ApplicationComponent` in ArchiMate models.

#### Scenario: Municipal application drawn correctly
- **WHEN** a municipal consumer application (e.g., iBurgerzaken, CZA, Corsa) is added to a view
- **THEN** it SHALL be created as an `ApplicationComponent` element

#### Scenario: Integration platform drawn correctly
- **WHEN** the CGS/GSB integration platform is added to a view
- **THEN** it SHALL be created as an `ApplicationComponent` element with its internal modules also modeled as nested `ApplicationComponent` elements

#### Scenario: National registry drawn correctly
- **WHEN** an external national registry (e.g., NHR, KVK, BRP/GBA, AMP, CORV, PDOK) is added to a view
- **THEN** it SHALL be created as an `ApplicationComponent` element

#### Scenario: SaaS/identity service drawn correctly
- **WHEN** a SaaS or identity service (e.g., NAAS, Entre ID) is added to a view
- **THEN** it SHALL be created as an `ApplicationComponent` element

### Requirement: Integration endpoint maps to ApplicationService or ApplicationInterface
A logical service exposed by an application (an integration endpoint group, an API operation group) SHALL be represented as an `ApplicationService`. A concrete access point (specific REST/SOAP endpoint, queue, or adapter interface) SHALL be represented as an `ApplicationInterface`.

#### Scenario: Integration service drawn correctly
- **WHEN** a named integration service offered by CGS (e.g., a HPS or MHR service) is added to a view
- **THEN** it SHALL be created as an `ApplicationService` element

#### Scenario: Concrete endpoint drawn correctly
- **WHEN** a specific adapter endpoint or queue is added to a view
- **THEN** it SHALL be created as an `ApplicationInterface` element

### Requirement: Organization maps to BusinessActor; functional role maps to BusinessRole
An external or internal organization (municipality, citizen, government body) SHALL be represented as a `BusinessActor`. A named functional role within an organization (e.g., Case Worker, System Administrator) SHALL be represented as a `BusinessRole`.

#### Scenario: Municipality drawn correctly
- **WHEN** a municipality (as an organization consuming CGS services) is added to a view
- **THEN** it SHALL be created as a `BusinessActor` element

#### Scenario: Functional role drawn correctly
- **WHEN** a named job function or process role is added to a view
- **THEN** it SHALL be created as a `BusinessRole` element

### Requirement: Domain grouping maps to Grouping
A container that clusters related applications or services by domain (e.g., "Burgerzaken", "Zaakgericht Werken", "Landelijke Voorzieningen") SHALL be represented as a `Grouping` element.

#### Scenario: Domain container drawn correctly
- **WHEN** a domain cluster (left panel, center platform, right panel, cloud zone) is added to a view
- **THEN** it SHALL be created as a `Grouping` element and child elements SHALL be nested inside it

### Requirement: Infrastructure node maps to Technology layer
A physical or virtual hosting node (server, cloud environment, VM, container platform) SHALL be represented as a `Node` or `SystemSoftware` element in the Technology layer — never as an `ApplicationComponent`.

#### Scenario: On-premise server drawn correctly
- **WHEN** an on-premise server or hosting environment is added to a view
- **THEN** it SHALL be created as a `Node` element in the Technology layer

#### Scenario: Middleware runtime drawn correctly
- **WHEN** a middleware runtime (e.g., an ESB runtime, container orchestrator) is added to a view
- **THEN** it SHALL be created as a `SystemSoftware` element in the Technology layer
