# CGS Schema Overview — `igp_ontwikkel_cgs_owner`

> Auto-generated from live database inspection on 2026-05-08.
> Schema: `igp_ontwikkel_cgs_owner` in database `igp_ontwikkel` at `localhost:5432`.

---

## Summary

| Metric | Value |
|---|---|
| Total tables | 46 |
| Core config tables | 30 |
| Audit tables (`_aud`) | 6 |
| System / revision tables | 1 (`revinfo`) + 1 (`cgssetting`) |
| Foreign key constraints | 66 |
| Tables with data (rows > 0) | 24 |
| Empty tables | 22 |

---

## Domain Groups

The 46 tables organize into **8 functional domains**. This grouping reflects the CGS (Configuratie Generieke Services) system — a **service bus / integration broker** that routes messages between municipal applications.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        CGS — Domain Overview                           │
│                                                                        │
│   ┌──────────────┐        ┌──────────────────┐                         │
│   │ APPLICATION  │◀──────▶│  SERVICE USAGE    │  (which app uses which  │
│   │  (7 rows)    │        │   (657 rows)      │   service)             │
│   └──────┬───────┘        └────────┬─────────┘                         │
│          │                         │                                   │
│          ▼                         ▼                                   │
│   ┌──────────────┐        ┌──────────────────┐                         │
│   │ CERTIFICATE  │        │ SERVICE DEF      │                         │
│   │  (0 rows)    │        │  (220 rows)      │◀── core service catalog │
│   └──────────────┘        └────────┬─────────┘                         │
│                                    │                                   │
│                    ┌───────────────┼───────────────┐                   │
│                    ▼               ▼               ▼                   │
│            ┌──────────────┐ ┌────────────┐ ┌─────────────────┐         │
│            │ CHANNEL DEF  │ │ SVC COMP   │ │ MESSAGE DEF     │         │
│            │  (14 rows)   │ │ RELATION   │ │  (32 rows)      │         │
│            └──────┬───────┘ │ (41 rows)  │ └────────┬────────┘         │
│                   │         └────────────┘          │                  │
│                   ▼                                 ▼                  │
│           ┌──────────────┐                  ┌─────────────────┐        │
│           │ ADAPTER      │                  │ TRANSFORMATION  │        │
│           │ ENDPOINT     │                  │ DEFINITION      │        │
│           │ (14 rows)    │                  │  (5 rows)       │        │
│           └──────┬───────┘                  └─────────────────┘        │
│                  │                                                     │
│                  ▼                                                     │
│           ┌──────────────┐         ┌──────────────┐                    │
│           │ ADAPTER DEF  │         │ ENDPOINT     │                    │
│           │  (7 rows)    │         │ CONFIG       │                    │
│           │              │         │ (491 rows)   │                    │
│           └──────────────┘         └──────────────┘                    │
│                                                                        │
│   ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌──────────────┐             │
│   │ LOGGING │  │  ebMS   │  │  CMIS   │  │ VALIDATION   │             │
│   │ domain  │  │ domain  │  │ domain  │  │ domain       │             │
│   └─────────┘  └─────────┘  └─────────┘  └──────────────┘             │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 1. Core Service Configuration

The central domain. Defines **what services exist**, **how they route**, and **which applications consume them**.

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `servicedefinition` | 220 | **The service catalog.** Each row is a named service (e.g. "iLogboekService", "GeodataService") with transport format (AXIOM), handling (SYN/ASYN), QoS (BESTEFFORT/RELIABLE), status (ACTIVE/INACTIVE), and logging/validation flags. |
| `serviceusage` | 657 | **Junction table: application ↔ service.** Records which application is authorized to use which service. The highest-volume config table. |
| `servicecomponentrelation` | 41 | **Wiring table.** Links a service to its implementing adapter, optional orchestration, and request/response/fault message definitions. This is the "how a service is physically fulfilled" configuration. |
| `channeldefinition` | 14 | **Routing rules.** Each channel links a service to an adapter endpoint, with optional orchestration, message filters (by application, XPath, organisation), and request/response/fault transformations. The "dynamic routing" layer. |

### Relationships

```
serviceusage ───────────▶ servicedefinition
serviceusage ───────────▶ application

servicecomponentrelation ─▶ servicedefinition
servicecomponentrelation ─▶ adapterdefinition
servicecomponentrelation ─▶ orchestrationdefinition (nullable)
servicecomponentrelation ─▶ messagedefinition (×3: request, response, fault)

channeldefinition ────────▶ servicedefinition
channeldefinition ────────▶ adapterendpoint (nullable)
channeldefinition ────────▶ orchestrationdefinition (nullable)
channeldefinition ────────▶ application (filterprovidingapplication)
channeldefinition ────────▶ messagedefinition (filtermessagedefinition, nullable)
channeldefinition ────────▶ transformationdefinition (×3: request, response, fault — all nullable)
```

