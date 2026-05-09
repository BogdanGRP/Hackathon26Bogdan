# CGSHelp PDF ↔ Database Schema Connections

> **Source PDF:** `CGSHelpPDF.pdf` — CiVision Municipal Service Bus Manual v2.7.17 (PinkRoccade Local Government), 209 pages
> **Source Schema:** `igp_ontwikkel_cgs_owner` — 46 tables, 9 domains
> **Cross-referenced specs:** `cgs-schema-docs.md`, `cgs-schema-tables.md`, `cgs-schema-overview.md`, `cgs-schema-er-diagram.md`
> **Generated:** 2026-05-08

---

## 1. Terminology Mapping (PDF ↔ Database)

The PDF uses UI/business language; the database uses technical table names. This mapping is critical for building accurate diagrams.

| PDF Term (UI) | Database Table | Notes |
|---|---|---|
| Services | `servicedefinition` | 1:1 mapping. PDF fields: Name, Status, Handling, QoS, logging flags |
| Service Authorization | `serviceusage` | Junction: which app may call which service. PDF adds usage level (Test/Production) |
| Message Configuration | `servicecomponentrelation` | Wiring: links service → adapter + request/response/fault message defs |
| Routings | `channeldefinition` | PDF "routing" = DB "channel". Filters + transformation per route |
| Applications | `application` | Consumer/provider apps. PDF adds alias concept |
| Application Opening Periods | `applicationopeningperiod` | When async delivery is allowed (day/time windows) |
| Adapters | `adapterdefinition` | Protocol type + direction (IN/OUT) |
| Adapter Endpoints | `adapterendpoint` | Named connection point bound to app alias |
| Adapter Endpoint Configuration | `endpointconfiguration` | Physical connection details (URL, credentials, WS-*, MQ, ebMS) |
| Adapter Endpoint Settings | `adaptersetting` | Key-value extensions per endpoint |
| Transformations | `transformationdefinition` | XSLT or Java transformation between message formats |
| Orchestrations | `orchestrationdefinition` | Composite service logic (multi-step) |
| Message Definitions | `messagedefinition` | Message format identification (namespace + key + element) |
| Public/Private Certificates | `certificate` | TLS and signing certificates |
| Settings | `cgssetting` | Global CGS configuration key-value pairs |
| Dashboard | reads `logservicerequest` | Aggregated view of service call counts and status |
| Logging | `logservicerequest`, `logroute`, `logaction`, `logmessage` | Full audit trail |
| Sending Processes | runtime (no config table) | Async message queue, not persisted in config DB |
| Digikoppeling / ebMS | `ebmscpa`, `ebmsmessage`, `ebmsattachment`, `ebmssendevent`, `ebmsmapping` | Government messaging standard |
| CMIS Configuration | `cmisproviderconfiguration`, `cmisrepository`, `cmispropertymapping` | DMS integration |
| Postinstall | not in schema | Import mechanism for configuration bundles |
| Supplier Setting | `vendor_setting` flag on most tables | PRLG-delivered config that cannot be modified by customers |

---

## 2. Runtime Processing Steps (PDF p.7-8 ↔ Domain Flow)

The PDF defines the **exact processing steps** for every incoming service request. Each step maps to specific database tables:

| Step | PDF Action Name | DB Tables Read | DB Tables Written |
|---|---|---|---|
| 1 | Configuration Validation | `servicedefinition`, `servicecomponentrelation` | — |
| 2 | Service License Check | `serviceusage` | — |
| 3 | Authorization | `serviceusage` (usage level: Test/Production) | — |
| 4 | Message Validation | `messagedefinition`, `elementdefinition`, `validator`, `validatoraction` | — |
| 5 | Routing | `channeldefinition` (filters: provider app, message filter, XPath, consumer org) | — |
| 6 | Storage in Queue | — (runtime only, async services) | — |
| 7 | Transformation (optional) | `transformationdefinition`, `xsltcontent` | — |
| 8 | Delivery | `adapterdefinition`, `adapterendpoint`, `endpointconfiguration`, `certificate` | — |
| — | (all steps) | — | `logservicerequest`, `logroute`, `logaction`, `logmessage` |

**Key insight from PDF:** Step 2 (License Check) and Step 3 (Authorization) are separate — the PDF reveals that `serviceusage` has a **usage level** concept (Test vs Production) that controls which `endpointconfiguration` is used. This is not obvious from the database schema alone.

