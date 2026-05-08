# MCP Postgres Setup

This workspace includes an MCP server that connects GitHub Copilot to the `igp_ontwikkel` PostgreSQL database, enabling Copilot to query the database directly during chat sessions.

## Prerequisites

- [Node.js](https://nodejs.org/) (v18 or later) — required to run `npx`
- Access to the `igp_ontwikkel` PostgreSQL instance at `localhost:5432`
- VS Code with the **GitHub Copilot** extension installed

## Steps

### 1. Verify Node.js is installed

```bash
node --version
npx --version
```

Both commands should return a version number. If not, install Node.js from https://nodejs.org/.

### 2. Open the workspace in VS Code

Open the `Hackathon26` folder in VS Code. The `.vscode/mcp.json` file is already included and will be picked up automatically.

### 3. Start the MCP server

Open the Copilot chat panel and look for the MCP server controls, or run the **MCP: List Servers** command from the Command Palette (`Ctrl+Shift+P`).

The server `igp-ontwikkel-readonly` should appear. Click **Start** if it is not already running.

> On first run, `npx` will download `@modelcontextprotocol/server-postgres` automatically.

### 4. Verify the connection

In the Copilot chat, try:

```
list the tables in the igp_ontwikkel_cgs_owner schema
```

Copilot should be able to query the database and return results.

## Troubleshooting

| Problem | Solution |
|---|---|
| `npx` not found | Install Node.js and restart VS Code |
| Connection refused on `localhost:5432` | Make sure the PostgreSQL Docker container is running (`docker ps`) |
| Permission denied | Check that your user has access to the `igp_ontwikkel` database |

## Connection details

| Property | Value |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `igp_ontwikkel` |
| User | `hackathon` |
| Access | Read-only |
