## ADDED Requirements

### Requirement: Traffic endpoint returns aggregated live flow data
The system SHALL expose a `GET /graph/traffic` HTTP endpoint that queries `igp_ontwikkel_cgs_owner.logservicerequest` and returns per-flow aggregated statistics for the last 24 hours.

#### Scenario: Successful traffic response
- **WHEN** a client sends `GET /graph/traffic`
- **THEN** the response SHALL have HTTP status 200
- **THEN** the response body SHALL contain a `flows` array and a `windowHours` integer (value: 24)
- **THEN** each flow SHALL include `consumer`, `service`, `provider`, `calls` (integer), and `errors` (integer)
- **THEN** flows SHALL be grouped by `(consumer, servicename, provider)` with counts aggregated

#### Scenario: Empty traffic window
- **WHEN** no rows exist in `logservicerequest` within the last 24 hours
- **THEN** `flows` SHALL be an empty array
- **THEN** the response SHALL still return HTTP 200

#### Scenario: Error rate is computable from response
- **WHEN** a flow has `calls: 12` and `errors: 12`
- **THEN** the client SHALL be able to compute `errorRate = errors / calls = 1.0` (100%)
- **THEN** the endpoint SHALL NOT pre-compute error rate — the client computes it

### Requirement: Traffic endpoint is not cached
The traffic endpoint SHALL return fresh data on every request and SHALL NOT cache responses, to reflect the live nature of the data.

#### Scenario: Consecutive requests return fresh data
- **WHEN** two requests are made to `GET /graph/traffic` 30 seconds apart
- **THEN** the second response SHALL reflect any new rows added to `logservicerequest` in that interval