---

## 3. Routing Rules (PDF p.48-51 ↔ `channeldefinition`)

The PDF reveals detailed **routing semantics** not documented in the schema specs:

### Filter Logic
- **AND combination**: When multiple filters are set on one routing, the incoming message must satisfy ALL conditions
- **XPath filter rules** for duplicate routings:
  - 2 routings same provider, both without XPath → message placed on **both** routes
  - 2 routings same provider, both same XPath → message placed on **both** routes
  - 2 routings same provider, one with XPath one without → message **only on the XPath route**

### Routing Filters → `channeldefinition` Columns
| PDF Filter Name | DB Column |
|---|---|
| Request addressed to application | `filterprovidingapplication_id` |
| Requesting application | (extra filter criteria) |
| Request addressed to organisation | `filterproviderorganisation` |
| Requesting organisation | `filterconsumerorganisation` |
| Request message filter | `filtermessagedefinition_id` |
| XPath filter | `filterxpath` |
| Request transformation | `requesttransformation_id` |
| Response transformation | `responsetransformation_id` |
| Error transformation | `faulttransformation_id` |

### Bv04→Bv03 Transformation
The PDF documents a specific transformation pattern: the broker suite returns Bv04 (broker confirmation) but end applications expect Bv03 (application confirmation). The transformation `bv042Bv03Bericht` can be selected as Response transformation on a routing. This maps to:
- `channeldefinition.responsetransformation_id` → `transformationdefinition` where name = `bv042Bv03Bericht`

---

## 4. Adapter Configuration Details (PDF p.51-58 ↔ `endpointconfiguration`)

The PDF reveals that `endpointconfiguration` is a **protocol-polymorphic** table — different columns are used depending on the adapter type:

| Adapter Type | PDF-Documented Fields | DB Columns Used |
|---|---|---|
| **WebService** | URL, User, Password, Certificate, Chunked, SOAP version, MTOM, WS-Addressing, WS-Security, Security TTL, Signing certificate | `url`, `username`, `password`, `certificate_id`, `chunked`, `soapversion`, `enablemtom`, `enablewsaddressing`, `enablewssecurity`, `securityttl`, `signingcertificate_id` |
| **ABAP** | System, Port, Client, User, Password, Certificate | `system`, `port`, `client`, `username`, `password`, `certificate_id` |
| **MQ** | System, Port, User, Manager, Channel, Session name, Session queue, Response queue, Timeout, Trace level, Job description | `system`, `port`, `username`, `manager`, `channel`, `sessionname`, `sessionqueue`, `responsequeue`, `timeout`, `tracelevel`, `jobdescription` |
| **HTTP** | URL, User, Password, Certificate, Chunked | `url`, `username`, `password`, `certificate_id`, `chunked` |
| **ebMS** | Status of certificate/CPA, OIN, ebMS CPA, Profile, Process, XPath filter | `ebmscpa_id`, `profile`, `processspecification`, `xpathfilter` |
| **Java** | JNDI Name, Provider | `jndiname`, `provider` |
| **File/FTP** | (hostname, fileprotocol) | `hostname`, `fileprotocol` |

**Key insight:** The PDF explicitly states that Test vs Production configurations exist per endpoint — `endpointconfiguration` has at least 2 rows per endpoint (one for each environment).

---

## 5. Application Connections (PDF p.115-139 ↔ `serviceusage` + `application`)

The PDF documents the **exact service authorizations** for each application. This is the most diagram-ready data — it defines every consumer↔service edge.

### PinkRoccade (Built on SAP) Applications

