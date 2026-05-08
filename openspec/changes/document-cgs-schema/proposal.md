## Why

The `inspect-cgs-schema` change extracted raw schema metadata (tables, columns, FKs, row counts) and produced an ER diagram, but the outputs lack human-readable documentation that explains the *semantic meaning* of each table, its role in the CGS domain, and how tables relate to each other in business terms. The team needs a documentation artifact that a new developer or architect can read to understand what CGS does and how its data model supports that, without having to reverse-engineer it from column names and FK constraints.

## What Changes

- Produce a comprehensive schema documentation file covering every core CGS table with:
  - Business-level description (what it represents in the service bus domain)
  - Semantic meaning of key columns (not just types — what they mean)
  - Relationship explanations in plain language (why table A references table B)
- Organize documentation by domain group (Service Bus Core, Adapter/Endpoint, CMIS, ebMS, Logging, Validation, Message/Transformation)
- Include a domain narrative that explains the end-to-end message flow through CGS tables
- This is a documentation-only step — no ArchiMate model changes

## Capabilities

### New Capabilities
- `schema-documentation`: Complete human-readable documentation of the CGS schema covering table purposes, column semantics, relationship explanations, and domain narratives

### Modified Capabilities
<!-- No existing capabilities are being modified -->

## Impact

- **Outputs**: New documentation file(s) in `openspec/specs/`
- **Dependencies**: Reads from existing `cgs-schema-overview.md`, `cgs-schema-tables.md`, and `cgs-schema-er-diagram.md` for raw data
- **No code changes**: Documentation only — no database, ArchiMate, or application changes
- **Consumers**: Team members, architects, new onboarding developers
