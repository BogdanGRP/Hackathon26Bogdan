## Context

The `igp_ontwikkel` PostgreSQL database contains the full CGS integration platform configuration: 55+ applications, 220 services, and their usage relationships. Live traffic is captured in `logservicerequest`. The ArchiMate model (`cgs-landscape.archimate`) already represents this landscape statically as 20 application components, 6 service category nodes, and 8 domain groupings.

The UI will run entirely on localhost — backend and frontend on the same machine that hosts PostgreSQL. Target audience is business stakeholders and consultants who need to understand "what connects to what" and "what's active right now" without reading database schemas or ArchiMate files.

**Constraints:**
- No external deployment — `localhost` only for the hackathon
- No authentication — single-user localhost demo
- Read-only access to PostgreSQL (`hackathon` user, password `hackathon`, port 5432)
- Top-20 applications by production service count; 6 service category groupings (not 220 individual services)
- Must be AI-generatable in one session

## Goals / Non-Goals

**Goals:**
- Render the CGS service landscape as an interactive node-graph with domain group containers
- Overlay live traffic (call volume + error rate) from `logservicerequest` as edge styling
- Toggle between "Live" (traffic overlay) and "As-built" (clean architecture) views
- Click a node to see connected services and traffic stats in a sidebar
- Auto-refresh traffic data every 30 seconds without full page reload
- Run with two terminal commands (`uvicorn` + `npm run dev`)

**Non-Goals:**
- Authentication or multi-user support
- Write-back to the database (no editing app configs or service definitions)
- Individual service-level nodes (220 services collapse to 6 category nodes)
- Real-time WebSocket streaming (polling every 30s is sufficient for the demo)
- Mobile responsiveness
- External deployment or Docker containerisation

## Decisions

### D1: FastAPI (Python) over Express (Node) for backend

**Chosen**: FastAPI + psycopg2-binary

**Why**: Python is the natural language for DB-heavy data scripts. The team already has Python on the machine (used for other tooling). FastAPI gives automatic OpenAPI docs at `/docs` — useful for understanding the API during development. `psycopg2` is the battle-tested PostgreSQL adapter.

**Alternative considered**: Express.js + pg — eliminated because it adds a second runtime (Node is already needed for the frontend) and offers no advantage over Python for simple read-only DB queries.

### D2: React Flow over D3.js or Cytoscape.js for graph rendering

**Chosen**: React Flow (`@xyflow/react`)

**Why**: React Flow is purpose-built for the exact node/edge/group nesting pattern this UI needs. It handles pan/zoom, node selection, and grouped containers natively. The ArchiMate `Grouping → ApplicationComponent → ApplicationService` hierarchy maps directly onto React Flow's parent node nesting. Visual quality is production-grade, which matters for the business stakeholder audience.

**Alternatives considered**:
- D3.js — maximum flexibility but requires significant custom code; not AI-generatable quickly
- Cytoscape.js — excellent for large graphs, but overkill for 20 nodes and the nesting UX is less natural
- Streamlit + pyvis — eliminated because it looks like a developer tool, not a business presentation

### D3: Two-endpoint API design (topology + traffic separated)

**Chosen**: 
- `GET /graph/topology` — slow-changing, cached for 10 minutes, returns full node/edge/group structure
- `GET /graph/traffic` — live, polled every 30s, returns aggregated flow stats

**Why**: Topology changes only when someone adds an application or service (rare). Traffic changes constantly. Separating them means the graph structure is stable and only the styling (edge width, color) re-renders on each poll. This also makes the "As-built vs Live" toggle trivial — just stop applying traffic data to edges.

**Alternative considered**: Single merged endpoint — eliminated because it would force a full graph re-render every 30s, causing visual instability.

### D4: Hierarchical left→center→right layout (not force-directed)

**Chosen**: Fixed positional layout matching the `cgs-landscape.archimate` model structure

**Why**: CGS is a hub-and-spoke architecture — every app connects through CGS. A force-directed layout would collapse into a star with CGS at the center and all edges radiating outward, which is visually cluttered and loses domain grouping meaning. The reference architecture image (Gooise Meren) confirms that hierarchical left=consumers, center=CGS, right=national systems is the correct mental model for this domain.

**Alternative considered**: Dagre (auto-hierarchical layout) — could work but produces inconsistent node placement across renders; fixed positions from the ArchiMate model are more predictable and match stakeholder mental models.

### D5: Edge styling encodes traffic semantics

| Metric | Visual encoding |
|---|---|
| Call volume (calls/day) | Edge stroke width (1px–6px) |
| Error rate 0–10% | Edge color: green |
| Error rate 10–50% | Edge color: amber |
| Error rate >50% | Edge color: red, pulsing animation |
| No traffic in window | Edge color: light gray (dashed) |

**Why**: Business stakeholders understand "thick red line = problem" without needing to read numbers. The sidebar shows exact numbers when they click.

## Risks / Trade-offs

**[Sparse live traffic]** → `logservicerequest` has only ~100 rows (15 distinct flows). Most edges will show as gray/dashed. \
_Mitigation_: Frame this as a strength in the demo — "This is real data, not synthetic." The 15 active flows are clearly highlighted against the full topology.

**[CORS between ports :8000 and :5173]** → Browser blocks requests from frontend to backend by default. \
_Mitigation_: Add `CORSMiddleware` to FastAPI allowing `http://localhost:5173`. One line of config.

**[React Flow node nesting depth]** → React Flow supports parent-child nesting but requires explicit `parentId` assignment and careful position management. \
_Mitigation_: Use absolute positioning for all nodes (positions derived from the ArchiMate layout we already built). Nodes inside groups use positions relative to group origin.

**[psycopg2 sync blocking in async FastAPI]** → psycopg2 is synchronous; mixing with async FastAPI can block the event loop. \
_Mitigation_: Use `run_in_executor` wrapper or switch to `psycopg2` with `def` (sync) routes, which FastAPI runs in a thread pool automatically. Keep it simple — no async DB calls needed for two read-only endpoints.

**[Hackathon scope creep]** → Stakeholders will ask for drill-down, time pickers, individual service nodes. \
_Mitigation_: The clean `topology / traffic` API separation means these are additive features. Document as "Phase 2" in the sidebar.

## Open Questions

- Should the sidebar show raw service names from `servicedefinition` when a category node is clicked, or just the count? _(Recommendation: show top 5 service names by call count)_
- Should the 24-hour traffic window be configurable in the UI, or hardcoded for the demo? _(Recommendation: hardcode for hackathon, add slider in Phase 2)_
- Which port should the backend use if 8000 is taken? _(Recommendation: make it an env variable `API_PORT`, default 8000)_
