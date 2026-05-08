## Three-Zone Landscape Layout

```
┌─────────────────────────┐    ┌──────────────────────────────────┐    ┌──────────────────────────┐
│  LEFT ZONE              │    │  CENTER ZONE                     │    │  RIGHT ZONE              │
│  Municipal Domain Apps  │    │  CGS / GSB Integration Platform  │    │  Landelijke Voorzieningen│
│                         │    │                                  │    │                          │
│  [Grouping: Burgerzaken]│───▶│  [ApplicationComponent: CGS]     │───▶│  [Grouping: Registries]  │
│    └─ iBurgerzaken      │    │    ├─ VOA                        │    │    ├─ [External] NHR     │
│    └─ CIPERS            │    │    ├─ SMM                        │    │    ├─ [External] KVK     │
│                         │    │    └─ ZTC                        │    │    ├─ [External] BRP/GBA │
│  [Grouping: ZGW]        │───▶│                                  │───▶│    ├─ [External] AMP     │
│    └─ CZA               │    │  [ApplicationComponent: VOA]     │    │    ├─ [External] CORV    │
│    └─ Corsa             │    │  [ApplicationComponent: Config]  │    │    └─ [External] PDOK    │
│    └─ Alfresco          │    │                                  │    │                          │
│                         │    │                                  │    │                          │
└─────────────────────────┘    └──────────────────────────────────┘    └──────────────────────────┘
                                              ▲
              ┌───────────────────────────────┴──────────────────────────────┐
              │  SUPPLEMENTARY ZONE (above or below main band)               │
              │  [Grouping: Identity & Access]                               │
              │    └─ NAAS (ApplicationComponent)                            │
              │    └─ Entre ID (ApplicationComponent)                        │
              │  [Grouping: Monitoring]                                      │
              │    └─ Dashboard (ApplicationComponent)                       │
              └──────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────────────────────────────────┐
│  LEGEND (Grouping in top-right corner)                                                       │
│  Element types used:  ApplicationComponent  ApplicationService  BusinessActor  Grouping       │
│  Relationship types:  Serving (─▶)  Flow (══▶)  Association (───)  Realization (- - ▶)       │
└──────────────────────────────────────────────────────────────────────────────────────────────┘
```

**Arrow direction rules:**
- Left zone → Center zone: `Flow` or `Serving`, left-to-right  
- Center zone → Right zone: `Serving` or `Flow`, left-to-right  
- Back-channel (Center → Left): create a separate `Flow` relationship right-to-left with explicit label  
- Supplementary zone ↔ Center zone: `Serving` (identity/monitoring serves the platform)

**Legend minimum content:** The Legend `Grouping` SHALL list every element type and relationship type actually present in the view. It SHALL NOT list types that do not appear.

## ADDED Requirements

### Requirement: Landscape view has three horizontal zones
Every landscape diagram SHALL be organized into three horizontal zones from left to right:
1. **Left zone** — Municipal consumer applications (domain apps), grouped by domain using `Grouping` elements
2. **Center zone** — The integration/service-bus platform (CGS/GSB) and its internal modules
3. **Right zone** — National registries and external voorzieningen, grouped by category

#### Scenario: Standard landscape layout applied
- **WHEN** a landscape view is created or regenerated
- **THEN** it SHALL contain a left zone with domain app groupings, a center zone with the CGS platform, and a right zone with national registries

### Requirement: Vertical supplementary zones for cross-cutting concerns
Elements that span or support the three horizontal zones (identity/access services, monitoring, cloud/SaaS) SHALL be placed in supplementary zones above or below the main horizontal band.

#### Scenario: Identity service placed correctly
- **WHEN** an identity or access management service (e.g., NAAS, Entre ID) is added to a landscape view
- **THEN** it SHALL be placed in a supplementary zone (above or below the main band), not in any of the three horizontal zones

### Requirement: Every view includes a legend
Every landscape view SHALL include a `Grouping` element labeled "Legend" that lists the element types and relationship types used in that view.

#### Scenario: Legend present in exported view
- **WHEN** a landscape view is exported or reviewed
- **THEN** a Legend grouping SHALL be visible containing at minimum the element types and relationship types appearing in the view

### Requirement: Grouping nesting reflects domain ownership
`ApplicationComponent` elements SHALL be visually nested inside the `Grouping` that represents their domain. An application MUST NOT appear inside a domain grouping to which it does not belong.

#### Scenario: Correct nesting of domain app
- **WHEN** iBurgerzaken (ApplicationComponent) is placed on a landscape view
- **THEN** it SHALL be nested inside the "Burgerzaken" Grouping element

#### Scenario: Incorrect nesting caught in review
- **WHEN** a reviewer finds an ApplicationComponent nested in the wrong domain Grouping
- **THEN** the element SHALL be moved to the correct Grouping before the view is accepted

### Requirement: Relationship arrows follow zone direction
Relationships between the left zone and the center zone SHALL be drawn left-to-right. Relationships between the center zone and the right zone SHALL also be drawn left-to-right. Back-channel or bidirectional flows SHALL use a `FlowRelationship` with explicit directionality or a bidirectional arrow annotation.

#### Scenario: Standard left-to-center arrow direction
- **WHEN** a domain app (left zone) sends data to CGS (center zone)
- **THEN** the FlowRelationship arrow SHALL point from left to right (domain app → CGS)

#### Scenario: CGS serves national registry (center-to-right)
- **WHEN** CGS (center zone) sends a request to a national registry (right zone)
- **THEN** the ServingRelationship or FlowRelationship arrow SHALL point from center to right (CGS → registry)
