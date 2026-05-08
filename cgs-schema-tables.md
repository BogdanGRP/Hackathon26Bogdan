# CGS Schema — Detailed Table Catalog

> Schema: `igp_ontwikkel_cgs_owner` | Database: `igp_ontwikkel` | Generated: 2026-05-08

---

## Table of Contents

1. [adapterdefinition](#adapterdefinition)
2. [adapterendpoint](#adapterendpoint)
3. [adaptersetting](#adaptersetting)
4. [application](#application)
5. [applicationopeningperiod](#applicationopeningperiod)
6. [certificate](#certificate)
7. [cgssetting](#cgssetting)
8. [channeldefinition](#channeldefinition)
9. [cmisconsumerproperty](#cmisconsumerproperty)
10. [cmispropertymapping](#cmispropertymapping)
11. [cmisproviderconfiguration](#cmisproviderconfiguration)
12. [cmisproviderproperty](#cmisproviderproperty)
13. [cmisrepository](#cmisrepository)
14. [ebmsattachment](#ebmsattachment)
15. [ebmscpa](#ebmscpa)
16. [ebmsmapping](#ebmsmapping)
17. [ebmsmessage](#ebmsmessage)
18. [ebmssendevent](#ebmssendevent)
19. [elementdefinition](#elementdefinition)
20. [endpointconfiguration](#endpointconfiguration)
21. [logaction](#logaction)
22. [logattachment](#logattachment)
23. [logmessage](#logmessage)
24. [logroute](#logroute)
25. [logservicerequest](#logservicerequest)
26. [messagedefinition](#messagedefinition)
27. [messagevalidation](#messagevalidation)
28. [messagevalidationaction](#messagevalidationaction)
29. [messagevalidationactioncfg](#messagevalidationactioncfg)
30. [orchestrationdefinition](#orchestrationdefinition)
31. [orchestrationsetting](#orchestrationsetting)
32. [revinfo](#revinfo)
33. [servicecomponentrelation](#servicecomponentrelation)
34. [servicedefinition](#servicedefinition)
35. [serviceusage](#serviceusage)
36. [transformationdefinition](#transformationdefinition)
37. [validator](#validator)
38. [validatoraction](#validatoraction)
39. [validatoractioncfg](#validatoractioncfg)
40. [xsltcontent](#xsltcontent)
41. [Audit tables (_aud)](#audit-tables)

---

## adapterdefinition

**Domain:** Adapter Layer | **Rows:** 7 | **PK:** `id`

Defines adapter types — the software components that handle inbound/outbound communication.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | Optimistic lock |
| name | varchar(50) | NO | — | e.g. "ILOGBOEKCLIQADAPTER", "CMISBROWSERBASEDADAPTER" |
| description | varchar(250) | NO | — | Dutch description of adapter purpose |
| adaptertype | varchar(10) | NO | — | HTTP, JAVA, WEBSERVICE |
| direction | varchar(10) | NO | — | OUTGOING, INCOMING |
| implementation | varchar(250) | NO | — | Fully qualified Java class name |
| factorysetting | boolean | NO | false | Factory default flag |

**FK:** None (root entity)
**Referenced by:** adapterendpoint, servicecomponentrelation

---

## adapterendpoint

**Domain:** Adapter Layer | **Rows:** 14 | **PK:** `id`

Named instances of adapters, bound to a specific application alias.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| adapterdefinition_id | numeric | NO | — | FK → adapterdefinition |
| name | varchar(30) | NO | — | |
| description | varchar(250) | NO | — | |
| applicationalias_id | numeric | NO | — | FK → application |
| factorysetting | boolean | NO | false | |

**FK:** adapterdefinition, application
**Referenced by:** channeldefinition, endpointconfiguration, cmisrepository

---

## adaptersetting

**Domain:** Adapter Layer | **Rows:** 0 | **PK:** `id`

Key-value configuration settings per endpoint configuration.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| endpointconfiguration_id | numeric | NO | — | FK → endpointconfiguration |
| name | varchar(60) | NO | — | |
| description | varchar(255) | NO | — | |
| settingtype | varchar(15) | NO | — | |
| settingvalue | text | YES | — | |
| defaultvalue | text | YES | — | |
| maxlength | numeric | YES | — | |
| required | boolean | NO | false | |
| domainvalues | text | YES | — | Allowed values |
| factorysetting | boolean | NO | false | |

**FK:** endpointconfiguration

---

## application

**Domain:** Application Layer | **Rows:** 7 | **PK:** `id`

External systems integrated by CGS. Uses Hibernate single-table inheritance (`dtype`).

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| dtype | varchar(10) | NO | — | Discriminator: currently all "Appl" |
| name | varchar(50) | NO | — | e.g. ROSWOZ, TERCERA, GEODATA |
| namesearchfield | varchar(60) | NO | — | Normalized name for search |
| description | varchar(100) | YES | — | |
| application_id | numeric | YES | — | FK → application (self: parent) |
| complementmessage | boolean | NO | false | |
| organisationconfigurationname | varchar(100) | YES | — | |
| factorysetting | boolean | NO | false | |

**FK:** application (self-referencing)
**Referenced by:** serviceusage, adapterendpoint, channeldefinition, certificate, applicationopeningperiod

---

## applicationopeningperiod

**Domain:** Application Layer | **Rows:** 0 | **PK:** `id`

Availability windows per weekday for applications.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| application_id | numeric | NO | — | FK → application |
| starttime | time | YES | — | |
| endtime | time | YES | — | |
| monday | boolean | NO | false | |
| tuesday | boolean | NO | false | |
| wednesday | boolean | NO | false | |
| thursday | boolean | NO | false | |
| friday | boolean | NO | false | |
| saturday | boolean | NO | false | |
| sunday | boolean | NO | false | |

**FK:** application

---

## certificate

**Domain:** Application Layer | **Rows:** 0 | **PK:** `id`

TLS and signing certificates for applications.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| application_id | numeric | YES | — | FK → application |
| alias | varchar(100) | NO | — | |
| canonicalname | varchar(100) | NO | — | CN from certificate |
| organization | varchar(100) | YES | — | |
| organizationunit | varchar(100) | YES | — | |
| stateprovince | varchar(100) | YES | — | |
| locality | varchar(100) | YES | — | |
| country | varchar(100) | YES | — | |
| serialnumber | varchar(100) | NO | — | |
| issuer | varchar(200) | NO | — | |
| notbefore | timestamp | NO | — | Validity start |
| notafter | timestamp | NO | — | Validity end |
| certificatetype | varchar(10) | NO | — | |

**FK:** application
**Referenced by:** endpointconfiguration (×2), ebmscpa

---

## cgssetting

**Domain:** System | **Rows:** 0 | **PK:** `id`

Global CGS platform settings.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| name | varchar(60) | NO | — | |
| description | varchar(255) | NO | — | |
| settingtype | varchar(15) | NO | — | |
| settingvalue | text | YES | — | |
| defaultvalue | text | YES | — | |
| maxlength | numeric | YES | — | |
| required | boolean | NO | false | |
| domainvalues | text | YES | — | |
| factorysetting | boolean | NO | false | |

**FK:** None (standalone)

---

## channeldefinition

**Domain:** Core Service | **Rows:** 14 | **PK:** `id`

Routing rules that connect services to adapter endpoints with optional filtering and transformation.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| description | varchar(100) | NO | — | |
| servicedefinition_id | numeric | NO | — | FK → servicedefinition |
| adapterendpoint_id | numeric | YES | — | FK → adapterendpoint |
| orchestrationdefinition_id | numeric | YES | — | FK → orchestrationdefinition |
| filterprovidingapplication_id | numeric | NO | — | FK → application |
| filtermessagedefinition_id | numeric | YES | — | FK → messagedefinition |
| filterxpath | varchar(4000) | YES | — | XPath filter expression |
| active | boolean | NO | false | |
| filterconsumerorganisation | varchar(254) | YES | — | |
| filterproviderorganisation | varchar(254) | YES | — | |
| filterconsumingapplication | varchar(50) | YES | — | |
| requesttransformation_id | numeric | YES | — | FK → transformationdefinition |
| responsetransformation_id | numeric | YES | — | FK → transformationdefinition |
| faulttransformation_id | numeric | YES | — | FK → transformationdefinition |
| factorysetting | boolean | NO | false | |

**FK:** servicedefinition, adapterendpoint, orchestrationdefinition, application, messagedefinition, transformationdefinition (×3)

---

## cmisconsumerproperty

**Domain:** CMIS | **Rows:** 23 | **PK:** `id`

Consumer-side CMIS metadata properties.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| name | varchar(50) | NO | — | |
| description | varchar(1000) | NO | — | |
| datatype | varchar(15) | NO | — | |
| levelfield | varchar(15) | NO | — | |
| factorysetting | boolean | NO | false | |

**FK:** None
**Referenced by:** cmispropertymapping

---

## cmispropertymapping

**Domain:** CMIS | **Rows:** 14 | **PK:** `id`

Maps consumer properties to provider in/out properties within a repository.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| cmisrepository_id | numeric | NO | — | FK → cmisrepository |
| cmisconsumerproperty_id | numeric | NO | — | FK → cmisconsumerproperty |
| cmisproviderproperty_in_id | numeric | NO | — | FK → cmisproviderproperty |
| cmisproviderproperty_out_id | numeric | NO | — | FK → cmisproviderproperty |
| factorysetting | boolean | NO | false | |

**FK:** cmisrepository, cmisconsumerproperty, cmisproviderproperty (×2)

---

## cmisproviderconfiguration

**Domain:** CMIS | **Rows:** 2 | **PK:** `id`

CMIS provider type definitions.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| name | varchar(50) | NO | — | |
| description | varchar(1000) | NO | — | |
| vendortype | varchar(15) | NO | — | |
| factorysetting | boolean | NO | false | |

**FK:** None
**Referenced by:** cmisproviderproperty, cmisrepository

---

## cmisproviderproperty

**Domain:** CMIS | **Rows:** 28 | **PK:** `id`

Provider-side CMIS metadata properties.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| cmisproviderconfiguration_id | numeric | NO | — | FK → cmisproviderconfiguration |
| name | varchar(50) | NO | — | |
| description | varchar(1000) | NO | — | |
| datatype | varchar(15) | NO | — | |
| levelfield | varchar(15) | NO | — | |
| definition | varchar(15) | NO | — | |
| usage | varchar(15) | NO | — | |
| factorysetting | boolean | NO | false | |

**FK:** cmisproviderconfiguration
**Referenced by:** cmispropertymapping (×2)

---

## cmisrepository

**Domain:** CMIS | **Rows:** 2 | **PK:** `id`

CMIS repository instances.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| repositoryid | varchar(1000) | NO | — | External repo ID |
| name | varchar(1000) | NO | — | |
| description | varchar(1000) | NO | — | |
| vendorname | varchar(1000) | NO | — | |
| productname | varchar(1000) | NO | — | |
| productversion | varchar(1000) | NO | — | |
| cmiscompliant | boolean | NO | false | |
| cmisproviderconfiguration_id | numeric | NO | — | FK → cmisproviderconfiguration |
| adapterendpoint_id | numeric | NO | — | FK → adapterendpoint |
| factorysetting | boolean | NO | false | |

**FK:** cmisproviderconfiguration, adapterendpoint
**Referenced by:** cmispropertymapping

---

## ebmsattachment

**Domain:** ebMS | **Rows:** 0 | **PK:** `id`

MIME attachments on ebMS messages.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| ebmsmessage_id | numeric | NO | — | FK → ebmsmessage |
| name | varchar(256) | YES | — | |
| content_id | varchar(256) | NO | — | MIME content ID |
| content_type | varchar(255) | NO | — | MIME type |
| content | bytea | NO | — | Binary content |

**FK:** ebmsmessage

---

## ebmscpa

**Domain:** ebMS | **Rows:** 0 | **PK:** `id`

Collaboration Protocol Agreements for Digikoppeling messaging.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| cpa_id | varchar(200) | NO | — | External CPA identifier |
| alias_name | varchar(15) | YES | — | |
| cpa | text | NO | — | Full CPA XML document |
| enddate | timestamp | YES | — | |
| certificate_id | numeric | YES | — | FK → certificate |
| factorysetting | boolean | NO | false | |

**FK:** certificate
**Referenced by:** ebmsmessage

---

## ebmsmapping

**Domain:** ebMS | **Rows:** 0 | **PK:** `id`

ebMS routing/mapping rules.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| name | varchar(255) | NO | — | |
| description | varchar(255) | NO | — | |
| mapping | text | NO | — | Mapping definition |
| deactivated | boolean | NO | false | |
| factorysetting | boolean | NO | false | |

**FK:** None (standalone)

---

## ebmsmessage

**Domain:** ebMS | **Rows:** 0 | **PK:** `id`

ebMS message envelopes.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| time_stamp | timestamp | NO | — | |
| cpa_id | numeric | NO | — | FK → ebmscpa |
| conversation_id | varchar(256) | NO | — | |
| sequence_nr | numeric | YES | — | |
| message_id | varchar(256) | NO | — | |
| ref_to_message_id | varchar(256) | YES | — | |
| time_to_live | timestamp | YES | — | |
| from_role | varchar(256) | YES | — | |
| to_role | varchar(256) | YES | — | |
| service_type | varchar(256) | YES | — | |
| service | varchar(256) | NO | — | |
| action | varchar(256) | NO | — | |
| namespace | varchar(256) | YES | — | |
| signature | text | YES | — | XML signature |
| message_header | text | NO | — | SOAP header |
| sync_reply | text | YES | — | |
| message_order | text | YES | — | |
| ack_requested | text | YES | — | |
| content | text | YES | — | Message body |
| status | numeric | NO | — | |
| status_time | timestamp | YES | — | |
| cgs_id | numeric | YES | — | |

**FK:** ebmscpa
**Referenced by:** ebmsattachment, ebmssendevent

---

## ebmssendevent

**Domain:** ebMS | **Rows:** 0 | **PK:** `id`

Send event log for reliable messaging.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| ebmsmessage_id | numeric | NO | — | FK → ebmsmessage |
| cpa_id | numeric | YES | — | |
| se_time | timestamp | NO | CURRENT_TIMESTAMP | |

**FK:** ebmsmessage

---

## elementdefinition

**Domain:** Message Layer | **Rows:** 0 | **PK:** `id`

Hierarchical XML elements within message definitions.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| messagedefinition_id | numeric | NO | — | FK → messagedefinition |
| parent_id | numeric | YES | — | FK → elementdefinition (self) |
| *(remaining columns from schema)* | | | | |

**FK:** messagedefinition, elementdefinition (self)
**Referenced by:** messagevalidation

---

## endpointconfiguration

**Domain:** Adapter Layer | **Rows:** 491 | **PK:** `id`

Physical connection configuration — multi-protocol in a single table.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| endpointtype | varchar | NO | — | |
| adapterendpoint_id | numeric | NO | — | FK → adapterendpoint |
| configuration | varchar | NO | — | |
| certificate_id | numeric | YES | — | FK → certificate (TLS) |
| url | varchar | YES | — | HTTP/WS endpoint URL |
| username | varchar | YES | — | Basic auth user |
| password | varchar | YES | — | Basic auth password |
| soapversion | varchar | YES | — | |
| enablewsaddressing | boolean | NO | — | |
| enablewssecurity | boolean | NO | — | |
| enablemtom | boolean | NO | — | |
| enablechunked | boolean | NO | — | |
| enableproxy | boolean | NO | — | |
| signingcertificate_id | numeric | YES | — | FK → certificate (signing) |
| wssecuritytimestampttl | numeric | YES | — | |
| system | varchar | YES | — | MQ system |
| port | numeric | YES | — | MQ port |
| client | numeric | YES | — | MQ client |
| channel | varchar | YES | — | MQ channel |
| jobdescription | varchar | YES | — | |
| manager | varchar | YES | — | MQ queue manager |
| replyqueue | varchar | YES | — | MQ reply queue |
| sessionname | varchar | YES | — | |
| sessionqueue | varchar | YES | — | |
| timeout | numeric | YES | — | |
| trace | numeric | YES | — | |
| jndiname | varchar | YES | — | |
| provider | varchar | YES | — | |
| ebmscpa_id | numeric | YES | — | |
| ebmsprocessspec | varchar | YES | — | |
| ebmsrequestaction | varchar | YES | — | |
| ebmsproviderxpath | varchar | YES | — | |
| ebmschannelid | varchar | YES | — | |
| ebmspartyid | varchar | YES | — | |
| ebmsotherpartyid | varchar | YES | — | |
| fileprotocol | varchar | YES | — | File transfer protocol |
| hostname | varchar | YES | — | |
| isresponse | boolean | NO | — | |
| factorysetting | boolean | NO | — | |
| forwardconsumercertificate | boolean | NO | — | |

**FK:** adapterendpoint, certificate (×2)
**Referenced by:** adaptersetting

---

## logaction

**Domain:** Logging | **Rows:** 148 | **PK:** `id`

Granular action log entries within service requests or routes.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| logservicerequest_id | numeric | YES | — | FK → logservicerequest |
| logroute_id | numeric | YES | — | FK → logroute |
| name | varchar | NO | — | Action name |
| description | varchar | YES | — | |
| resultdescription | varchar | NO | — | |
| resultdetails | text | YES | — | |
| result | varchar | NO | — | SUCCESS/FAILURE |
| duration | numeric | NO | — | Milliseconds |
| actiontimestamp | timestamp | NO | — | |

**FK:** logservicerequest, logroute

---

## logattachment

**Domain:** Logging | **Rows:** 0 | **PK:** `id`

Attachments on logged messages.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| *(columns)* | | | | |
| logmessage_id | numeric | NO | — | FK → logmessage |

**FK:** logmessage

---

## logmessage

**Domain:** Logging | **Rows:** 66 | **PK:** `id`

Stores actual message XML/SOAP payloads for audit.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| messagekey | varchar | NO | — | Message type key |
| elementvalue | varchar | YES | — | |
| namespace | varchar | NO | — | XML namespace |
| configurationname | varchar | YES | — | |
| message | text | NO | — | Full message content |

**FK:** None
**Referenced by:** logservicerequest (×2), logroute (×3), logattachment

---

## logroute

**Domain:** Logging | **Rows:** 22 | **PK:** `id`

Outbound route log per service request.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| logservicerequest_id | numeric | NO | — | FK → logservicerequest |
| requesttimestamp | timestamp | NO | — | |
| responsetimestamp | timestamp | YES | — | |
| status | varchar | NO | — | |
| erroroccurred | boolean | NO | — | |
| provider | varchar | NO | — | |
| outgoingcomponenttype | varchar | NO | — | |
| outgoingcomponent | varchar | NO | — | |
| outgoingcomponentsearchfield | varchar | NO | — | |
| adapterendpointname | varchar | YES | — | |
| responseisfault | boolean | NO | — | |
| transformedrequest_id | numeric | YES | — | FK → logmessage |
| response_id | numeric | YES | — | FK → logmessage |
| transformedresponse_id | numeric | YES | — | FK → logmessage |
| requesttransformationname | varchar | YES | — | |
| responsetransformationname | varchar | YES | — | |

**FK:** logservicerequest, logmessage (×3)
**Referenced by:** logaction

---

## logservicerequest

**Domain:** Logging | **Rows:** 22 | **PK:** `id`

Top-level service request log entry.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| requesttimestamp | timestamp | NO | — | |
| responsetimestamp | timestamp | YES | — | |
| status | varchar | NO | — | |
| erroroccurred | boolean | NO | — | |
| servicename | varchar | NO | — | |
| axisservicename | varchar | YES | — | |
| incomingcomponenttype | varchar | NO | — | |
| incomingcomponent | varchar | NO | — | |
| responseisfault | boolean | NO | — | |
| consumer | varchar | NO | — | |
| provider | varchar | YES | — | |
| username | varchar | YES | — | |
| consumeradministration | varchar | YES | — | |
| consumerorganisation | varchar | YES | — | |
| consumerpartyid | varchar | YES | — | |
| providerusername | varchar | YES | — | |
| provideradministration | varchar | YES | — | |
| providerorganisation | varchar | YES | — | |
| providerpartyid | varchar | YES | — | |
| servicehandling | varchar | NO | — | SYN/ASYN |
| serviceusagelevel | varchar | NO | — | |
| reference | varchar | YES | — | |
| crossreference | varchar | YES | — | |
| ebmsmsgid | varchar | YES | — | |
| ebmsxrefmsgid | varchar | YES | — | |
| request_id | numeric | YES | — | FK → logmessage |
| response_id | numeric | YES | — | FK → logmessage |
| parentservicerequest_id | numeric | YES | — | FK → logservicerequest (self) |
| processedbyadmin | boolean | NO | — | |
| alias | varchar | YES | — | |
| provideralias | varchar | YES | — | |
| soapaction | varchar | YES | — | |
| resentservicerequestid | numeric | YES | — | |

**FK:** logmessage (×2), logservicerequest (self)
**Referenced by:** logroute, logaction

---

## messagedefinition

**Domain:** Message Layer | **Rows:** 32 | **PK:** `id`

Message type catalog — used to match incoming messages to services.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| description | varchar | YES | — | |
| messagekey | varchar | NO | — | Message type identifier |
| elementvalue | varchar | YES | — | |
| namespace | varchar | NO | — | XML namespace |
| soapaction | varchar | YES | — | |
| configurationname | varchar | YES | — | |
| filterxpath | varchar | YES | — | XPath filter |
| validationactive | boolean | NO | — | |
| factorysetting | boolean | NO | — | |

**FK:** None
**Referenced by:** servicecomponentrelation (×3), channeldefinition, transformationdefinition (×2), elementdefinition

---

## messagevalidation

**Domain:** Validation | **Rows:** 0 | **PK:** `id`

Links element definitions to validators.

**FK:** elementdefinition, validator
**Referenced by:** messagevalidationaction

---

## messagevalidationaction

**Domain:** Validation | **Rows:** 0 | **PK:** `id`

Links message validations to validator actions.

**FK:** messagevalidation, validatoraction
**Referenced by:** messagevalidationactioncfg

---

## messagevalidationactioncfg

**Domain:** Validation | **Rows:** 0 | **PK:** `id`

Configuration per message validation action.

**FK:** messagevalidationaction, validatoractioncfg

---

## orchestrationdefinition

**Domain:** Orchestration | **Rows:** 0 | **PK:** `id`

Orchestration workflow specifications.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| name | varchar | NO | — | |
| namesearchfield | varchar | NO | — | |
| description | varchar | YES | — | |
| implementation | varchar | NO | — | Java class |
| factorysetting | boolean | NO | — | |

**FK:** None
**Referenced by:** channeldefinition, servicecomponentrelation, orchestrationsetting

---

## orchestrationsetting

**Domain:** Orchestration | **Rows:** 0 | **PK:** `id`

Key-value settings per orchestration definition.

**FK:** orchestrationdefinition

---

## revinfo

**Domain:** Audit | **Rows:** 106 | **PK:** `id`

Hibernate Envers revision metadata.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| timestamp | numeric | YES | — | Epoch millis |
| username | varchar | YES | — | Who made the change |

**FK:** None
**Referenced by:** all `_aud` tables

---

## servicecomponentrelation

**Domain:** Core Service | **Rows:** 41 | **PK:** `id`

Wires a service to its implementing adapter, orchestration, and message definitions.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| servicedefinition_id | numeric | NO | — | FK → servicedefinition |
| adapterdefinition_id | numeric | NO | — | FK → adapterdefinition |
| orchestrationdefinition_id | numeric | YES | — | FK → orchestrationdefinition |
| messagedefinitionrequest_id | numeric | YES | — | FK → messagedefinition |
| messagedefinitionresponse_id | numeric | YES | — | FK → messagedefinition |
| messagedefinitionfault_id | numeric | YES | — | FK → messagedefinition |

**FK:** servicedefinition, adapterdefinition, orchestrationdefinition, messagedefinition (×3)

---

## servicedefinition

**Domain:** Core Service | **Rows:** 220 | **PK:** `id`

The service catalog — all integration services available in CGS.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| name | varchar | NO | — | e.g. "iLogboekService", "GeodataService" |
| namesearchfield | varchar | NO | — | |
| description | varchar | NO | — | Dutch description |
| transportformat | varchar | NO | — | AXIOM |
| handling | varchar | NO | — | SYN, ASYN |
| qualityofservice | varchar | NO | — | BESTEFFORT, RELIABLE |
| status | varchar | NO | — | ACTIVE, INACTIVE |
| obsolete | boolean | NO | — | |
| logrequest | boolean | NO | — | |
| logresponse | boolean | NO | — | |
| logfault | boolean | NO | — | |
| logattachments | boolean | NO | — | |
| logactionlevel | varchar | NO | — | |
| validation | boolean | NO | — | |
| validatorclass | varchar | YES | — | |
| factorysetting | boolean | NO | — | |

**FK:** None
**Referenced by:** serviceusage, servicecomponentrelation, channeldefinition

---

## serviceusage

**Domain:** Core Service | **Rows:** 657 | **PK:** `id`

Junction table: which application can use which service.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| servicedefinition_id | numeric | NO | — | FK → servicedefinition |
| application_id | numeric | NO | — | FK → application |

**FK:** servicedefinition, application

---

## transformationdefinition

**Domain:** Message Layer | **Rows:** 5 | **PK:** `id`

XSLT transformation specifications between message formats.

| Column | Type | Nullable | Default | Notes |
|---|---|---|---|---|
| id | numeric | NO | — | PK |
| changecounter | numeric | NO | 1 | |
| messagedefinitionoriginal_id | numeric | NO | — | FK → messagedefinition (source) |
| messagedefinitiontarget_id | numeric | NO | — | FK → messagedefinition (target) |
| content_id | numeric | NO | — | FK → xsltcontent |

**FK:** messagedefinition (×2), xsltcontent
**Referenced by:** channeldefinition (×3)

---

## validator

**Domain:** Validation | **Rows:** 0 | **PK:** `id`

Validator definitions.

**FK:** None
**Referenced by:** validatoraction, messagevalidation

---

## validatoraction

**Domain:** Validation | **Rows:** 0 | **PK:** `id`

Actions per validator.

**FK:** validator
**Referenced by:** validatoractioncfg, messagevalidationaction

---

## validatoractioncfg

**Domain:** Validation | **Rows:** 0 | **PK:** `id`

Configuration per validator action.

**FK:** validatoraction
**Referenced by:** messagevalidationactioncfg

---

## xsltcontent

**Domain:** Message Layer | **Rows:** 1 | **PK:** `id`

Stores actual XSLT stylesheet content.

**FK:** None
**Referenced by:** transformationdefinition

---

## Audit Tables

All audit tables follow the Hibernate Envers pattern:

| Table | PK | FK |
|---|---|---|
| `adapterendpoint_aud` | id, rev | rev → revinfo |
| `adaptersetting_aud` | id, rev | rev → revinfo |
| `application_aud` | id, rev | rev → revinfo |
| `channeldefinition_aud` | id, rev | rev → revinfo |
| `endpointconfiguration_aud` | id, rev | rev → revinfo |
| `orchestrationsetting_aud` | id, rev | rev → revinfo |

Each `_aud` table mirrors the columns of its parent table (nullable) plus `revtype` (0=INSERT, 1=UPDATE, 2=DELETE).