---

## 2. Adapter Layer

Defines **connectivity** — the adapters that send/receive messages to/from external systems.

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `adapterdefinition` | 7 | **Adapter types.** Each row defines an adapter class: name, type (HTTP/JAVA/WEBSERVICE), direction (OUTGOING/INCOMING), and Java implementation class (e.g. `nl.makelaarsuite.cgs.services.adapter.out.http.cmis.CMISBrowserBasedAdapter`). |
| `adapterendpoint` | 14 | **Named adapter instances.** Binds an adapter definition to an application alias. A logical "connection point" that channels and endpoint configurations reference. |
| `adaptersetting` | 0 | **Key-value settings** per endpoint configuration. Name, type, value, default, domain values. Currently empty. |
| `endpointconfiguration` | 491 | **Physical connection details.** The largest config table after serviceusage. Contains URL, credentials, SOAP version, WS-Security, MTOM, proxy, MQ (manager/channel/queue), ebMS, and file transfer settings per adapter endpoint. Multi-protocol support in a single table. |

### Relationships

```
adapterendpoint ──────────▶ adapterdefinition
adapterendpoint ──────────▶ application (applicationalias)

adaptersetting ───────────▶ endpointconfiguration

endpointconfiguration ────▶ adapterendpoint
endpointconfiguration ────▶ certificate (TLS cert, nullable)
endpointconfiguration ────▶ certificate (signing cert, nullable)
```

---

## 3. Application Layer

The **external systems** that CGS integrates.

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `application` | 7 | **Application registry.** Each row is an external system (e.g. ROSWOZ, TERCERA, GEODATA, iAdministratie, SQUIT2020, DSO, SNG). Has a `dtype` discriminator column (all "Appl" currently — Hibernate single-table inheritance). Self-referencing `application_id` FK allows parent/child grouping. |
| `applicationopeningperiod` | 0 | **Availability windows.** Per-weekday (mon–sun) time ranges when an application accepts messages. Currently unused. |
| `certificate` | 0 | **TLS/signing certificates.** Stores alias, CN, org, serial, issuer, validity dates, and type. Referenced by endpoint configurations and ebMS CPAs. Currently empty. |

### Relationships

```
application ──────────────▶ application (self-ref: parent, nullable)

applicationopeningperiod ─▶ application

certificate ──────────────▶ application (nullable)
```

---

## 4. Message Layer

Defines the **message types** and **transformations** used by services.

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `messagedefinition` | 32 | **Message type catalog.** Identified by messagekey + namespace + optional soapaction. Used to match incoming messages to the correct service. |
| `elementdefinition` | 0 | **Message element hierarchy.** Defines XML elements within a message definition. Self-referencing `parent_id` creates tree structure. Currently empty. |
| `transformationdefinition` | 5 | **XSLT transformation specs.** Links a source message definition to a target message definition plus XSLT content. Used by channels for request/response/fault transformation. |
| `xsltcontent` | 1 | **Actual XSLT stylesheet content.** Referenced by transformation definitions. |

### Relationships

```
elementdefinition ────────▶ messagedefinition
elementdefinition ────────▶ elementdefinition (self-ref: parent)

transformationdefinition ─▶ messagedefinition (original)
transformationdefinition ─▶ messagedefinition (target)
transformationdefinition ─▶ xsltcontent
```

---

## 5. Orchestration

Defines **workflow/orchestration logic** for services that need multi-step processing.

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `orchestrationdefinition` | 0 | **Orchestration specifications.** Name, description, and Java implementation class. Currently empty — services use direct adapter routing instead. |
| `orchestrationsetting` | 0 | **Key-value settings** per orchestration. Currently empty. |

### Relationships

```
orchestrationsetting ────▶ orchestrationdefinition
```

---

## 6. CMIS (Content Management Interoperability Services)

Configuration for document management system integration.

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `cmisproviderconfiguration` | 2 | **CMIS provider types.** Vendor-specific configuration (e.g. Alfresco, SharePoint). |
| `cmisproviderproperty` | 28 | **Provider-side properties.** Metadata fields available in the CMIS provider. |
| `cmisconsumerproperty` | 23 | **Consumer-side properties.** Metadata fields used by CGS applications. |
| `cmispropertymapping` | 14 | **Property mapping bridge.** Maps a consumer property to provider in/out properties within a repository context. |
| `cmisrepository` | 2 | **CMIS repository instances.** Links to adapter endpoint and provider configuration. Stores repo ID, vendor, product info. |

### Relationships

```
cmisproviderproperty ─────▶ cmisproviderconfiguration

cmisrepository ───────────▶ adapterendpoint
cmisrepository ───────────▶ cmisproviderconfiguration

cmispropertymapping ──────▶ cmisrepository
cmispropertymapping ──────▶ cmisconsumerproperty
cmispropertymapping ──────▶ cmisproviderproperty (in)
cmispropertymapping ──────▶ cmisproviderproperty (out)
```

