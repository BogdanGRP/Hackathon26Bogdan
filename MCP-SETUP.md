# MCP Setup

This workspace includes MCP servers that connect GitHub Copilot to the `igp_ontwikkel` PostgreSQL database and to the ArchiMate model, enabling Copilot to query the database and interact with architecture models directly during chat sessions.

## Prerequisites

- [Node.js](https://nodejs.org/) (v18 or later) — required to run `npx`
- Access to the `igp_ontwikkel` PostgreSQL instance at `localhost:5432` with superuser credentials
- VS Code with the **GitHub Copilot** extension installed

## Steps

### 1. Verify Node.js is installed

```bash
node --version
npx --version
```

Both commands should return a version number. If not, install Node.js from https://nodejs.org/.

### 2. Create the `hackathon` database user (one-time setup)

Connect to PostgreSQL as the `postgres` superuser and run the following SQL:

```sql
-- Create the read-only hackathon user
CREATE USER hackathon WITH PASSWORD 'hackathon';

-- Grant connect access to the database
GRANT CONNECT ON DATABASE igp_ontwikkel TO hackathon;

-- Add the user to the igp_ontwikkel_cgs_user role (grants SELECT access)
GRANT igp_ontwikkel_cgs_user TO hackathon;

-- Ensure no write privileges are granted
REVOKE CREATE ON SCHEMA public FROM hackathon;
```

You can use the `igp-ontwikkel-admin` MCP server (configured in `.vscode/mcp.json`) in VS Code to run these commands via Copilot chat, or use `psql`:

```bash
psql -h localhost -p 5432 -U postgres -d igp_ontwikkel
```

### 3. Open the workspace in VS Code

Open the `Hackathon26` folder in VS Code. The `.vscode/mcp.json` file is already included and will be picked up automatically.

### 4. Start the MCP servers

Open the Copilot chat panel and look for the MCP server controls, or run the **MCP: List Servers** command from the Command Palette (`Ctrl+Shift+P`).

The following servers should appear:

| Server | Purpose |
|---|---|
| `igp-ontwikkel-admin` | Admin connection (`postgres:postgres`) for initial setup only |
| `igp-ontwikkel-readonly` | Read-only connection (`hackathon:hackathon`) for day-to-day queries |
| `archimate` | ArchiMate model interaction |

Click **Start** on each server you want to use.

> On first run, `npx` will download the required packages automatically.

### 5. Verify the connections

In the Copilot chat, try:

```
list the tables in the igp_ontwikkel_cgs_owner schema
```

```
list the views in the archimate model
```

Copilot should be able to query the database and interact with the architecture model.

## Troubleshooting

| Problem | Solution |
|---|---|
| `npx` not found | Install Node.js and restart VS Code |
| Connection refused on `localhost:5432` | Make sure the PostgreSQL Docker container is running (`docker ps`) |
| Permission denied for `hackathon` user | Re-run the user creation SQL in step 2 |
| `hackathon` user does not exist | Run the `CREATE USER` statement in step 2 |

## Connection details

| Server | Host | Port | Database | User | Access |
|---|---|---|---|---|---|
| `igp-ontwikkel-admin` | `localhost` | `5432` | `igp_ontwikkel` | `postgres` | Superuser (setup only) |
| `igp-ontwikkel-readonly` | `localhost` | `5432` | `igp_ontwikkel` | `hackathon` | Read-only (`igp_ontwikkel_cgs_user` role) |
| `archimate` | — | — | — | — | ArchiMate MCP server |
