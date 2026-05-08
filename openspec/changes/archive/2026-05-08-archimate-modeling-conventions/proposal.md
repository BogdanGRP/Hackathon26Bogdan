## Why

When building ArchiMate diagrams of the CGS landscape (and beyond), there is no agreed-upon standard for which ArchiMate element type to use for each category of component — leading to inconsistent models where, for example, a municipal application might be drawn as an Application Component in one view and an Application Service in another. A single, authoritative mapping from component category to ArchiMate element type is needed so that all diagrams are consistent, reviewable, and governable.

## What Changes

- Define a canonical mapping of real-world component categories to ArchiMate element types, covering:
  - Municipal consumer applications (domain apps such as iBurgerzaken, CIPERS, CZA)
  - The integration/service-bus platform (CGS/GSB and its internal modules)
  - National registries and external voorzieningen (NHR, KVK, BRP/GBA, AMP, CORV, PDOK)
  - Business actors and roles (municipalities, citizens, departments)
  - Services and endpoints (integration services, API endpoints, adapters)
  - Domain/functional groupings (containers that cluster related elements)
  - Identity & access / SaaS components (NAAS, Entre ID)
  - Infrastructure and hosting nodes (on-premise servers, cloud environments)
- Define relationship type conventions (Serving, Flow, Association, Realization, etc.) between element categories
- Define view-layout conventions: which element categories appear in which column/zone of a landscape diagram

## Capabilities

### New Capabilities
- `element-type-conventions`: Canonical table mapping each component category to its ArchiMate element type, with rationale and examples drawn from the CGS/IGP landscape
- `relationship-type-conventions`: Rules for which ArchiMate relationship type to use between pairs of element categories (e.g., Application Component → Application Service uses Serving)
- `view-layout-conventions`: Rules for how to spatially organize elements in landscape views (left/center/right zones, grouping nesting, legend requirements)

### Modified Capabilities
<!-- No existing capabilities are being modified -->

## Impact

- **ArchiMate models**: `architecture/mks-connections.archimate` and `architecture/cgs-landscape.archimate` must be reviewed against the new conventions and corrected where element types are wrong
- **Future diagrams**: All new views created by the `cgs-live-graph-ui` change and any future landscape automation must conform to these conventions
- **No database or code changes**: This is a documentation and modeling-standard change only
- **Consumers**: Architects, developers building automated diagram generation, and anyone reading or reviewing ArchiMate models