---

## 7. ebMS (Electronic Business Messaging Service)

Support for the Dutch government ebMS/MSH messaging standard (Digikoppeling).

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `ebmscpa` | 0 | **Collaboration Protocol Agreements.** Stores CPA XML documents with alias, end date, and linked certificate. |
| `ebmsmessage` | 0 | **ebMS messages.** Full message envelope: headers, content, conversation ID, sequence, roles, service/action, status. |
| `ebmsattachment` | 0 | **MIME attachments** on ebMS messages. |
| `ebmssendevent` | 0 | **Send event log** for reliable messaging retry. |
| `ebmsmapping` | 0 | **Routing/mapping rules** for ebMS message processing. |

### Relationships

```
ebmscpa ──────────────────▶ certificate (nullable)

ebmsmessage ──────────────▶ ebmscpa

ebmsattachment ───────────▶ ebmsmessage

ebmssendevent ────────────▶ ebmsmessage
```

---

## 8. Logging

Operational logging of service request/response traffic through CGS.

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `logservicerequest` | 22 | **Top-level log entry** per service invocation. Records consumer/provider, timing, status, error flag, ebMS IDs, and references request/response messages. Self-referencing for nested (parent) service calls. |
| `logroute` | 22 | **Log entry per outbound route** within a service request. Records which adapter endpoint was used, timing, and references to transformed request/response messages. |
| `logaction` | 148 | **Granular action log.** Individual steps within a service request or route: name, result, duration, description. |
| `logmessage` | 66 | **Message content store.** Stores actual XML/SOAP message payloads (messagekey, namespace, config name, full message text). |
| `logattachment` | 0 | **Attachments** on logged messages. Currently empty. |

### Relationships

```
logservicerequest ────────▶ logmessage (request, nullable)
logservicerequest ────────▶ logmessage (response, nullable)
logservicerequest ────────▶ logservicerequest (parent, nullable — for nested calls)

logroute ─────────────────▶ logservicerequest
logroute ─────────────────▶ logmessage (transformed request, nullable)
logroute ─────────────────▶ logmessage (response, nullable)
logroute ─────────────────▶ logmessage (transformed response, nullable)

logaction ────────────────▶ logservicerequest (nullable)
logaction ────────────────▶ logroute (nullable)

logattachment ────────────▶ logmessage
```

---

## 9. Validation

Message validation rules — currently **entirely empty** (all 4 tables have 0 rows).

### Tables

| Table | Rows | Semantic Role |
|---|---|---|
| `validator` | 0 | Validator definitions. |
| `validatoraction` | 0 | Actions per validator. |
| `validatoractioncfg` | 0 | Configuration per validator action. |
| `messagevalidation` | 0 | Links element definitions to validators. |
| `messagevalidationaction` | 0 | Links message validations to validator actions. |
| `messagevalidationactioncfg` | 0 | Configuration per message validation action. |

### Relationships

```
validatoraction ──────────▶ validator
validatoractioncfg ───────▶ validatoraction

messagevalidation ────────▶ elementdefinition
messagevalidation ────────▶ validator

messagevalidationaction ──▶ messagevalidation
messagevalidationaction ──▶ validatoraction

messagevalidationactioncfg ▶ messagevalidationaction
messagevalidationactioncfg ▶ validatoractioncfg
```

---

## 10. Audit / Revision Tracking (Hibernate Envers)

### Tables

| Table | PK | Semantic Role |
|---|---|---|
| `revinfo` | `id` | **Revision metadata.** Timestamp + username for each revision. 106 revisions recorded. |
| `adapterendpoint_aud` | `id, rev` | Audit trail for adapter endpoint changes. |
| `adaptersetting_aud` | `id, rev` | Audit trail for adapter setting changes. |
| `application_aud` | `id, rev` | Audit trail for application changes. |
| `channeldefinition_aud` | `id, rev` | Audit trail for channel definition changes. |
| `endpointconfiguration_aud` | `id, rev` | Audit trail for endpoint config changes. |
| `orchestrationsetting_aud` | `id, rev` | Audit trail for orchestration setting changes. |

All `_aud` tables have a composite PK of `(id, rev)` and FK to `revinfo.id`.

---

## 11. System Settings

| Table | Rows | Semantic Role |
|---|---|---|
| `cgssetting` | 0 | **Global CGS settings.** Key-value configuration for the CGS system itself (name, type, value, default, domain). Currently empty. |

---

## Complete FK Relationship Graph