| Application | PDF Abbreviation | Authorized Services (from PDF) | Connection Type |
|---|---|---|---|
| CiVision Addresses & Buildings | CGA | OpvragenAutorisatieCMG, OpvragenConsistentieControleCMG, OpvragenLeverGegevensCMG, OpvragenMutatiesCMM, PlaatsBerichtCMG, StUFBeantwoordVraagBG, StUFOntvangAsynchroonBG, StUFVerwerkTriggerbericht | ABAP (Built on SAP) |
| CiVision Taxes Basis | CBB | OpvragenAutorisatieCMG, OpvragenConsistentieControleCMG, OpvragenLeverGegevensCMG, OpvragenMutatiesCMM, PlaatsBerichtCMG, RDWService, StUFBeantwoordVraagBG, StUFBeantwoordVraagWKPB, StUFBeantwoordVraagWOZ, StUFOntvangAsynchroonBG, StUFOntvangAsynchroonWOZ, StUFOntvangAsynchroonZKN, StUFVerwerkKennisgevingWKPB, StUFVerwerkTransactieWKPB, StUFVerwerkTriggerbericht | ABAP (Built on SAP) |
| CiVision Collection | CIN | OpvragenAutorisatieCMG, OpvragenConsistentieControleCMG, OpvragenLeverGegevensCMG, OpvragenMutatiesCMM, PlaatsBerichtCMG, StUFBeantwoordVraagBG, StUFOntvangAsynchroonBG, StUFVerwerkTriggerbericht | ABAP (Built on SAP) |
| CiVision Land Registry | CKD | OpvragenAutorisatieCMG, OpvragenConsistentieControleCMG, OpvragenLeverGegevensCMG, OpvragenMutatiesCMM, PlaatsBerichtCMG, StUFBeantwoordVraagBG, StUFOntvangAsynchroonBG, StUFVerwerkTriggerbericht | ABAP (Built on SAP) |
| CiVision Resources | CMD | OpvragenAutorisatieCMG, OpvragenConsistentieControleCMG, OpvragenLeverGegevensCMG, OpvragenMutatiesCMM, PlaatsBerichtCMG, StUFBeantwoordVraagBG, StUFOntvangAsynchroonBG, StUFVerwerkTriggerbericht | ABAP (Built on SAP) |
| CiVision Basic Registration | CBR/SAP | OpvragenAutorisatieCMG, OpvragenConsistentieControleCMG, OpvragenLeverGegevensCMG, OpvragenMutatiesCMM, OpvragenPersoonsDossierGBAVviaCML, PlaatsBerichtCMG, StUFBeantwoordVraagBG, StUFOntvangAsynchroonBG, StUFOntvangAsynchroonZKN, StUFVerwerkTriggerbericht | ABAP (Built on SAP) |
| CiVision Basis | CBS | OpvragenItpCheckConnection, OpvragenItpGetVersion, OpvragenItpPathExists, OpvragenItpPrinterCount, OpvragenItpPrinterExists, OpvragenItpPrinterInfo, OpvragenItpSubmitJobASync | ABAP (Built on SAP) |
| CiVision Case Handling | CZA | ApplicatieService, GenerateDocument, OpvragenAutorisatieCMG, OpvragenConsistentieControleCMG, OpvragenLeverGegevensCMG, OpvragenMutatiesCMM, PlaatsBerichtCMG, StUFBeantwoordVraagBG, StUFBeantwoordVraagZKN, StUFOntvangAsynchroonBG, StUFOntvangAsynchroonZKN, StUFVerwerkTriggerbericht, CMISDiscoveryService, CMISNavigationService, CMISObjectService, CMISRepositoryService, CMISVersioningService | ABAP (Built on SAP) |

### WebService/Certificate-based Applications

| Application | Authorized Services (from PDF) | Connection Type |
|---|---|---|
| CiPers (CIPERS) | AanvragenBSNVoorraadBVBSN, OpvragenPersoonsDossierGBAV, PresentievraagBVBSN, StUFOntvangAsynchroonZKN, WijzigenWachtwoordGBAV, OpvragenAfnemerIndicaties, OpvragenPersoonsDossierGBAVBZ, OpvragenVolledigePL | WebService + certificate |
| CiVision Portal / KCC | AWRService, JCCService, KCRService, OpvragenPersoonsDossierGBAVviaCML, StUFBeantwoordVraagBG, StUFBeantwoordVraagBZ, StUFBeantwoordVraagIntegraalBG, StUFBeantwoordVraagWOZ, StUFBeantwoordVraagZKN | WebService + certificate |
| iBurgerzaken | BijhoudingBRP, BevragingBRP, CMISNavigationService, CMISObjectService, CMISRepositoryService, CMISDiscoveryService | WebService + certificate |
| CiVision Broker Data | CMG | StUFOntvangAsynchroonBG, PlaatsBerichtGBAVOA | Internal (standard install) |
| CiVision Broker National | CML | ApplicatieService, ControlIdentifyingDataBVBSN, RetrieveIdentifyingDataBVBSN, OpvragenBSNBVBSN, OpvragenPersoonsDossierGBAV, OpvragenPersoonsDossierPIVAV, OpvragenPersoonsDossierGBAVRetour, OvernemenPersoonGBAV, OvernemenPersoonPIVAV, OvernemenVolgenNamensCMLinVOA, RegistrerenRetourmeldingGBAV, VerifieerIdentiteitsDocumentBVBSN, VerzendEmail, WijzigenWachtwoordGBAV, WijzigenWachtwoordPIVAV, ZoekNummerBVBSN | Internal (standard install) |
| GBAVOA | PlaatsBerichtCMG | WebService + certificate |
| LV WOZ | StUFOntvangAsynchroonWOZLV | WebService + certificate |
| Legacy (HRS/OIS) | StUFBeantwoordVraagBG, StUFOntvangAsynchroonBG | WebService + certificate |
| OLO (Omgevingsloket) | StUFOntvangAsynchroonLVO | Digikoppeling (ebMS or JNet) |

