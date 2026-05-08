## Canonical Relationship-Type Mapping Table

| Source Element | Target Element | Relationship | MCP `relationship_type` value |
|---|---|---|---|
| `ApplicationComponent` (server) | `ApplicationComponent` (client) | `ServingRelationship` | `Serving` |
| `ApplicationComponent` / `ApplicationService` | `ApplicationComponent` / `ApplicationService` | `FlowRelationship` (data movement) | `Flow` |
| `ApplicationInterface` | `ApplicationService` | `RealizationRelationship` | `Realization` |
| `BusinessActor` | `ApplicationService` | `AssociationRelationship` | `Association` |
| `ApplicationService` | `BusinessActor` (service direction) | `ServingRelationship` | `Serving` |
| `BusinessActor` | `BusinessRole` | `AssignmentRelationship` | `Assignment` |

> **MCP validation (2026-05-08)**: All relationship types above are confirmed available via `mcp_archimate_create_relationship`. The MCP tool uses **short names** (`Serving`, `Flow`, `Realization`, `Association`, `Assignment`) — not the full ArchiMate names with the `Relationship` suffix used in this spec for readability.

> **Bidirectional flow handling**: When data flows in both directions between two components, create **two separate `Flow` relationships**, one in each direction. Do not use a single undirected `Association` as a substitute — it loses directional information needed for impact analysis. Label each `Flow` relationship with a short description if the direction is not obvious from context.

## ADDED Requirements

### Requirement: ApplicationComponent-to-ApplicationService uses ServingRelationship
When an `ApplicationComponent` exposes a service that another `ApplicationComponent` depends on, the relationship SHALL be a `ServingRelationship` directed from the serving component to the consuming component.

#### Scenario: CGS serves a domain app
- **WHEN** CGS (ApplicationComponent) provides integration services consumed by a municipal app (ApplicationComponent)
- **THEN** the relationship SHALL be a `ServingRelationship` from CGS to the municipal app

### Requirement: Data flow between components uses FlowRelationship
When data (messages, files, events) moves from one `ApplicationComponent` or `ApplicationService` to another, the relationship SHALL be a `FlowRelationship` directed in the direction of data movement.

#### Scenario: Message flow between applications
- **WHEN** a domain application sends a message to CGS for routing
- **THEN** the relationship SHALL be a `FlowRelationship` directed from the sending application to CGS

### Requirement: ApplicationInterface realizes ApplicationService
When an `ApplicationInterface` is the concrete manifestation of an `ApplicationService`, the relationship between them SHALL be a `RealizationRelationship` directed from the interface to the service.

#### Scenario: Endpoint realizes a service
- **WHEN** a specific SOAP endpoint (ApplicationInterface) implements an integration service (ApplicationService)
- **THEN** the relationship SHALL be a `RealizationRelationship` from the interface to the service

### Requirement: BusinessActor uses ApplicationService via AssociationRelationship
When a `BusinessActor` (e.g., a municipality) uses an `ApplicationService`, the relationship SHALL be an `AssociationRelationship`. Alternatively, the service-facing direction may be expressed as a `ServingRelationship` from the application layer to the business actor.

#### Scenario: Municipality uses CGS service
- **WHEN** a municipality (BusinessActor) accesses a CGS integration service (ApplicationService)
- **THEN** the relationship SHALL be an `AssociationRelationship` between the actor and the service, OR a `ServingRelationship` from the service to the actor

### Requirement: BusinessRole is assigned to BusinessActor via AssignmentRelationship
When a `BusinessRole` describes the function a `BusinessActor` performs, the relationship SHALL be an `AssignmentRelationship` directed from the actor to the role.

#### Scenario: Role assignment
- **WHEN** a municipality (BusinessActor) acts in the role of "Service Consumer" (BusinessRole)
- **THEN** the relationship SHALL be an `AssignmentRelationship` from the actor to the role

### Requirement: No direct relationship between Business layer and Technology layer elements
Business layer elements (BusinessActor, BusinessRole) SHALL NOT be directly related to Technology layer elements (Node, SystemSoftware). Application layer elements SHALL mediate between the two layers.

#### Scenario: Layer-skipping relationship rejected
- **WHEN** a reviewer finds a direct relationship between a BusinessActor and a Node
- **THEN** the model SHALL be corrected by introducing an intermediate ApplicationComponent or ApplicationService
