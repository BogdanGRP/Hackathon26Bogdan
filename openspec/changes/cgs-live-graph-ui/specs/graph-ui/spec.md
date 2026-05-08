## ADDED Requirements

### Requirement: Graph renders domain groups as visual containers
The UI SHALL render the service landscape as a React Flow diagram with three columns of domain group containers: consumer applications (left), CGS platform (center), national systems (right).

#### Scenario: Initial render shows all nodes grouped
- **WHEN** the application loads
- **THEN** 6 domain group containers SHALL be visible on the left column
- **THEN** 1 CGS Integration Platform container SHALL be visible in the center
- **THEN** 1 Landelijke Voorzieningen container SHALL be visible on the right
- **THEN** all application nodes SHALL be rendered inside their respective group containers
- **THEN** 6 service category nodes SHALL be rendered inside the CGS container

#### Scenario: Edges connect consumers to service categories and providers
- **WHEN** the topology loads
- **THEN** directed edges SHALL connect application nodes to service category nodes
- **THEN** directed edges SHALL connect service category nodes to external provider nodes
- **THEN** edge direction SHALL flow left → center → right

### Requirement: Live traffic mode styles edges by call volume and error rate
The UI SHALL have a "Live" toggle that, when active, overlays traffic data on the graph edges.

#### Scenario: Live mode shows edge thickness by call volume
- **WHEN** Live mode is active
- **THEN** edges with higher call volume SHALL be rendered with greater stroke width (range: 1px to 6px)
- **THEN** edges with zero calls in the last 24 hours SHALL render as dashed gray lines

#### Scenario: Live mode colors edges by error rate
- **WHEN** Live mode is active and an edge has error rate 0–10%
- **THEN** the edge SHALL render in green
- **WHEN** Live mode is active and an edge has error rate 10–50%
- **THEN** the edge SHALL render in amber
- **WHEN** Live mode is active and an edge has error rate > 50%
- **THEN** the edge SHALL render in red with a pulsing animation

#### Scenario: As-built mode shows clean architecture
- **WHEN** Live mode is toggled off (As-built mode)
- **THEN** all edges SHALL render in the default neutral color with equal stroke width
- **THEN** no traffic-derived styling SHALL be visible

### Requirement: Traffic data auto-refreshes every 30 seconds
The UI SHALL poll `GET /graph/traffic` every 30 seconds and update edge styling without re-rendering the entire graph.

#### Scenario: Silent refresh updates edges
- **WHEN** 30 seconds elapse since the last traffic fetch
- **THEN** a new request to `/graph/traffic` SHALL be made automatically
- **THEN** edge widths and colors SHALL update to reflect new data
- **THEN** node positions and group containers SHALL NOT move during the refresh

### Requirement: Node selection shows a detail sidebar
The UI SHALL display a sidebar panel when the user clicks a node, showing connections and traffic statistics.

#### Scenario: Clicking an application node shows its services
- **WHEN** the user clicks an application component node
- **THEN** a sidebar SHALL appear showing the application's name and description
- **THEN** the sidebar SHALL list the service categories this application connects to
- **THEN** if Live mode is active, the sidebar SHALL show total calls and errors for this application in the last 24 hours

#### Scenario: Clicking a service category node shows its consumers
- **WHEN** the user clicks a service category node
- **THEN** a sidebar SHALL show the category name and total service count
- **THEN** the sidebar SHALL list the top-5 applications using this category by call volume
- **THEN** if Live mode is active, the sidebar SHALL show total calls and error rate for this category

#### Scenario: Clicking empty canvas dismisses the sidebar
- **WHEN** the user clicks on the canvas background
- **THEN** the sidebar SHALL close

### Requirement: UI runs on localhost with a single dev command
The frontend SHALL start with `npm run dev` and be accessible at `http://localhost:5173` with no additional configuration required beyond the backend running on `http://localhost:8000`.

#### Scenario: Cold start works out of the box
- **WHEN** `npm install` is run once and then `npm run dev` is executed
- **THEN** the application SHALL be accessible at `http://localhost:5173`
- **THEN** the application SHALL display the graph using data from `http://localhost:8000`