### Third-Party Partners (PDF p.134-137)

| Supplier | Abbreviation | StUF App Name | CGS Consumer App | Key Services |
|---|---|---|---|---|
| BCT | BCT | CORSA | DMS | StUF-ZKN, StUF-BG (sync+async), CMIS |
| Brain | BRAIN | InProcess | FrontOffice | StUF-BG/BZ (sync), GBA-V, StUF-EF |
| Circle | CIRCLE | VERSEON | DMS | StUF-ZKN, StUF-BG |
| Decos | DEC | DOCUMENT | DMS | StUF-ZKN, StUF-BG |
| GemeenteWeb | GW | GW | FrontOffice | StUF-BG/BZ (sync), GBA-V |
| GreenValley | GV | GVCMS | FrontOffice | StUF-BG/BZ (sync), GBA-V |
| JCC Software | JCC | GBOS | JCC | JCCService |
| Logica | DSB | DSB | FrontOffice | StUF-BG/BZ (sync), GBA-V |
| QNH | QNH | QNH | FrontOffice | StUF-BG/BZ (sync), GBA-V |
| Roxit | SQT | SquitXO | SQUITXO | StUF-ZKN, StUF-BG, StUF-LVO, GBA-V |
| SIM | SIM | simsite | FrontOffice | StUF-BG/BZ (sync), GBA-V, KCR |
| Yucat BV | YUCAT | BuitenBeter | BuitenBeter | StUF-EF |
| OLO | OLO | OLO | OLO | StUF-LVO |

---

## 6. URL Pattern Mapping (PDF p.24-38 ↔ `endpointconfiguration.url`)

The PDF documents **80+ web service URLs** in standardized patterns. These map to the `url` column in `endpointconfiguration`:

| URL Pattern | Protocol Stack | Service Domain | Port |
|---|---|---|---|
| `https://[server]:8443/CGS/ws/services/{Name}?wsdl` | SOAP/WebService | Generic services | 8443 |
| `https://[server]:8443/CGS/ws1/services/{Name}?wsdl` | SOAP/WebService | Extended services | 8443 |
| `https://[server]:8443/CGS/StUF/services/{Name}?wsdl` | SOAP/StUF | StUF 0204 services | 8443 |
| `https://[server]:8443/CGS/StUF/0301/{sector}/{version}/services/{Name}?wsdl` | SOAP/StUF | StUF 0301 services | 8443 |
| `https://[server]:8443/CGS/ABAP/services/{Name}?wsdl` | SOAP via SAP JCo | SAP-backed services | 8443 |
| `https://[server]:8443/CGS/UNIFACE/services/{Name}?wsdl` | SOAP via STUNNEL | UNIFACE/CWIZ services | 8443 |
| `https://[server]:8444/CGS/ebms/services/Digikoppeling?wsdl` | ebMS/Digikoppeling | Government interop | **8444** |
| `https://[server]:8443/CGS/ws/suwi/services/{Name}?wsdl` | SOAP/SuwiML | Social domain services | 8443 |
| `https://[server]:8443/CGS/ws/easypark/services/{Name}?wsdl` | SOAP/Custom | EasyPark parking | 8443 |

**Key insight:** ebMS/Digikoppeling uses **port 8444** (not 8443). This is important for network/firewall configuration.

