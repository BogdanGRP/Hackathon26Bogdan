## Why

The CGS integration platform connects 55+ municipal applications through a service bus, but there is no visual way for business stakeholders or consultants to understand which systems are connected, which services are active, and where live traffic is flowing. Architecture documentation exists only as static ArchiMate files. This demo-quality UI addresses that gap and lays the foundation for an operational monitoring tool.

## What Changes

- **New**: A single-page web application that renders the CGS service landscape as an interactive graph
- **New**: A lightweight FastAPI backend with two endpoints serving topology and live traffic data from `igp_ontwikkel` PostgreSQL
- **New**: Live traffic heatmap overlay — edge thickness and color reflect call volume and error rate from `logservicerequest`
- **New**: Domain grouping containers (Burgerzaken, Zaakgericht, Sociaal Domein, Belastingen, Geo, Portaal) matching the `cgs-landscape.archimate` model
- **New**: Toggle between "Live" view (traffic overlay) and "As-built" view (clean architecture)
- **New**: Click/hover interactions — select a node to see its connected services and traffic stats in a sidebar

## Capabilities

### New Capabilities

- `graph-topology-api`: FastAPI backend endpoint that queries `serviceusage`, `application`, and `servicedefinition` tables and returns a graph payload `{ nodes, edges, groups }` representing the top-20 application landscape with 6 service category nodes
- `graph-traffic-api`: FastAPI backend endpoint that aggregates `logservicerequest` data (last 24 hours) into per-flow call counts and error rates, returned as `{ flows: [{consumer, service, provider, calls, errors}] }`
- `graph-ui`: React + React Flow frontend that renders domain groups as containers, application components as nodes, service categories as intermediate nodes, and serving relationships as directed edges with live traffic styling

### Modified Capabilities

<!-- none — this is a net-new addition, no existing specs are affected -->

## Impact

- **New code**: `ui/` folder in the repo root with `ui/backend/` (Python/FastAPI) and `ui/frontend/` (React/Vite/React Flow)
- **Database**: Read-only queries against existing `igp_ontwikkel_cgs_owner` tables — no schema changes
- **Dependencies**: Python (`fastapi`, `uvicorn`, `psycopg2-binary`), Node.js (`react`, `reactflow`, `vite`)
- **Runtime**: Localhost only — backend on port 8000, frontend on port 5173
- **Existing files**: No changes to ArchiMate models, OpenSpec changes, or schema documentation
