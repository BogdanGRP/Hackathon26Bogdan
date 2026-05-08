## Context

ArchiMate 3.1 offers ~50 element types across Business, Application, Technology, and Motivation layers. Without a written convention, different team members draw the same category of component differently — a municipal application may appear as an `ApplicationComponent`, `ApplicationService`, or `ApplicationFunction` in different diagrams, making governance, automated tooling, and cross-diagram traceability impossible.

The CGS landscape currently has two ArchiMate models (`mks-connections.archimate`, `cgs-landscape.archimate`) and an active effort (`cgs-live-graph-ui`) to generate landscape diagrams automatically from live database data. For that automation to produce correct output, the element-type mapping must be codified before the diagram-generation tasks are implemented.

**Stakeholders**: Architects who review models; developers building the automated landscape generator; team members onboarding to the CGS domain.

## Goals / Non-Goals

**Goals:**
- Define which ArchiMate element type maps to each real-world component category in the CGS/IGP landscape
- Define which ArchiMate relationship type to use between common pairs of element categories
- Define spatial/layout rules for landscape views so that automated and manual diagrams look consistent
- Be prescriptive enough to make automated diagram generation deterministic

**Non-Goals:**
- Covering every possible ArchiMate element type — only those relevant to the CGS/IGP landscape
- Replacing the full ArchiMate 3.1 specification — this is a profile, not a replacement
- Defining color schemes or visual styling (out of scope for this change)
- Covering motivation, strategy, or implementation/migration layers

## Decisions

### D1: Use Application Layer as the primary layer for all software components

**Decision**: All applications, platforms, services, and endpoints are represented at the Application layer (`ApplicationComponent`, `ApplicationService`, `ApplicationInterface`, `ApplicationFunction`). The Technology layer is used only for explicit infrastructure (servers, cloud platforms, middleware runtimes).

**Rationale**: The CGS landscape is an application-centric view. Mixing Application and Technology layer elements for software components creates visual clutter and confuses ArchiMate layer semantics. Using the Technology layer for infrastructure-only matches standard ArchiMate practice.

**Alternative considered**: Model all components at the Technology layer (as is common in infrastructure diagrams) — rejected because the primary audience is application architects, not infrastructure engineers.

---

### D2: Applications are `ApplicationComponent`; services/endpoints are `ApplicationService` or `ApplicationInterface`

**Decision**:
- A deployable application (iBurgerzaken, CGS, CZA) → `ApplicationComponent`
- A logical service offered by an application (an integration endpoint, an API operation group) → `ApplicationService`
- A concrete access point (a specific REST/SOAP endpoint, a queue) → `ApplicationInterface`

**Rationale**: ArchiMate semantics: `ApplicationComponent` is a modular unit that can be deployed; `ApplicationService` is externally visible behavior; `ApplicationInterface` is the concrete access point. This three-level hierarchy matches how CGS exposes functionality.

---

### D3: Business actors/organizations at Business layer; roles as `BusinessRole`

**Decision**: Municipalities, citizens, and external organizations → `BusinessActor`. Functional roles within those organizations (e.g., "Case Worker", "System Administrator") → `BusinessRole`.

**Rationale**: Business layer elements represent organizational concepts. Conflating organizations with application layer elements loses the ability to express who uses what.

---

### D4: Domain groupings use `Grouping`

**Decision**: Containers that cluster related applications by domain (e.g., "Burgerzaken", "Zaakgericht Werken", "Landelijke Voorzieningen") → `Grouping`.

**Rationale**: `Grouping` is the ArchiMate element for arbitrary cross-layer or same-layer clusters. It has no semantic implication beyond "these belong together," which is exactly what domain groupings express. `ApplicationFunction` or nested `ApplicationComponent` would imply composition/decomposition semantics that are not intended here.

---

### D5: Relationship type selection

**Decision**:
- `ApplicationComponent` uses a service → `ServingRelationship` (server → client direction)
- Data flows between components → `FlowRelationship`
- An `ApplicationInterface` realizes an `ApplicationService` → `RealizationRelationship`
- A `BusinessActor` uses an `ApplicationService` → `AssociationRelationship` (or `ServingRelationship` in the opposite direction)
- A `Grouping` contains elements → `AssociationRelationship` (or implicit nesting in view)

**Rationale**: Using the wrong relationship type breaks automated impact analysis and traceability. These mappings follow ArchiMate 3.1 §5 relationship rules.

## Risks / Trade-offs

- **[Risk] Existing models violate conventions** → Mitigation: A follow-up compliance review task is included in `tasks.md` to audit and correct `mks-connections.archimate` and `cgs-landscape.archimate` against the new conventions.
- **[Risk] ArchiMate MCP tooling may not support all element types** → Mitigation: Specs will list only element types confirmed available via the `mcp_archimate_*` tools; unknown types will be flagged as open questions.
- **[Trade-off] `Grouping` has no behavioral semantics** — it cannot express that a domain group "provides" services. If that becomes a requirement, a future change can introduce `ApplicationCollaboration` or nested `ApplicationComponent` patterns.

## Open Questions

- Should national registries (NHR, KVK, BRP) be modeled as external `ApplicationComponent` elements, or as `ApplicationService` elements to emphasize that we only see their interface? (Proposal leans toward `ApplicationComponent` with stereotype `«external»`.)
- Does the ArchiMate MCP server support custom stereotypes/profiles, or only standard element types?