---

## 7. Digikoppeling/ebMS Flow (PDF p.105-112 ↔ `ebms*` tables)

The PDF describes the **exact ebMS message flow** through CGS, providing context that the database tables alone cannot reveal:

### Incoming ebMS Flow
```
External Partner (e.g. LV WOZ)
    │
    │ SOAP message on port 443 → proxy → port 8444
    ▼
ebMSServlet (httpprocessor)
    │── Immediate SOAP ACK response to partner
    │
    ├── Lookup CPA (ebmscpa table)
    ├── Store in MSG Store (ebmsmessage + ebmsattachment)
    │
    ├── Send Acknowledge back to partner (async, via return channel)
    │   URL from CPA, retry count from CPA
    │
    └── Fire event to EBMSINADAPTER (via MKS CRUD layer)
         │
         └── CGS Routing Service places on sending process
              │
              └── Delivered to receiving application (e.g. CBB)
                   └── Bv03 response returned
```

### Outgoing ebMS Flow
```
Requesting Application (e.g. CBB)
    │
    ├── ABAPxxINADAPTER → BV04 response to requester
    │
    └── Routed to EBMSOUTADAPTER
         │
         ├── Retrieve CPA from ebmscpa
         ├── Store in MSG Store (N copies per CPA retry setting)
         │
         └── ebMS Out Sending Threads (multithreaded)
              │
              ├── Send to partner URL (from CPA) on port 443
              │   └── Partner returns SOAP ACK
              │
              └── Receive Acknowledge (async, via ebMSServlet)
                   └── Mark original as delivered
                   └── Remove remaining retry copies
```

### ebMS Table Roles (from PDF context)
| Table | PDF-Revealed Purpose |
|---|---|
| `ebmscpa` | Stores imported CPA (Collaboration Protocol Agreement) — the "contract" between parties. Contains URLs, certificates, QoS, retry settings, profiles for both parties. |
| `ebmsmessage` | MSG Store — holds messages with N copies per CPA retry setting. Marked as processed when Acknowledge received. |
| `ebmsattachment` | MIME attachments (SwA — Soap with Attachments standard, precursor to MTOM) |
| `ebmssendevent` | Tracks each send attempt with timestamp and result |
| `ebmsmapping` | Maps CPA → provider application. Configured in EBMSINADAPTER settings. |

---

## 8. CMIS / Case DMS Bridge (PDF p.95-102 ↔ `cmis*` tables)

The PDF reveals the **Case DMS Bridge** orchestration that connects to Alfresco, Decos (DOCUMENT), or BCT (CORSA):

### DMS Synchronization Modes
1. **Via Changelog** — periodic background task (frequency configurable in orchestration setting `ZAAKDMSBRUG_CHANGELOG_FREQ`). Retrieves changes from DMS, converts to StUF-ZKN messages.
2. **Full Synchronization** — one-time initial sync of all cases/documents from DMS to case warehouse.

### DMS Provider Types (PDF → `cmisproviderconfiguration`)
| PDF DMS Type | Provider Configuration Value | Target Application |
|---|---|---|
| Alfresco | `ALF` (default) | Alfresco DMS |
| Decos | `DOCUMENT` | Decos DMS |
| BCT | `CORSA` | Corsa DMS |

### CMIS Services (PDF-documented, DB-confirmed)
- `CMISNavigationService` — folder structure retrieval
- `CMISObjectService` — CRUD operations on repository objects
- `CMISRepositoryService` — repository metadata
- `CMISDiscoveryService` — query-based data retrieval
- `CMISVersioningService` — document locking/unlocking
- `CMISMultiFilingService` — multi-folder filing operations

---

## 9. UNIFACE/CWIZ Architecture (PDF p.111-114)

The PDF reveals the **STUNNEL** proxy architecture for UNIFACE connections — not visible in the database:

```
Incoming (CWIZ → CGS):
  UNIFACE APP SERVER → STUNNEL (port 8085) → MKS (port 8443)

Outgoing (CGS → CWIZ):
  MKS → STUNNEL (port 15000) → UNIFACE APP SERVER (port 13000, uRouter)
```

This explains why UNIFACE adapters exist in the database but their endpoints don't have standard HTTP URLs.

---

## 10. Key Insights Only in the PDF (Not in Schema)

