# CGS Architecture Landscape — Diagram Plan

> **Goal**: Create a structured enterprise architecture overview diagram similar to the reference image, using live data from the `igp_ontwikkel` database.

---

## What the Reference Image Shows

The reference image (Gooise Meren municipality) has this structure:

```
┌──────────────────┐    ┌──────────────────────────────────┐    ┌─────────────────────┐
│  Domein Apps     │    │   Gemeentelijke Servicebox (GSB)  │    │ Landelijke           │
│  (left column)   │    │   (large center platform)         │    │ Voorzieningen        │
│                  │    │                                   │    │ (right column)       │
│  [App Group 1]   │───▶│  [CGS / Integration Engine]       │───▶│  [NHR]              │
│    └─ AppBox     │    │                                   │    │  [KVK]              │
│  [App Group 2]   │    │  [Internal: VOA, Woning,          │    │  [GBA/BRP]          │
│    └─ AppBox     │    │   SMM, ZTC, Platform Config]      │    │  [AMP]              │
│  ...             │    │                                   │    │  [CORV]             │
│                  │    │  [Monitoring / Dashboard]         │    │  [PDOK]             │
│                  │    │  [API & Integration Manager]      │    └─────────────────────┘
│                  │    │  [Klantbestand / CRM]             │
└──────────────────┘    └──────────────────────────────────┘
                               ▲
              ┌────────────────┴──────────────────┐
              │  Pink Cloud (Burgerzaken)          │
              │  [iBurgerzaken, CIPERS, VOA]       │
              └───────────────────────────────────┘
                               ▼
              ┌────────────────────────────────────┐
              │  Yellow Box: Identity & Access     │
              │  SaaS: NAAS, Entre ID              │
              └────────────────────────────────────┘
```

**Key visual conventions in the reference:**
- **Teal/cyan boxes**: Application components
- **Pink/rose large container**: The integration platform (on-premise)
- **Gray containers**: Domain groupings
- **Color-coded arrows**: Different relationship types (serving, flow, etc.)
- **Legend**: Top-right corner
- **Annotation labels** on arrows: Short codes (HPS, MHR, NPS, etc.)

---

## Our Data Landscape

From `igp_ontwikkel_cgs_owner`, we have **55 production applications** and **220 services**.

### Proposed Domain Groups

Based on application names and descriptions in the database:

#### Left Panel — Municipal Consumer Applications

| Group | Applications | Source |
|---|---|---|
| **Burgerzaken** | iBurgerzaken, CIPERS, CMLGBA | `description` contains "Burgerzaken", "CiPers" |
| **Zaakgericht Werken** | CZA, WebNext, ZTC, Corsa, Alfresco, Decos, Verseon | Case/document management |
| **Sociaal Domein** | CWIZ, iSamenleving, CMO, DKD, iAdministratie | Social support |
| **Belastingen & Middelen** | CBB, CIN, CMD, 4WOZ, GEOTAX | Finance/tax |
| **Geo & Ruimte** | CBR, CGA, CKD, ROS, ROSWOZ | Geo/cadastre |
| **Portaal & Integratie** | CPT, FrontOffice, CMG, CIR, CIZ, CML | Portal/broker |
| **Externe Applicaties** | CLIQ, SquitXO, Legacy, TOG, Djuma, NedGraphics | Third-party |

#### Center — CGS Integration Platform

| Component | What it represents |
|---|---|
| **CGS** | CiVision Gemeentelijke Servicebus — the core router |
| **Service catalog** | 220 services grouped by type (StUF, Query, Storage, KVK, BRP/GBA, Zaak) |
| **CMM** | CiVision Makelaar Gegevensmagazijn — data warehouse broker |
| **ITP** | Integratie Tekst Platform |

#### Right Panel — Landelijke Voorzieningen (National Systems)

| Group | Applications |
|---|---|
| **BRP/GBA** | GWS (via StUFBeantwoordVraagBG) |
| **KVK/NHR** | KVK, NHR |
| **Overheid** | MijnOverheid, Digilevering, DSO, LV WOZ, BRAVO |
| **Finance** | FIN (CLIQ ESB financial system) |

---

## Build Plan — 5 Phases

### Phase 1 — Domain Classification (Prep, no ArchiMate yet)

**Goal**: Assign each of 55 production apps to a domain group.

- Query `serviceusage` + `servicedefinition` to understand which services each app uses
- Use service name patterns (StUF*, Opvragen*, *GBA*, *KVK*, *ZTC*) to confirm domain
- Build a mapping table: `app_name → domain_group`

**Key query needed**:
```sql
SELECT a.name, a.description, 
       array_agg(DISTINCT sd.name) as services_used
FROM application a
JOIN serviceusage su ON su.application_id = a.id
JOIN servicedefinition sd ON sd.id = su.servicedefinition_id
WHERE su.usagelevel = 'PRODUCTION'
GROUP BY a.name, a.description;
```

