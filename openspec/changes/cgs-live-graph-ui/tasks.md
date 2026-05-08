## 1. Project Scaffold

- [ ] 1.1 Create `ui/` folder at repo root with `ui/backend/` and `ui/frontend/` subdirectories
- [ ] 1.2 Create `ui/backend/requirements.txt` with: `fastapi`, `uvicorn[standard]`, `psycopg2-binary`
- [ ] 1.3 Scaffold `ui/frontend/` with Vite + React + TypeScript: `npm create vite@latest frontend -- --template react-ts`
- [ ] 1.4 Install React Flow in frontend: `npm install @xyflow/react`
- [ ] 1.5 Create `ui/README.md` with start instructions (two terminal commands)

## 2. Backend — Topology Endpoint

- [ ] 2.1 Create `ui/backend/main.py` with FastAPI app, CORS middleware allowing `http://localhost:5173`
- [ ] 2.2 Create `ui/backend/db.py` with psycopg2 connection helper using `postgresql://hackathon:hackathon@127.0.0.1:5432/igp_ontwikkel`
- [ ] 2.3 Implement `GET /graph/topology` route — query `application`, `serviceusage`, `servicedefinition` tables
- [ ] 2.4 Filter topology to top-20 production apps (by service count, `usagelevel = 'PRODUCTION'`) plus 6 service category nodes
- [ ] 2.5 Map apps to their domain groups (Burgerzaken, Zaakgericht Werken, Sociaal Domein, Belastingen en Middelen, Geo en Ruimte, Portaal en Integratie, CGS Platform, Landelijke Voorzieningen)
- [ ] 2.6 Return `{ nodes: [...], edges: [...], groups: [...] }` with correct `id`, `label`, `type`, `groupId`, `position` fields — use ArchiMate element type names for `type` field per `openspec/changes/archimate-modeling-conventions/specs/element-type-conventions/spec.md` (apps → `ApplicationComponent`, service categories → `ApplicationService`, groups → `Grouping`)
- [ ] 2.7 Add simple in-memory cache (Python `functools.lru_cache` or TTL dict) — cache topology for 10 minutes

## 3. Backend — Traffic Endpoint

- [ ] 3.1 Implement `GET /graph/traffic` route — query `logservicerequest` for rows in last 24 hours
- [ ] 3.2 Aggregate by `(consumer, servicename, provider)` — compute `calls` count and `errors` sum per group
- [ ] 3.3 Return `{ flows: [...], windowHours: 24 }` — no caching on this endpoint
- [ ] 3.4 Verify backend starts cleanly: `uvicorn main:app --reload --port 8000` from `ui/backend/`
- [ ] 3.5 Check OpenAPI docs at `http://localhost:8000/docs` show both endpoints correctly

## 4. Frontend — Graph Layout

- [ ] 4.1 Create `src/types.ts` with TypeScript types for `TopologyNode`, `TopologyEdge`, `TopologyGroup`, `TrafficFlow`
- [ ] 4.2 Create `src/api.ts` with `fetchTopology()` and `fetchTraffic()` functions calling the backend
- [ ] 4.3 Create `src/layout.ts` — map topology response to React Flow `nodes` and `edges` arrays with fixed x/y positions (left column: x=20, center: x=400, right: x=860) per the three-zone layout in `openspec/changes/archimate-modeling-conventions/specs/view-layout-conventions/spec.md`
- [ ] 4.4 Assign domain group containers as React Flow parent nodes — set `parentId` on each app node
- [ ] 4.5 Render the base graph in `App.tsx` — load topology on mount, display `<ReactFlow>` with nodes, edges, and group containers
- [ ] 4.6 Verify all 20 app nodes, 6 service category nodes, and 8 group containers render without overlap

## 5. Frontend — Live Traffic Overlay

- [ ] 5.1 Create `src/trafficStyles.ts` — function `applyTrafficToEdges(edges, flows)` that returns edges with updated `style` (strokeWidth, stroke color) based on call volume and error rate thresholds
- [ ] 5.2 Implement Live/As-built toggle button in the UI — state `isLive: boolean`
- [ ] 5.3 When `isLive=true`, apply traffic styles to edges; when false, use default neutral styles
- [ ] 5.4 Implement 30-second polling — `setInterval` calling `fetchTraffic()` and re-applying styles without re-rendering nodes
- [ ] 5.5 Add pulsing CSS animation for edges with error rate > 50% (red pulsing)
- [ ] 5.6 Gray dashed style for edges with zero traffic in the 24h window

## 6. Frontend — Sidebar Panel

- [ ] 6.1 Create `src/Sidebar.tsx` component — receives selected node data, renders name, description, connection list
- [ ] 6.2 On app node click: show app name, description, list of connected service categories, and (if live mode) total calls + errors in 24h
- [ ] 6.3 On service category node click: show category name, service count, top-5 consumers by call volume
- [ ] 6.4 On canvas click (no node): dismiss sidebar
- [ ] 6.5 Style sidebar — fixed right panel, clean typography suitable for business stakeholder presentation

## 7. Polish and Demo Readiness

- [ ] 7.1 Add a header bar with title "CGS Service Landscape", last-refresh timestamp, and Live/As-built toggle
- [ ] 7.2 Add node icons or color-coding to distinguish `application` nodes from `service-category` nodes
- [ ] 7.3 Test end-to-end: start backend, start frontend, verify graph loads, traffic overlays appear, sidebar works
- [ ] 7.4 Verify the 15 known active flows from `logservicerequest` appear as styled edges in Live mode
- [ ] 7.5 Update `ui/README.md` with full setup and start instructions
- [ ] 7.6 Commit all `ui/` files and push to `main`