These facts enrich the database specifications but cannot be discovered from the schema alone:

| # | Insight | Impact on Diagrams |
|---|---|---|
| 1 | **Usage levels (Test/Production)** on `serviceusage` control which `endpointconfiguration` row is used | Draw separate Test/Production paths |
| 2 | **Opening periods** halt async delivery but NOT sync messages | Show async queue bypass for open/closed states |
| 3 | **Certificate ↔ Application is 1:1** — a certificate can only be linked to one application | Add constraint to ER diagram |
| 4 | **Supplier/Vendor settings** are immutable by customers | Mark vendor-managed vs customer-managed config |
| 5 | **Bv04→Bv03 transformation** is a standard routing pattern | Show broker confirmation vs application confirmation flow |
| 6 | **ebMS port 8444** vs standard port 8443 | Network architecture diagrams need separate ports |
| 7 | **STUNNEL proxy** for UNIFACE (ports 8085, 15000, 13000) | Infrastructure layer in deployment diagrams |
| 8 | **Dashboard auto-refresh** reads log tables periodically | Show monitoring as continuous read on log tables |
| 9 | **XPath filter rules** determine multi-route fan-out behavior | Complex routing logic in flow diagrams |
| 10 | **CPA contains message definitions + endpoint configs** from both parties — comparable to `servicecomponentrelation` + `endpointconfiguration` combined | ebMS domain can be drawn as a mirror of core routing |
| 11 | **Changelog frequency** in orchestration settings drives DMS sync | Background process flow for CMIS diagrams |
| 12 | **6 processing steps** define the exact CGS runtime pipeline | Sequence diagram step ordering |

---

## 11. Service Catalog (PDF ↔ `servicedefinition`)

The PDF documents **80+ services with descriptions and URLs**. Here are the service categories with their PDF descriptions and DB matches:

### StUF Services — By Sector Model
| Service Name | PDF Description | Sector Model | Handling |
|---|---|---|---|
| StUFBeantwoordVraagBG | Synchronously retrieve objects | BG (Burgerzaken) 0204 + 0310 | SYN |
| StUFOntvangAsynchroonBG | Asynchronously receive notifications/questions/answers/errors | BG 0204 + 0310 | ASYN |
| StUFBeantwoordVraagZKN | Synchronously retrieve objects | ZKN (Zaakgericht) 0201 + 0310 | SYN |
| StUFOntvangAsynchroonZKN | Asynchronously receive notifications | ZKN 0201 + 0310 | ASYN |
| StUFBeantwoordVraagWOZ | Synchronously retrieve objects | WOZ (Waardering) | SYN |
| StUFOntvangAsynchroonWOZ | Asynchronously receive messages (not from LV WOZ) | WOZ 0312 | ASYN |
| StUFOntvangAsynchroonWOZLV | Asynchronously receive from LV WOZ | WOZ 0312 (national) | ASYN |
| StUFBeantwoordVraagBZ | Synchronously retrieve objects | BZ (Belastingen) | SYN |
| StUFOntvangAsynchroonBZ | Asynchronously receive messages | BZ | ASYN |
| StUFOntvangAsynchroonEF | Asynchronously receive messages | EF (e-Formulieren) 0204/0310/0315 | ASYN |
| StUFOntvangAsynchroonLVO | Process asynchronous LVO messages | LVO (Omgevingsloket) | ASYN |
| StUFVrijeBerichtenZKN | Free messages | ZKN 0310 | ASYN |
| StUFValideerAsynchroonBericht | Validate async message with detailed error return | BG 0204 | SYN |

### National Facility Services
| Service Name | PDF Description | External Party |
|---|---|---|
| BevragingBRP | Synchronous person query from BRP | Basisregistratie Personen |
| BijhoudingBRP | Registration maintenance at BRP | Basisregistratie Personen |
| OpvragenPersoonsDossierGBAV | Request Person GBA-V | GBA-V (via CML) |
| OvernemenPersoonGBAV | Take over Person GBA-V | GBA-V (via CML) |
| OpvragenAfnemerIndicaties | Request customer indicators GBA-V | GBA-V |
| BVBSNAanvragenBSNVoorraad | Request BSN stock | BV-BSN |
| BVBSNPresentievraag | Real-time presence question | BV-BSN |
| StUFMassaleBevragingWOZ0312 | Mass WOZ query from Kadaster | Kadaster |

