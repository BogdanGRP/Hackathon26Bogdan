## 1. Document element-type conventions

- [x] 1.1 Write the canonical element-type mapping table (component category → ArchiMate type) as the primary output of the `element-type-conventions` spec
- [x] 1.2 Validate that every element type used in the mapping is available via the ArchiMate MCP tooling (`mcp_archimate_*` tools)
- [x] 1.3 Add rationale notes for any ambiguous categories (e.g., national registries as external ApplicationComponent)
- [x] 1.4 Confirm the open question: whether external systems should use a stereotype or a separate naming convention

## 2. Document relationship-type conventions

- [x] 2.1 Write the canonical relationship-type mapping table (source element type × target element type → ArchiMate relationship) as the primary output of the `relationship-type-conventions` spec
- [x] 2.2 Verify each relationship type is supported by the ArchiMate MCP create-relationship tool
- [x] 2.3 Add a note on bidirectional flow handling (FlowRelationship with explicit direction vs. two separate relationships)

## 3. Document view layout conventions

- [x] 3.1 Write the three-zone layout rule with a textual diagram showing left/center/right zones for the `view-layout-conventions` spec
- [x] 3.2 Document the supplementary zone rule for cross-cutting concerns (identity, monitoring, SaaS)
- [x] 3.3 Document the legend requirement and define minimum legend content
- [x] 3.4 Document arrow direction rules per zone pair

## 4. Audit existing ArchiMate models

- [x] 4.1 Open `architecture/mks-connections.archimate` and list all elements with their current ArchiMate types
- [x] 4.2 Open `architecture/cgs-landscape.archimate` and list all elements with their current ArchiMate types
- [x] 4.3 Identify any elements whose type conflicts with the element-type-conventions spec
- [x] 4.4 Correct conflicting element types in both models using `mcp_archimate_update_element`
- [x] 4.5 Identify any relationships whose type conflicts with the relationship-type-conventions spec
- [x] 4.6 Correct conflicting relationship types in both models

## 5. Validate and save models

- [x] 5.1 Export both updated models to HTML/Markdown and verify element types render correctly
- [x] 5.2 Save both updated ArchiMate models using `mcp_archimate_save_model`
- [x] 5.3 Confirm the `cgs-live-graph-ui` diagram-generation tasks reference these conventions for element type selection