**Open question**: Some apps appear in multiple potential domains (e.g., CMG fits both "Portaal" and "Integration"). Do we want strict single-domain assignment, or allow overlap?

---

### Phase 2 — Core Platform Skeleton

**Goal**: Create the CGS platform container and internal structure in ArchiMate.

Elements to create:
1. `CGS` ApplicationComponent (already exists in model)
2. Grouping container: "CGS Integration Platform"  
3. Sub-groupings inside CGS:
   - "Service Bus" (CGS core)
   - "Makelaar Services" (CMG, CML, CMM)
   - "Integratie Tekst" (ITP)
4. Service catalog elements — grouped by category:
   - "StUF Services" (60 services — create as a sub-grouping, not individual boxes)
   - "Query Services" (28)
   - "BRP/GBA Services" (17)
   - etc.

**Design decision needed**: At the scale of 220 services, do we model each service individually (like the current model has 10) or use service category groupings as in the reference image? The reference image abstracts services into labeled boxes, not individual ArchiMate elements. **Recommended: use category groupings** — it matches the image and stays readable.

---

### Phase 3 — Consumer Domain Groups (Left Panel)

**Goal**: Create 7 domain Grouping containers, each containing the relevant ApplicationComponents.

Layout (each group stacked vertically, left column):

```
x=20, width=300
├── Burgerzaken          y=20,  height=160  (3 apps)
├── Zaakgericht Werken   y=200, height=200  (7 apps)
├── Sociaal Domein       y=420, height=180  (5 apps)
├── Belastingen          y=620, height=160  (5 apps)
├── Geo & Ruimte         y=800, height=160  (5 apps)
├── Portaal & Integratie y=980, height=160  (6 apps)
└── Externe Applicaties  y=1160,height=160  (7 apps)
```

Each app gets a labeled box (140×55) inside its group, with the app description shown as documentation.

---

### Phase 4 — External Providers (Right Panel)

**Goal**: Create the "Landelijke Voorzieningen" section on the right.

Sub-groups:
- "LV BRP/GBA" — GWS, NHR (already in model)
- "LV KVK" — KVK (already in model), plus KVK services
- "Overheid Online" — MijnOverheid, Digilevering, DSO, LV WOZ
- "Financial" — FIN (already in model)

---

### Phase 5 — Relationships & Connections

**Goal**: Wire up the serving relationships across domains.

Strategy:
1. **From DB**: Use `serviceusage` table → each `(application_id, servicedefinition_id)` pair = a potential connection
2. **From logs**: Use `logservicerequest` → confirmed live traffic (already done for 15 combos)
3. **Approach**: Don't wire every app to every service (too many arrows). Instead:
   - Connect domain Grouping → CGS platform (one arrow per group = clean like the image)
   - Connect CGS → each national system (right panel)
   - Add detail arrows only for the most-used flows (from logservicerequest)

---

## What We Need from You

Before building, a few open questions:

1. **Scope**: All 55 production apps, or focus on a subset (e.g., top 20 by service count)?

2. **Service granularity**: Individual `ApplicationService` elements for all 220 services, or grouped by category? *(Recommendation: category groups for readability)*

3. **Additional domain context**: The reference image has labels like "HPS", "MHR", "NPS" on the arrows — these appear to be protocol/system type codes. Do you have a mapping of what those mean for your apps?

4. **Non-CGS apps**: Apps like `SquitXO`, `Decos`, `Alfresco` — are they on-premise or SaaS? Should they be in a separate "SaaS" zone like the reference image shows at the bottom?

5. **Separate view or extend current model?**: Create a brand-new view in the existing `mks-connections.archimate`, or start a new `.archimate` file dedicated to the full landscape?

---

## Effort Estimate

| Phase | ArchiMate elements to create | Estimated MCP calls |
|---|---|---|
| Phase 1 | 0 (analysis only) | ~5 DB queries |
| Phase 2 | ~15 (groups + CGS internals) | ~20 MCP calls |
| Phase 3 | ~70 (7 groups + ~55 app components) | ~80 MCP calls |
| Phase 4 | ~15 (4 groups + ~10 provider components) | ~20 MCP calls |
| Phase 5 | ~30 relationships + view population | ~50 MCP calls |
| **Total** | **~130 elements** | **~175 MCP calls** |

This is achievable in a single session if we work systematically phase by phase.

---

## Limitations vs. Reference Image

| Feature | Reference image | Our ArchiMate model |
|---|---|---|
| Color coding (pink/teal) | ✅ Custom colors per group | ❌ Requires manual edit in Archi desktop |
| Arrow labels (HPS, MHR) | ✅ Protocol codes on connections | ⚠️ Possible via relationship names |
| Nested sub-components | ✅ Deep nesting in GSB | ✅ ArchiMate groupings support this |
| Legend box | ✅ Top-right corner | ✅ Can add as a Note element |
| Scale (55 apps) | ~40 boxes visible | ✅ Fully supported |
| Export to PNG/SVG | ✅ Via Archi desktop | ⚠️ MCP exports Mermaid text only |
