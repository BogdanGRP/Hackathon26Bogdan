## ADDED Requirements

### Requirement: Topology endpoint returns graph structure
The system SHALL expose a `GET /graph/topology` HTTP endpoint that queries the `igp_ontwikkel_cgs_owner` schema and returns a JSON payload describing the full application landscape as a graph.

#### Scenario: Successful topology response
- **WHEN** a client sends `GET /graph/topology`
- **THEN** the response SHALL have HTTP status 200
- **THEN** the response body SHALL contain `nodes`, `edges`, and `groups` arrays
- **THEN** `nodes` SHALL include the top-20 production applications by service count plus 6 service category nodes (StUF Services, Query Services, BRP/GBA Services, Zaak Services, KVK/NHR Services, Integration Services)
- **THEN** `edges` SHALL represent serving relationships derived from the `serviceusage` table
- **THEN** each node SHALL include `id`, `label`, `type` (`application` or `service-category`), and `groupId`

#### Scenario: Topology is cached
- **WHEN** a second request is made within 10 minutes of the first
- **THEN** the response SHALL be served from cache without re-querying the database

#### Scenario: Groups are returned with domain metadata
- **WHEN** `GET /graph/topology` is called
- **THEN** each group in `groups` SHALL include `id`, `label`, and `position` (`left`, `center`, or `right`)
- **THEN** the 6 domain consumer groups SHALL have `position: "left"`
- **THEN** the CGS Integration Platform group SHALL have `position: "center"`
- **THEN** the Landelijke Voorzieningen group SHALL have `position: "right"`

### Requirement: CORS headers allow localhost frontend
The backend SHALL include CORS middleware permitting requests from `http://localhost:5173`.

#### Scenario: Frontend can call the API
- **WHEN** the React frontend at `http://localhost:5173` calls `GET /graph/topology`
- **THEN** the response SHALL include the header `Access-Control-Allow-Origin: http://localhost:5173`
- **THEN** the browser SHALL not block the request
