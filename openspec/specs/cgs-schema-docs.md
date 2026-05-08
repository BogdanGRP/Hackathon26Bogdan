# CGS Schema Documentation

> **Source schema:** `igp_ontwikkel_cgs_owner` | **Database:** `igp_ontwikkel` | **Inspected:** 2026-05-08
>
> This document provides human-readable documentation of the CGS (Configuratie Generieke Services) database schema — explaining what each table represents, the business meaning of key columns, and how tables relate to each other in domain terms.
>
> CGS is the **Enterprise Service Bus (ESB)** configuration database for the Dutch municipal software platform *Makelaarsuite (MKS)*. It routes messages between municipal applications such as ROSWOZ, TERCERA, GEODATA, iAdministratie, and SQUIT2020.

---

## Table of Contents

- [Domain Narrative — How a Message Flows Through CGS](#domain-narrative)
- [Domain 1 — Service Bus Core](#domain-1--service-bus-core)
  - [servicedefinition](#servicedefinition)
  - [serviceusage](#serviceusage)
  - [servicecomponentrelation](#servicecomponentrelation)
  - [channeldefinition](#channeldefinition)
  - [orchestrationdefinition](#orchestrationdefinition)
  - [orchestrationsetting](#orchestrationsetting)
- [Domain 2 — Application](#domain-2--application)
  - [application](#application)
  - [applicationopeningperiod](#applicationopeningperiod)
  - [certificate](#certificate)
- [Domain 3 — Adapter / Endpoint](#domain-3--adapter--endpoint)
  - [adapterdefinition](#adapterdefinition)
  - [adapterendpoint](#adapterendpoint)
  - [endpointconfiguration](#endpointconfiguration)
  - [adaptersetting](#adaptersetting)
- [Domain 4 — Message / Transformation](#domain-4--message--transformation)
  - [messagedefinition](#messagedefinition)
  - [elementdefinition](#elementdefinition)
  - [transformationdefinition](#transformationdefinition)
  - [xsltcontent](#xsltcontent)
- [Domain 5 — Validation](#domain-5--validation)
  - [validator](#validator)
  - [validatoraction](#validatoraction)
  - [validatoractioncfg](#validatoractioncfg)
  - [messagevalidation](#messagevalidation)
  - [messagevalidationaction](#messagevalidationaction)
  - [messagevalidationactioncfg](#messagevalidationactioncfg)
- [Domain 6 — CMIS](#domain-6--cmis)
  - [cmisproviderconfiguration](#cmisproviderconfiguration)
  - [cmisproviderproperty](#cmisproviderproperty)
  - [cmisconsumerproperty](#cmisconsumerproperty)
  - [cmisrepository](#cmisrepository)
  - [cmispropertymapping](#cmispropertymapping)
- [Domain 7 — ebMS Messaging](#domain-7--ebms-messaging)
  - [ebmscpa](#ebmscpa)
  - [ebmsmessage](#ebmsmessage)
  - [ebmsattachment](#ebmsattachment)
  - [ebmssendevent](#ebmssendevent)
  - [ebmsmapping](#ebmsmapping)
- [Domain 8 — Logging](#domain-8--logging)
  - [logmessage](#logmessage)
  - [logservicerequest](#logservicerequest)
  - [logroute](#logroute)
  - [logaction](#logaction)
  - [logattachment](#logattachment)
- [Domain 9 — System & Audit](#domain-9--system--audit)
  - [cgssetting](#cgssetting)
  - [revinfo](#revinfo)
  - [Audit tables (_aud)](#audit-tables-_aud)
- [Cross-Cutting Patterns](#cross-cutting-patterns)

---

## Domain Narrative

*How a message flows through CGS from consumer application to provider.*

CGS acts as a configuration-driven service bus: it does not process business logic itself, but configures routing, transformation, and authentication between municipal applications. Here is the end-to-end flow:

```
 Consumer Application
        │
        │  "I want to call GeodataService"
        ▼
 ┌─────────────────────────┐
 │  serviceusage            │  ← Is this application authorized to call this service?
 │  (application ↔ service) │    Lookup: (application_id, servicedefinition_id)
 └────────────┬────────────┘
              │  Yes → resolve service
              ▼
 ┌─────────────────────────┐
 │  servicedefinition       │  ← What are the rules for this service?
 │                          │    Transport: AXIOM, Handling: SYN, QoS: BESTEFFORT
 │                          │    Log request/response? Validate?
 └────────────┬────────────┘
              │
   ┌──────────┼───────────────────┐
   │          │                   │
   ▼          ▼                   ▼
channeldef  servicecomp.      (messagedefinition)
(routing)   (wiring)          request/response/fault
   │          │               format definitions
   │          └─▶ adapterdefinition (what kind of adapter?)
   │
   │  Apply channel filters:
   │    - filterprovidingapplication_id (which backend provides?)
   │    - filtermessagedefinition_id (which message format?)
   │    - filterxpath (XPath condition on message content)
   │    - filterconsumerorganisation / filterproviderorganisation
   │
   ▼
 ┌─────────────────────────┐
 │  adapterendpoint         │  ← Which named connection point to use?
 │                          │    (bound to adapterdefinition + application alias)
 └────────────┬────────────┘
              │
              ▼
 ┌─────────────────────────┐
 │  endpointconfiguration   │  ← What are the physical connection details?
 │                          │    URL, credentials, SOAP version, WS-Security,
 │                          │    MQ manager/channel/queue, ebMS settings, etc.
 └────────────┬────────────┘
              │
   (optional) │
   ┌──────────┴──────────┐
   │  transformationdefinition  │ ← Transform request/response between formats?
   │  → xsltcontent              │   Source messagedefinition → target messagedefinition
   └─────────────────────┘       via XSLT stylesheet
              │
              ▼
 Provider Application (external system)
              │
              ▼
 ┌─────────────────────────┐
 │  logservicerequest       │  ← Top-level audit entry created
 │  logroute               │  ← One entry per outbound route taken
 │  logaction              │  ← Granular step-by-step actions
 │  logmessage             │  ← Actual XML payloads stored
 └─────────────────────────┘
```

**Key insight:** CGS is *stateless at runtime* — all configuration is pre-defined in these tables. A service request triggers a lookup chain:
`serviceusage → servicedefinition → channeldefinition → adapterendpoint → endpointconfiguration`
and the result drives routing, transformation, and logging.

---

## Domain 1 — Service Bus Core

This domain defines **what services exist**, **who can use them**, **how they are wired**, and **how they are routed**. It is the heart of CGS — every message flows through these tables.

---

### servicedefinition

**Rows:** 220 | **Role:** The service catalog

Every CGS integration service is registered here. A service definition describes a named capability (e.g. "iLogboekService", "GeodataService", "WOZService") and its technical contract.

**Key columns:**
| Column | Meaning |
|---|---|
| `name` | The service name — typically a Dutch or English identifier like "iLogboekService" or "ophalen_beschikbare_versies" |
| `transportformat` | Currently always `AXIOM` — the Apache Axiom SOAP processing library used internally |
| `handling` | `SYN` (synchronous, caller waits for response) or `ASYN` (asynchronous, fire-and-forget) |
| `qualityofservice` | `BESTEFFORT` (no delivery guarantee) or `RELIABLE` (guaranteed delivery, typically via ebMS) |
| `status` | `ACTIVE` or `INACTIVE` — inactive services are not routable |
| `logrequest` / `logresponse` / `logfault` / `logattachments` | Flags controlling which parts of the message traffic are logged to the Logging domain tables |
| `logactionlevel` | Granularity of action logging (e.g. `NONE`, `BASIC`, `EXTENDED`) |
| `validation` | Whether incoming messages are validated against the Validation domain rules |
| `factorysetting` | `true` for default/factory services shipped with the platform; `false` for customer-specific services |

**Relationships:**
- Referenced by `serviceusage` — to record which applications are subscribed to this service
- Referenced by `servicecomponentrelation` — to wire the service to its adapter and message formats
- Referenced by `channeldefinition` — to define routing rules for this service

---

### serviceusage

**Rows:** 657 | **Role:** Application-to-service subscription registry (junction table)

This is the **authorization table**: it records which application is allowed to invoke which service. With 657 rows, it is the most populated configuration table in CGS.

The UNIQUE constraint on `(servicedefinition_id, application_id)` ensures each application-service pair appears at most once.

**Key columns:**
| Column | Meaning |
|---|---|
| `servicedefinition_id` | The service being subscribed to |
| `application_id` | The application that is authorized to call it |

**Relationship meaning:** This table bridges `application` and `servicedefinition`. A request from an application that has no `serviceusage` row for the target service will be rejected. The high row count (657) compared to only 7 applications and 220 services reflects that most applications subscribe to many services.

---

### servicecomponentrelation

**Rows:** 41 | **Role:** Service wiring — links a service to its physical implementation

Where `servicedefinition` says *what* a service is, `servicecomponentrelation` says *how* it is implemented. It wires a service to:
- The adapter type that handles its messages
- The orchestration workflow (if any)
- The request, response, and fault message formats

**Key columns:**
| Column | Meaning |
|---|---|
| `servicedefinition_id` | The service being wired |
| `adapterdefinition_id` | Which adapter type handles this service (e.g. HTTP, WEBSERVICE) |
| `orchestrationdefinition_id` | Optional: if the service requires orchestration (currently always null in live data) |
| `messagedefinitionrequest_id` | The expected format of incoming requests for this service |
| `messagedefinitionresponse_id` | The expected format of responses from this service |
| `messagedefinitionfault_id` | The format of SOAP fault responses |

**Relationship meaning:** This is the "contract specification" for a service. The 41 rows represent 41 service implementations wired up in the system. Services without a `servicecomponentrelation` cannot be routed.

---

### channeldefinition

**Rows:** 14 | **Role:** Dynamic routing rules

A channel defines how a service request should be routed to a specific backend endpoint. The key insight is that a single service can have *multiple channels* — CGS selects the right channel at runtime based on filter conditions.

**Key columns:**
| Column | Meaning |
|---|---|
| `servicedefinition_id` | The service this channel belongs to |
| `adapterendpoint_id` | The backend endpoint to route to (nullable — may use orchestration instead) |
| `orchestrationdefinition_id` | If set, route through an orchestration workflow instead of a direct endpoint |
| `filterprovidingapplication_id` | Route to this channel only when the *provider* is a specific application |
| `filtermessagedefinition_id` | Route only when the incoming message matches this message definition |
| `filterxpath` | Route only when this XPath expression evaluates to true on the message |
| `filterconsumerorganisation` / `filterproviderorganisation` | Route based on the consumer or provider organisation name in the message |
| `filterconsumingapplication` | Route based on the consumer application name |
| `requesttransformation_id` | Apply this XSLT transformation to the outgoing request |
| `responsetransformation_id` | Apply this XSLT transformation to the incoming response |
| `faulttransformation_id` | Apply this XSLT transformation to fault responses |
| `active` | Whether this channel is active and selectable |

**Relationship meaning:** Channels are the "routing table" of CGS. The filter columns allow context-sensitive routing: the same service call from different applications, with different message formats, or with different XPath conditions can be sent to different endpoints. Transformations on channels allow format bridging between consumer and provider message formats.

---

### orchestrationdefinition

**Rows:** 0 | **Role:** Multi-step workflow specifications

Defines named orchestration workflows — Java classes that implement multi-step processing logic (e.g. call service A, transform the result, call service B). Currently **empty** in this environment, meaning all services use direct adapter routing via `channeldefinition`.

**Key columns:**
| Column | Meaning |
|---|---|
| `implementation` | Fully qualified Java class that implements the orchestration logic |
| `name` | Business name of the workflow |

---

### orchestrationsetting

**Rows:** 0 | **Role:** Key-value configuration for orchestration workflows

Key-value settings passed to an orchestration definition's Java implementation. Mirrors the structure of `adaptersetting`. Currently **empty**.

**Relationship:** Each setting belongs to exactly one `orchestrationdefinition`.

---

## Domain 2 — Application

This domain holds the **external systems** that CGS integrates. In the live environment, 7 municipal applications are registered.

---

### application

**Rows:** 7 | **Role:** Registry of integrated municipal applications

Every system that sends or receives messages through CGS must be registered here. Examples from live data: ROSWOZ, TERCERA, GEODATA, iAdministratie, SQUIT2020, DSO, SNG.

**Key columns:**
| Column | Meaning |
|---|---|
| `dtype` | Hibernate single-table inheritance discriminator. Currently always `"Appl"` — reserved for potential future application subtypes |
| `name` | The application's identifier used throughout CGS (e.g. in `serviceusage`, `adapterendpoint.applicationalias_id`) |
| `namesearchfield` | Normalized/uppercase version of the name used for case-insensitive search |
| `application_id` | Self-referencing FK to `application` — allows grouping applications under a parent (e.g. a suite of related systems under one parent application) |
| `complementmessage` | Whether CGS should complement/enrich messages for this application |
| `organisationconfigurationname` | Name of the organisation configuration used for routing/filtering |
| `factorysetting` | `true` for platform-provided applications; `false` for customer-installed ones |

**Self-reference:** The `application_id → application.id` FK creates an optional parent-child hierarchy. In the current data with only 7 applications, this is used to group related systems.

---

### applicationopeningperiod

**Rows:** 0 | **Role:** Availability windows per weekday

Defines when an application is available to receive messages. CGS can use these windows to block or queue messages outside business hours. Currently **empty** — no availability restrictions are configured.

**Key columns:** Seven boolean columns (`monday` through `sunday`) plus `starttime` and `endtime` define per-day availability windows.

**Relationship:** Each opening period belongs to one `application`. An application may have multiple opening periods (e.g. different hours Mon–Fri vs. weekends).

---

### certificate

**Rows:** 0 | **Role:** TLS and signing certificates for applications

Stores X.509 certificate metadata used for:
1. TLS client authentication (referenced by `endpointconfiguration.certificate_id`)
2. WS-Security message signing (referenced by `endpointconfiguration.signingcertificate_id`)
3. ebMS CPA signing (referenced by `ebmscpa.certificate_id`)

Currently **empty** — either certificates are not configured in this environment, or TLS is handled outside CGS.

**Key columns:**
| Column | Meaning |
|---|---|
| `alias` | Short name used to reference this certificate in configurations |
| `canonicalname` | The CN (Common Name) field from the certificate's Distinguished Name |
| `serialnumber` | Unique certificate serial number from the issuing CA |
| `notbefore` / `notafter` | Certificate validity period — CGS can use these for expiry checks |
| `certificatetype` | Whether this is a TLS authentication certificate or a signing certificate |
| `application_id` | The application that owns this certificate (nullable — certificates may be shared) |

**UNIQUE constraint:** `(alias, certificatetype)` — each alias+type combination must be unique.

---

## Domain 3 — Adapter / Endpoint

This domain defines the **connectivity layer**: the adapters (software components) and endpoints (named connection instances) that send and receive messages to/from external systems.

The relationship chain is:
```
adapterdefinition → adapterendpoint → endpointconfiguration → adaptersetting
                                              ↑
                                         certificate (optional)
```

---

### adapterdefinition

**Rows:** 7 | **Role:** Adapter type catalog (root reference table)

Defines the types of software adapters available in CGS. Each row is a named adapter class — e.g. "CMISBROWSERBASEDADAPTER", "ILOGBOEKCLIQADAPTER", "WEBSERVICEADAPTER". These are Java implementations installed in the CGS platform.

**Key columns:**
| Column | Meaning |
|---|---|
| `adaptertype` | Protocol category: `HTTP`, `JAVA`, or `WEBSERVICE` |
| `direction` | `OUTGOING` (CGS sends to external) or `INCOMING` (external sends to CGS) |
| `implementation` | Fully qualified Java class name that implements the adapter |
| `description` | Dutch human-readable description of what this adapter does |
| `factorysetting` | Platform-provided adapter (`true`) vs. customer-added (`false`) |

**Relationship:** No outgoing FKs — this is a root table. Referenced by `adapterendpoint` and `servicecomponentrelation`.

---

### adapterendpoint

**Rows:** 14 | **Role:** Named adapter instances bound to applications

Where `adapterdefinition` defines an adapter *type*, `adapterendpoint` defines a *specific instance* of that adapter bound to a particular application alias. For example: "the HTTP adapter instance used for GEODATA" vs. "the HTTP adapter instance used for ROSWOZ".

**Key columns:**
| Column | Meaning |
|---|---|
| `adapterdefinition_id` | Which adapter type this endpoint is an instance of |
| `applicationalias_id` | The application that this endpoint represents on the receiving end — i.e., which external system this endpoint connects to |
| `name` | Human-readable name for this endpoint instance |
| `factorysetting` | Platform-provided (`true`) vs. customer-configured (`false`) |

**Relationship meaning:** `adapterendpoint` is the "named connection point" abstraction. Channels route to adapter endpoints (not directly to endpoint configurations), because the same logical endpoint may have multiple physical configurations (e.g. different URLs for test vs. production). The endpoint abstraction also allows the CMIS domain (`cmisrepository`) to associate a document repository with a specific adapter endpoint.

---

### endpointconfiguration

**Rows:** 491 | **Role:** Physical connection details (largest config table)

The most detailed configuration table — stores all physical connection parameters for an adapter endpoint. With 491 rows for only 14 adapter endpoints, each endpoint has many configuration variants (different environments, protocol modes, etc.).

CGS implements a *multi-protocol endpoint* pattern: all protocol-specific settings share a single table, with nullable columns used selectively based on the protocol.

**Key columns by protocol group:**

*General:*
| Column | Meaning |
|---|---|
| `endpointtype` | Protocol/mode type (e.g. HTTP, MQ, FILE, EBMS) |
| `configuration` | Configuration profile name |
| `adapterendpoint_id` | Which logical endpoint this configuration belongs to |

*HTTP / Web Service:*
| Column | Meaning |
|---|---|
| `url` | The target endpoint URL |
| `username` / `password` | HTTP Basic Auth credentials |
| `soapversion` | SOAP 1.1 or 1.2 |
| `enablewsaddressing` | Whether WS-Addressing headers are included |
| `enablewssecurity` | Whether WS-Security signing/encryption is applied |
| `enablemtom` | Whether MTOM (MIME attachment optimization) is enabled |
| `certificate_id` | TLS client certificate for mutual authentication |
| `signingcertificate_id` | Certificate used to sign SOAP messages |

*MQ (IBM MQ / JMS):*
| Column | Meaning |
|---|---|
| `manager` | MQ queue manager name |
| `channel` | MQ channel name |
| `replyqueue` | Queue to receive responses on |
| `sessionqueue` | Session queue for correlation |

*ebMS (Digikoppeling):*
| Column | Meaning |
|---|---|
| `ebmscpa_id` | CPA to use for this ebMS endpoint |
| `ebmsprocessspec` | Process specification identifier |
| `ebmsrequestaction` / `ebmsrequestservice` | ebMS message addressing |
| `ebmspartyid` / `ebmsotherpartyid` | Sender and receiver party IDs |

*File Transfer:*
| Column | Meaning |
|---|---|
| `fileprotocol` | FTP, SFTP, or local file system |
| `hostname` | Remote host for file transfer |

---

### adaptersetting

**Rows:** 0 | **Role:** Key-value settings for endpoint configurations

Provides additional named configuration parameters for an `endpointconfiguration`, as a flexible key-value extension mechanism. Currently **empty**.

**Key columns:**
| Column | Meaning |
|---|---|
| `endpointconfiguration_id` | The endpoint configuration these settings apply to |
| `settingtype` | Data type of the value (STRING, INTEGER, BOOLEAN, etc.) |
| `settingvalue` | The actual value |
| `defaultvalue` | Default if no value is set |
| `domainvalues` | Pipe-separated list of allowed values (for enum-like settings) |
| `required` | Whether this setting must have a value |

---

## Domain 4 — Message / Transformation

This domain defines the **message format contracts** and the **XSLT transformation pipeline** that bridges between different formats.

---

### messagedefinition

**Rows:** 32 | **Role:** Message type catalog (root reference table)

Defines the message types that CGS understands. Each row represents a distinct message format identified by a combination of `messagekey`, `namespace`, and optionally `soapaction`. These identifiers are used to match incoming SOAP requests to the correct service routing.

**Key columns:**
| Column | Meaning |
|---|---|
| `messagekey` | The primary message type identifier — typically a SOAP operation name or message type (e.g. "GeefLeerlingReq", "WozWaardeRequest") |
| `namespace` | The XML namespace of the message, used together with `messagekey` for unambiguous identification |
| `soapaction` | The SOAPAction HTTP header value, used for WS routing |
| `configurationname` | Optional named configuration group this message belongs to |
| `filterxpath` | XPath expression used to extract a routing discriminator from the message content |
| `validationactive` | Whether incoming messages of this type should be validated against `messagevalidation` rules |

**Relationship:** Referenced extensively throughout the schema — by `servicecomponentrelation` (3×: request, response, fault contracts), by `channeldefinition` (filter matching), by `transformationdefinition` (source and target formats), and by `elementdefinition` (element tree within a message).

---

### elementdefinition

**Rows:** 0 | **Role:** Hierarchical XML element tree within a message definition

Defines the schema elements within a `messagedefinition` as a tree structure. Each row is one XML element: it belongs to a message definition and optionally has a parent element (enabling nested XML hierarchies). Used by the Validation domain to specify which elements to validate. Currently **empty**.

**Key columns:**
| Column | Meaning |
|---|---|
| `messagedefinition_id` | The message format this element belongs to |
| `parent_id` | Self-referencing FK to `elementdefinition` — the parent XML element in the hierarchy (null for root elements) |

**Self-reference:** The `parent_id → id` FK creates an arbitrary-depth XML element tree. Root elements have `parent_id = null`.

---

### transformationdefinition

**Rows:** 5 | **Role:** XSLT transformation specification

Defines a named XSLT transformation between two message formats. Used by `channeldefinition` to transform requests, responses, and faults on the fly during routing.

**Key columns:**
| Column | Meaning |
|---|---|
| `messagedefinitionoriginal_id` | The source message format (what comes in) |
| `messagedefinitiontarget_id` | The target message format (what goes out after transformation) |
| `content_id` | FK to `xsltcontent` — the actual XSLT stylesheet to apply |

**Relationship meaning:** A transformation definition acts as a typed bridge: "when you have a message of format X, apply this XSLT to produce a message of format Y." Channels reference up to three transformations (request, response, fault), enabling bidirectional format bridging between consumer and provider.

---

### xsltcontent

**Rows:** 1 | **Role:** XSLT stylesheet storage

Stores the raw XSLT stylesheet content referenced by `transformationdefinition`. Separating content from the transformation definition allows the same stylesheet to be reused by multiple transformation definitions (though in practice there is currently only 1 stylesheet).

The single row represents the one active XSLT transformation in this environment.

---

## Domain 5 — Validation

This domain defines the **message validation rules** — validators, their actions, and how they are bound to message elements. The entire domain is currently **empty** (all 6 tables have 0 rows), meaning no validation rules are active.

The design follows a layered pattern:
```
validator → validatoraction → validatoractioncfg
    ↕               ↕                ↕
messagevalidation → messagevalidationaction → messagevalidationactioncfg
    ↑
elementdefinition (from Message domain)
```

---

### validator

**Rows:** 0 | **Role:** Validator type registry

Defines a validator — a Java class that can validate XML elements. The UNIQUE constraint on `classname` ensures each Java validator class is registered once.

**Key columns:** `classname` (UNIQUE) — the fully qualified Java class implementing the validation logic.

---

### validatoraction

**Rows:** 0 | **Role:** Named validation actions on a validator

A validator can expose multiple named actions (methods). Each row represents one callable method on a `validator`. The UNIQUE constraint on `(validator_id, methodname)` ensures each validator-method pair is unique.

**Key columns:**
| Column | Meaning |
|---|---|
| `validator_id` | The validator this action belongs to |
| `methodname` | Java method name to invoke for this validation action |

---

### validatoractioncfg

**Rows:** 0 | **Role:** Configuration parameters for validator actions

Key-value configuration parameters that are passed to a `validatoraction` when it is invoked. Allows the same validator action to be parameterized differently in different contexts.

**Key columns:** `validatoraction_id`, `name`, `value` — which action, what parameter, what value.

---

### messagevalidation

**Rows:** 0 | **Role:** Binds a validator to a specific message element

Associates a `validator` with a specific `elementdefinition` in a message format. This says "when validating messages of this format, validate *this element* using *this validator*."

The UNIQUE constraints ensure each element-validator combination appears only once, and ordering is controlled via a `validationorder` column.

**Key columns:**
| Column | Meaning |
|---|---|
| `elementdefinition_id` | Which XML element in which message format to validate |
| `validator_id` | Which validator to apply |

---

### messagevalidationaction

**Rows:** 0 | **Role:** Junction table — links a message validation to a validator action (many-to-many)

A `messagevalidation` can trigger multiple `validatoraction`s. This table bridges them. The UNIQUE constraint on `(messagevalidation_id, validatoraction_id)` prevents duplicate wiring.

---

### messagevalidationactioncfg

**Rows:** 0 | **Role:** Junction table with configuration — links validation actions to their configurations

Provides the specific configuration values (`validatoractioncfg`) to use when a `messagevalidationaction` is executed. This is the innermost configuration layer: "for *this* validation action in *this* message validation context, use *these* configuration parameters."

---

## Domain 6 — CMIS

CMIS (Content Management Interoperability Services) is an OASIS standard for document management system integration. This domain configures CGS's integration with CMIS-compliant document repositories (e.g. Alfresco, SharePoint).

The data flow is: **consumer application properties ↔ property mapping ↔ CMIS provider properties**, scoped to a specific repository.

---

### cmisproviderconfiguration

**Rows:** 2 | **Role:** CMIS provider type definition

Defines the type/vendor of a CMIS provider (e.g. "Alfresco Community", "SharePoint Online"). Think of this as the "driver" for a CMIS server vendor.

**Key columns:**
| Column | Meaning |
|---|---|
| `vendortype` | The CMIS vendor identifier (e.g. ALFRESCO, SHAREPOINT) |
| `name` / `description` | Human-readable provider type name and description |

---

### cmisproviderproperty

**Rows:** 28 | **Role:** Metadata properties available on the CMIS provider side

Defines the metadata fields (document properties) that the CMIS provider exposes. Examples: `cmis:objectId`, `cmis:name`, `cmis:creationDate`, or vendor-specific properties.

**Key columns:**
| Column | Meaning |
|---|---|
| `cmisproviderconfiguration_id` | Which vendor type these properties belong to |
| `datatype` | Property data type (STRING, INTEGER, DATE, BOOLEAN) |
| `levelfield` | Whether this is a document-level or folder-level property |
| `definition` | Whether this is a standard CMIS property or vendor-specific |
| `usage` | How this property is used (READ, WRITE, READWRITE) |

---

### cmisconsumerproperty

**Rows:** 23 | **Role:** Metadata properties used by CGS consumer applications

Defines the metadata fields from the consumer application's perspective — the field names and types that the requesting application understands. These may differ in name and structure from the provider's properties.

**Key columns:**
| Column | Meaning |
|---|---|
| `datatype` | Property data type on the consumer side |
| `levelfield` | Document-level or folder-level property |

**Relationship:** `cmisconsumerproperty` has no outgoing FKs — it is a root reference table. The mapping to provider properties happens in `cmispropertymapping`.

---

### cmisrepository

**Rows:** 2 | **Role:** A specific CMIS repository instance

Represents a deployed CMIS repository (e.g. "Alfresco repo for ROSWOZ document archive"). Combines a provider configuration with an adapter endpoint to describe a live document management system.

**Key columns:**
| Column | Meaning |
|---|---|
| `repositoryid` | The external repository identifier as returned by the CMIS server |
| `cmisproviderconfiguration_id` | Which CMIS vendor type this repository is |
| `adapterendpoint_id` | Which CGS adapter endpoint handles communication with this repository |
| `vendorname` / `productname` / `productversion` | Repository software metadata |
| `cmiscompliant` | Whether this repository fully conforms to the CMIS standard |

---

### cmispropertymapping

**Rows:** 14 | **Role:** Property translation bridge between consumer and provider (junction table)

This is the core mapping table: for a specific repository, it maps a consumer-side property to the corresponding provider-side properties (one for reading — `_in`, one for writing — `_out`).

The separation of `in` and `out` properties allows asymmetric mapping: reading a document may use a different provider property than writing it.

**Key columns:**
| Column | Meaning |
|---|---|
| `cmisrepository_id` | The repository this mapping applies to (mapping is per-repo) |
| `cmisconsumerproperty_id` | The consumer-side metadata field being mapped |
| `cmisproviderproperty_in_id` | Provider property to read from when fetching metadata |
| `cmisproviderproperty_out_id` | Provider property to write to when storing metadata |

**Multiple UNIQUE constraints** enforce that each consumer property is mapped at most once per repository for each direction.

---

## Domain 7 — ebMS Messaging

ebMS (Electronic Business Messaging Service) is the messaging protocol used by the Dutch government's Digikoppeling standard for reliable, secure inter-system communication. This domain is currently **entirely empty** (0 rows in all tables), indicating ebMS is not active in this environment.

---

### ebmscpa

**Rows:** 0 | **Role:** Collaboration Protocol Agreement

A CPA is an XML document that describes the technical agreement between two parties for ebMS message exchange — defining message formats, security requirements, reliability settings, and endpoint addresses.

**Key columns:**
| Column | Meaning |
|---|---|
| `cpa_id` | External CPA identifier string (e.g. "urn:nl.gov.overheid.cpa:1234") |
| `cpa` | The full CPA XML document stored as text |
| `alias_name` | Short name for the CPA used in configurations |
| `enddate` | CPA expiry date — after this date the CPA is no longer valid |
| `certificate_id` | The signing certificate used for this CPA's digital signatures |

---

### ebmsmessage

**Rows:** 0 | **Role:** ebMS message envelope storage

Stores the complete ebMS message envelope for messages processed through the Digikoppeling gateway. Each row is one ebMS message with its full header set and payload.

**Key columns:**
| Column | Meaning |
|---|---|
| `cpa_id` | Which CPA governs this message exchange |
| `conversation_id` | Unique conversation identifier linking related messages |
| `message_id` | The ebMS MessageId header value (globally unique) |
| `ref_to_message_id` | If this is a response, the MessageId of the request being replied to |
| `from_role` / `to_role` | Sender and receiver party roles as defined in the CPA |
| `service` / `action` | ebMS service and action identifiers for routing |
| `status` | Message processing status code |
| `signature` | XML digital signature for message integrity |
| `message_header` | Full SOAP envelope header |
| `cgs_id` | Internal CGS reference linking this ebMS message to a CGS service request |

---

### ebmsattachment

**Rows:** 0 | **Role:** MIME attachments on ebMS messages

Stores binary file attachments included in an ebMS message (e.g. PDF documents, XML files). Uses the MIME multi-part attachment mechanism.

**Key columns:** `ebmsmessage_id`, `content_id` (MIME Content-ID header), `content_type` (MIME type), `content` (binary bytea).

---

### ebmssendevent

**Rows:** 0 | **Role:** Reliable messaging send event log

Tracks when an ebMS message was sent, supporting the reliable messaging retry mechanism. The UNIQUE constraint on `ebmsmessage_id` ensures only one send event record per message.

**Key columns:** `ebmsmessage_id`, `se_time` (send timestamp, defaults to CURRENT_TIMESTAMP).

---

### ebmsmapping

**Rows:** 0 | **Role:** ebMS message routing/mapping rules

Stores routing or transformation mapping rules for ebMS message processing. Isolated table — no FK connections to other ebMS or CGS tables. The `mapping` column stores the mapping definition (likely XML or expression-based).

---

## Domain 8 — Logging

This domain provides the **operational audit trail** of all service requests processed by CGS. With 258 total rows across 4 active tables, it is the main evidence of CGS activity in this environment.

The hierarchy is:
```
logservicerequest (1 per service call)
    └── logroute (1 per outbound route)
            └── logaction (N per route, granular steps)

logmessage (message payloads — referenced by request and route)
logattachment (binary attachments on messages)
```

---

### logmessage

**Rows:** 66 | **Role:** Raw message payload storage (root reference table)

Stores the actual XML/SOAP message content. This is the raw payload — not the routing metadata. Referenced by multiple other logging tables for different message roles (request, response, transformed variants).

**Key columns:**
| Column | Meaning |
|---|---|
| `messagekey` | The message type identifier (same key as in `messagedefinition`) |
| `namespace` | XML namespace of the message |
| `configurationname` | Which CGS configuration produced this message |
| `message` | The full message content as text (XML/SOAP payload) |

**Relationship meaning:** `logmessage` is a root table with no outgoing FKs — messages are stored once and referenced multiple times. A `logservicerequest` references the original request and response messages. A `logroute` references up to 3 message versions: the outgoing request (possibly transformed), the incoming response (possibly transformed), and the raw response. This separation allows comparing pre- and post-transformation payloads for debugging.

---

### logservicerequest

**Rows:** 22 | **Role:** Top-level audit entry per service invocation

The entry point for all logging. One row per service call received by CGS.

**Key columns:**
| Column | Meaning |
|---|---|
| `servicename` | Name of the CGS service called |
| `requesttimestamp` / `responsetimestamp` | When the request arrived and when the response was sent |
| `status` | Processing outcome |
| `erroroccurred` | Quick flag indicating whether any error happened |
| `consumer` | Identity of the calling application |
| `provider` | Identity of the backend system that ultimately responded |
| `incomingcomponenttype` / `incomingcomponent` | Which CGS component received this request (e.g. AXIS, CXF) |
| `servicehandling` | `SYN` or `ASYN` — whether the caller waited for a response |
| `consumerorganisation` / `providerorganisation` | Organisation-level identifiers for filtering |
| `ebmsmsgid` / `ebmsxrefmsgid` | ebMS message IDs if this was a Digikoppeling call |
| `request_id` / `response_id` | FKs to `logmessage` for the actual request and response payloads |
| `parentservicerequest_id` | Self-referencing FK — if this service call was triggered by another service call (orchestration or chained calls), this points to the parent request |

**Self-reference:** The `parentservicerequest_id → id` FK creates a tree of nested service calls, enabling tracing of orchestrated multi-step service flows.

---

### logroute

**Rows:** 22 | **Role:** Per-route log entry within a service request

A service request may be routed to multiple backends. Each outbound route produces one `logroute` row. The 22 routes matching the 22 service requests suggests each request took exactly one route in this environment.

**Key columns:**
| Column | Meaning |
|---|---|
| `logservicerequest_id` | The parent service request this route belongs to |
| `requesttimestamp` / `responsetimestamp` | Timing for this specific route's outbound call |
| `provider` | The backend system this route was sent to |
| `outgoingcomponenttype` / `outgoingcomponent` | Which CGS adapter/component handled this outbound call |
| `adapterendpointname` | The name of the adapter endpoint used |
| `responseisfault` | Whether the backend returned a SOAP fault |
| `transformedrequest_id` | FK to `logmessage` — the request payload *after* any transformation |
| `response_id` | FK to `logmessage` — the raw response from the backend |
| `transformedresponse_id` | FK to `logmessage` — the response *after* any transformation |
| `requesttransformationname` / `responsetransformationname` | Names of the transformations applied |

**Relationship meaning:** The three `logmessage` FKs on `logroute` enable debugging of the transformation pipeline: you can compare the original request (from `logservicerequest.request_id`) with the transformed request sent to the backend (`transformedrequest_id`), and the raw backend response (`response_id`) with the transformed response returned to the consumer (`transformedresponse_id`).

---

### logaction

**Rows:** 148 | **Role:** Granular action log — individual processing steps

The most granular logging level. Each row is one named step in the processing of a service request or route. With 148 actions across 22 service requests, each request generates approximately 6–7 action entries on average.

**Key columns:**
| Column | Meaning |
|---|---|
| `logservicerequest_id` | Parent service request (nullable — some actions are at request level) |
| `logroute_id` | Parent route (nullable — some actions are at request level, before routing) |
| `name` | Action name (e.g. "ValidateRequest", "TransformRequest", "SendToProvider") |
| `result` | Outcome: `SUCCESS` or `FAILURE` |
| `duration` | How long this action took in milliseconds |
| `resultdescription` | Short outcome description |
| `resultdetails` | Full details — may contain error stack traces or debug information |
| `actiontimestamp` | When this action occurred |

---

### logattachment

**Rows:** 0 | **Role:** Binary attachments on logged messages

Stores binary file attachments that were part of a logged message (e.g. PDF files in MTOM messages). Currently **empty**.

**Key columns:** `logmessage_id` — the message this attachment belongs to.

---

## Domain 9 — System & Audit

System tables and the Hibernate Envers audit trail.

---

### cgssetting

**Rows:** 0 | **Role:** Global CGS platform settings

Key-value store for platform-wide configuration parameters that affect CGS behavior globally (rather than per-service or per-endpoint). Same structure as `adaptersetting` — name, type, value, default, domain values. Currently **empty**.

**Relationship:** No FKs — standalone global configuration table.

---

### revinfo

**Rows:** 106 | **Role:** Hibernate Envers revision metadata hub

Central table for the Hibernate Envers audit trail. Every time a configuration entity is created, updated, or deleted, Envers records a revision here and creates a snapshot row in the corresponding `_aud` table.

**Key columns:**
| Column | Meaning |
|---|---|
| `id` | Revision number — auto-incrementing |
| `timestamp` | Unix epoch milliseconds when the change occurred |
| `username` | Who made the change (application user or system account) |

With 106 revisions recorded, the CGS configuration has been modified 106 times since auditing was enabled.

**Relationship:** Referenced by all 6 `_aud` tables via their `rev` FK column.

---

### Audit tables (_aud)

CGS uses **Hibernate Envers** for configuration change auditing. For selected entities, Envers automatically creates a snapshot (`_aud`) row for every revision.

The pattern is consistent across all audit tables:
- **Composite PK:** `(id, rev)` — the entity ID + revision number uniquely identifies a historical snapshot
- **FK to revinfo:** `rev → revinfo.id` — links to the revision metadata
- **Same columns as the main table** — a full copy of the row at that revision
- **Additional `revtype` column** — `0` = INSERT, `1` = UPDATE, `2` = DELETE

| Audit Table | Audited Entity | Rows |
|---|---|---|
| `adapterendpoint_aud` | `adapterendpoint` | 14 (14 endpoint snapshots) |
| `adaptersetting_aud` | `adaptersetting` | 3 |
| `application_aud` | `application` | 7 (7 application snapshots) |
| `channeldefinition_aud` | `channeldefinition` | 25 (14 channels × multiple revisions) |
| `endpointconfiguration_aud` | `endpointconfiguration` | 57 (most frequently changed) |
| `orchestrationsetting_aud` | `orchestrationsetting` | 0 |

**Why only some tables are audited:** Envers auditing is enabled selectively. The audited tables (`adapterendpoint`, `adaptersetting`, `application`, `channeldefinition`, `endpointconfiguration`, `orchestrationsetting`) represent the "live" configuration that changes during operations. High-volume tables like `logservicerequest` and `serviceusage` are not audited because they change continuously.

The **57 revisions** on `endpointconfiguration_aud` reflect that endpoint configurations (URLs, credentials, connection settings) are the most frequently updated configuration in CGS.

---

## Cross-Cutting Patterns

### Universal columns on every table
- `id` (numeric) — surrogate primary key, no business meaning
- `changecounter` (numeric, default 1) — optimistic locking version counter, incremented on every update to detect concurrent modifications

### The `factorysetting` flag
Most configuration tables include `factorysetting boolean NOT NULL DEFAULT false`. This flag distinguishes:
- `true` — factory/platform default records shipped with the CGS installation
- `false` — customer-created or customer-modified configuration

This separation allows upgrades to refresh factory settings without overwriting customer configuration.

### Self-referencing tables
Three tables reference themselves, creating hierarchical structures:
| Table | Self-ref column | Purpose |
|---|---|---|
| `application` | `application_id` | Parent application grouping |
| `elementdefinition` | `parent_id` | XML element tree (root elements have null parent) |
| `logservicerequest` | `parentservicerequest_id` | Nested/chained service call tracing |

### Hub tables — most referenced
| Table | Referenced by | Why central |
|---|---|---|
| `application` | serviceusage, adapterendpoint, channeldefinition, certificate, applicationopeningperiod, application (self) | Every connected system is an application |
| `servicedefinition` | serviceusage, servicecomponentrelation, channeldefinition | Every routable capability is a service |
| `messagedefinition` | servicecomponentrelation (×3), channeldefinition, transformationdefinition (×2), elementdefinition | Every message format is a message definition |
| `adapterendpoint` | channeldefinition, endpointconfiguration, cmisrepository | Every connection point is an endpoint |
| `logmessage` | logservicerequest (×2), logroute (×3), logattachment | All message payloads flow through logmessage |
| `revinfo` | All 6 `_aud` tables | Every audit revision references revinfo |

### Domain isolation
The CMIS, ebMS, and Validation domains are **functionally isolated** from the core service bus domain — they do not have FK relationships into the Service Bus Core tables. They connect only through the Application and Adapter/Endpoint domains (CMIS via `adapterendpoint`; ebMS via `certificate`). This means these domains can be added or removed without affecting core service routing.