### Domain-Specific Services
| Service Name | PDF Description | Protocol |
|---|---|---|
| CMISObjectService | CRUD operations via CMIS | CMIS/WebService |
| CMISNavigationService | Folder structure retrieval via CMIS | CMIS/WebService |
| FtpService | File exchange via FTP | FTP |
| SimplerInvoicingService | UBL message exchange via OpenPeppol | ebMS/WUS |
| DigipoortAanleveren | Electronic message delivery to Digipoort | UNIFACE |
| PrinterService | File printing (iBurgerzaken) | WebService |
| GenerateDocument | Document generation via ITP | ABAP/WebService |
| VerzendEmail | Send email service | Internal |

---

## 12. Diagram-Ready Relationship Sets

These extracted relationships can be directly used to build PlantUML, ArchiMate, or Mermaid diagrams.

### A. Consumer → Service Authorization Matrix
```
CGA  → [CMG-ops(5), StUF-BG(2), Trigger(1)]  = 8 services
CBB  → [CMG-ops(5), StUF-BG/WOZ/WKPB/ZKN(7), RDW(1), Trigger(1)]  = 14 services
CIN  → [CMG-ops(5), StUF-BG(2), Trigger(1)]  = 8 services
CKD  → [CMG-ops(5), StUF-BG(2), Trigger(1)]  = 8 services
CMD  → [CMG-ops(5), StUF-BG(2), Trigger(1)]  = 8 services
CBR  → [CMG-ops(5), StUF-BG/ZKN(3), GBA-V(1), Trigger(1)]  = 10 services
CBS  → [ITP(7)]  = 7 services
CZA  → [CMG-ops(5), StUF-BG/ZKN(4), CMIS(5), GenerateDoc(1), Trigger(1), AppSvc(1)]  = 17 services
CML  → [GBA-V/PIVA-V(6), BV-BSN(4), VOA(2), Email(1), AppSvc(1)]  = 16 services (estimated)
CIPERS → [GBA-V(4), BV-BSN(2), StUF-ZKN(1), WachtwoordGBAV(1)]  = 8 services
CPT/KCC → [AWR(1), JCC(1), KCR(1), GBA-V(1), StUF-BG/BZ/WOZ/ZKN(5)]  = 9 services
iBurgerzaken → [BRP(2), CMIS(4)]  = 6 services
```

### B. Provider Connection Types
```
ABAP providers: CBB, CBR, CGA, CIN, CKD, CMD, CZA (SAP JCo via STUNNEL)
WebService providers: CGS (internal), GEOTAX, CWIZ, external services
Java providers: CMG, internal services
MQ providers: Legacy (HRS, OIS) via IBM MQ
ebMS providers: LV WOZ, OLO (via Digikoppeling)
UNIFACE providers: CWIZ (Digipoort, GPK, NationalParkeerRegister)
FTP providers: file-based integrations
```

### C. Transformation Chains
```
StUF BG 0204 ←→ StUF BG 0210 (Centric variant)
StUF BG 0204 ←→ StUF BG 0310 (standard evolution)
StUF 0204 ←→ StUF 0301 (framework version)
Bv04 → Bv03 (broker confirmation → application confirmation)
Any format → wildCardRequest (custom XSLT transformation)
```

### D. Cross-Domain Integration Points
```
CGS ←→ BRP (Basisregistratie Personen): BevragingBRP, BijhoudingBRP
CGS ←→ GBA-V: OpvragenPersoonsDossier, OvernemenPersoon, WijzigenWachtwoord
CGS ←→ BV-BSN: AanvragenBSNVoorraad, Presentievraag, VerifieerIdentiteitsDocument
CGS ←→ LV WOZ: StUFOntvangAsynchroonWOZLV (via Digikoppeling ebMS)
CGS ←→ NHR/KVK: KVKMutatieService, StUFBeantwoordVraagNHR
CGS ←→ Digipoort: DigipoortAanleveren, DigipoortStatusinformatie (via UNIFACE)
CGS ←→ DMS: CMIS services (Alfresco/Decos/Corsa)
CGS ←→ OLO: StUFOntvangAsynchroonLVO (via Digikoppeling)
CGS ←→ CMG/CMM: Distribution API, Magazine API, VOA API
```