```
                          ┌──────────────────┐
                          │    revinfo        │
                          │   (audit hub)     │
                          └────────▲─────────┘
                                   │ (all _aud tables)
                    ┌──────────────┼──────────────────┐
                    │              │                   │
              ┌─────┴──────┐ ┌────┴─────────┐  ┌──────┴──────────┐
              │ *_aud (×6) │ │              │  │                 │
              └────────────┘ │              │  │                 │
                             │              │  │                 │
    ┌────────────────────────┤              │  │                 │
    │                        │              │  │                 │
    ▼                        │              │  │                 │
┌──────────┐          ┌──────┴───────┐      │  │                 │
│xsltcontent│◀────────│transform.def │      │  │                 │
└──────────┘          └──────▲───────┘      │  │                 │
                             │(×3)          │  │                 │
                    ┌────────┴─────────┐    │  │                 │
                    │ channeldefinition │    │  │                 │
                    └───┬──┬──┬──┬─────┘    │  │                 │
                        │  │  │  │          │  │                 │
         ┌──────────────┘  │  │  └──────┐   │  │                 │
         ▼                 │  ▼         ▼   │  │                 │
┌────────────────┐         │ ┌────────┐ ┌───┴──┴───────┐         │
│ adapterendpoint│◀────────┘ │ orch.  │ │ service      │         │
│                │           │ def.   │ │ definition   │         │
└──┬─────────┬───┘           └───▲────┘ └──▲───▲───────┘         │
   │         │                   │         │   │                 │
   ▼         ▼                   │         │   │                 │
┌──────┐  ┌──────────┐    ┌─────┴───┐  ┌──┴───┴──────┐          │
│adapt.│  │applicat. │    │orch.    │  │svc.comp.    │          │
│ def. │  │          │◀───┤setting  │  │relation     │──▶message│
└──────┘  └────┬─────┘    └─────────┘  └─────────────┘   def.   │
               │                                         (×3)   │
          ┌────┼────────────────┐                                │
          ▼    ▼                ▼                                 │
     ┌────────┐ ┌────────────┐ ┌────────────┐                   │
     │cert.   │ │app.opening │ │serviceusage│                   │
     │        │ │period      │ │ (657 rows) │                   │
     └───▲────┘ └────────────┘ └────────────┘                   │
         │                                                       │
    ┌────┴────────┐         ┌──────────────────────────────┐     │
    │endpoint     │         │      message                 │     │
    │config.      │         │      definition   ◀──────────┘     │
    │ (491 rows)  │         └──────────▲───────────────┘         │
    └─────────────┘                    │                         │
                               ┌───────┴───────┐                │
                               │elementdefinit. │                │
                               │(self-ref tree) │                │
                               └───────▲────────┘                │
                                       │                         │
                               ┌───────┴────────┐               │
                               │messagevalidat. │               │
                               └────────────────┘               │
```

---

## Cross-Cutting Patterns

### Every table has...
- `id` (numeric) — surrogate primary key
- `changecounter` (numeric, default 1) — optimistic locking version

### Most config tables have...
- `factorysetting` (boolean, default false) — marks factory/default records vs. user-created

### Self-referencing tables
- `application.application_id → application.id` (parent/child apps)
- `elementdefinition.parent_id → elementdefinition.id` (XML element tree)
- `logservicerequest.parentservicerequest_id → logservicerequest.id` (nested calls)

### Hub tables (most referenced)
1. **`application`** — referenced by: serviceusage, adapterendpoint, channeldefinition, certificate, applicationopeningperiod, application (self)
2. **`servicedefinition`** — referenced by: serviceusage, servicecomponentrelation, channeldefinition
3. **`messagedefinition`** — referenced by: servicecomponentrelation (×3), channeldefinition, transformationdefinition (×2), elementdefinition
4. **`adapterendpoint`** — referenced by: channeldefinition, endpointconfiguration, cmisrepository
5. **`revinfo`** — referenced by: all 6 `_aud` tables
6. **`logmessage`** — referenced by: logservicerequest (×2), logroute (×3), logattachment

---

## Semantic Interpretation

**CGS is an Enterprise Service Bus (ESB) configuration database** for the Dutch municipal software platform "Makelaarsuite" (MKS). It manages:

1. **Service definitions** — the catalog of integration services available
2. **Service wiring** — which adapter implements each service, which message formats it expects
3. **Routing channels** — conditional routing rules (by application, XPath, organisation)
4. **Endpoint configs** — physical connection details (URLs, credentials, queues, certificates)
5. **Message transformations** — XSLT transforms between source and target message formats
6. **Application registry** — the external systems that produce/consume messages
7. **Operational logging** — request/response traffic audit trail
8. **CMIS integration** — document management property mapping
9. **ebMS messaging** — Digikoppeling (Dutch government messaging standard) support

The naming uses Dutch (e.g. "Uitgaande" = outgoing, "ophalen" = retrieve, "versies" = versions, "beschikbare" = available).
