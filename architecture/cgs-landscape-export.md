# CGS Service Landscape

## Table of Contents

- [Overview](#overview)
- [Application Layer](#application-layer)
- [Composite Layer](#composite-layer)
- [Views](#views)

## Overview

- **Elements:** 39
- **Relationships:** 20
- **Views:** 1

## Application Layer

### Application Components

#### iBurgerzaken

Burgerzaken 2.0 — municipal citizen records system. Top consumer: 42 production services.

**Relationships:**

- StUF Services -> Serving "StUF"
- BRP/GBA Services -> Serving "BRP/GBA"

#### CIPERS

CiPers — citizen persons administration. 11 production services.

**Relationships:**

- BRP/GBA Services -> Serving "BRP/GBA"

#### CZA

CiVision Zaakafhandeling — case handling system. 30 production services.

**Relationships:**

- StUF Services -> Serving "StUF"
- Zaak Services -> Serving "Zaak"

#### WebNext

WebNext Zaaksysteem — web-based case management. 20 production services.

#### Corsa

BCT Corsa — document and case management DMS. 16 production services.

#### Alfresco

Alfresco DMS — document management system. 9 production services.

#### CWIZ

CiVision Samenlevingszaken — social affairs platform. 25 production services.

**Relationships:**

- StUF Services -> Serving "StUF"

#### iSamenleving

iSamenleving application — integrated social domain. 22 production services.

#### CMO

CiVision Maatschappelijke Ondersteuning — social support (WMO). 9 production services.

#### CBB

CiVision Belastingen — municipal tax system. 31 production services.

**Relationships:**

- Query Services -> Serving "Query"

#### CIN

CiVision Innen — debt collection and enforcement. 12 production services.

#### CMD

CiVision Middelen — financial management (CMD). 8 production services.

#### CBR

CiVision Basisregistratie — base registrations (BAG/WOZ). 10 production services.

**Relationships:**

- Query Services -> Serving "Query"

#### CGA

CiVision Adressen en Gebouwen — addresses and buildings (BAG). 8 production services.

#### CKD

CiVision Kadaster — land registry system (BRK). 8 production services.

#### FrontOffice

Front Office — citizen-facing front office portal. 20 production services.

**Relationships:**

- Integration Services -> Serving "Integration"

#### CPT

CiVision Portaal — staff-facing municipal portal. 8 production services.

#### CMG

CiVision Makelaar Gegevens — data broker / integration mediator. 13 production services.

#### CIR

CiVision Integraal Raadplegen (NodeJS) — integrated data consultation, NodeJS implementation. 8 production services.

#### CML

CiVision Makelaar Landelijke Voorzieningen — national registry broker. 27 production services.

**Relationships:**

- KVK/NHR Services -> Serving "KVK/NHR"

#### CGS

CiVision Gemeentelijke Servicebus — the central integration platform / ESB. Routes all service calls between municipal apps and national registries. 18 production services hosted.

**Relationships:**

- Serving "hosts" -> StUF Services
- Serving "hosts" -> Query Services
- Serving "hosts" -> BRP/GBA Services
- Serving "hosts" -> Zaak Services
- Serving "hosts" -> KVK/NHR Services
- Serving "hosts" -> Integration Services

#### \[External\] NHR

Nieuw Handelsregister — national trade register (KVK). Provides StUFBeantwoordVraagNHR service.

**Relationships:**

- Serving "NHR data" -> KVK/NHR Services

#### \[External\] KVK

Kamer van Koophandel — chamber of commerce. Consumer of NHR services and provider of KVKEventService.

**Relationships:**

- Serving "KVK events" -> KVK/NHR Services

#### GWS

GWS — GBA/BRP registration system. Provides BRP base registration services.

**Relationships:**

- Serving "BRP/GBA data" -> BRP/GBA Services

#### FIN

Financial system — external provider for CLIQWUSService (providerorganisation=FIN in logservicerequest).

**Relationships:**

- Serving "Financial data" -> Integration Services

### Application Services

#### StUF Services

Category: 60 StUF (Standard Exchange Format) services — synchronous and asynchronous message exchange for BG, BZ, ZKN, BAG, WOZ, DCR, and more. Core integration protocol for Dutch municipal systems.

**Relationships:**

- Serving "StUF" -> iBurgerzaken
- Serving "StUF" -> CZA
- Serving "StUF" -> CWIZ
- CGS -> Serving "hosts"

#### Query Services

Category: 28 query services — data retrieval for persons (GBA/BRP), BSN, dossiers, klantkaart, WOZ, ZTC, and more (Opvragen* naming pattern).

**Relationships:**

- Serving "Query" -> CBB
- Serving "Query" -> CBR
- CGS -> Serving "hosts"

#### BRP/GBA Services

Category: 17 BRP/GBA services — citizen base registration: BevragingBRP, BijhoudenPersoon, ActualiserenGBA, BVBSN identity verification, and related national registry interactions.

**Relationships:**

- Serving "BRP/GBA" -> iBurgerzaken
- Serving "BRP/GBA" -> CIPERS
- CGS -> Serving "hosts"
- GWS -> Serving "BRP/GBA data"

#### Zaak Services

Category: 4 zaak (case) services — ZTC case-type catalogue management: OpvragenAfhandelingZTC, ToevoegenZaaktypeGegevens, WijzigenZaaktypeGegevens, NotificatieToevoegingAfhandeling.

**Relationships:**

- Serving "Zaak" -> CZA
- CGS -> Serving "hosts"

#### KVK/NHR Services

Category: 3 KVK/NHR services — trade register interactions: KVKEventService, StUFBeantwoordVraagNHR, OpslaanMaatschappelijkeActiviteitService. Live traffic confirmed in logservicerequest.

**Relationships:**

- Serving "KVK/NHR" -> CML
- CGS -> Serving "hosts"
- \[External\] NHR -> Serving "NHR data"
- \[External\] KVK -> Serving "KVK events"

#### Integration Services

Category: Remaining integration services — document generation, email, printing, CMIS, Digilevering, Berichtenbox, and platform operational services (94 services).

**Relationships:**

- Serving "Integration" -> FrontOffice
- CGS -> Serving "hosts"
- FIN -> Serving "Financial data"

## Composite Layer

### Groupings

#### Burgerzaken

Burgerzaken domain — citizen records and persons administration. Apps: iBurgerzaken, CIPERS.

#### Zaakgericht Werken

Zaakgericht Werken — case and document management. Apps: CZA, WebNext, Corsa, Alfresco.

#### Sociaal Domein

Sociaal Domein — social support and community services. Apps: CWIZ, iSamenleving, CMO.

#### Belastingen en Middelen

Belastingen en Middelen — tax, finance and enforcement. Apps: CBB, CIN, CMD.

#### Geo en Ruimte

Geo en Ruimte — geo, cadastre and base registrations. Apps: CBR, CGA, CKD.

#### Portaal en Integratie

Portaal en Integratie — portals, data brokers and integration mediators. Apps: FrontOffice, CPT, CMG, CIR, CML.

#### CGS Integration Platform

CGS Integration Platform (CiVision Gemeentelijke Servicebus) — central ESB routing 220 services between 55 municipal applications and national registries.

#### Landelijke Voorzieningen

Landelijke Voorzieningen — national systems and registries. Includes BRP/GBA (GWS), KVK/NHR, and financial systems (FIN).

## Views

### CGS Service Landscape — Top 20 Applicaties

**Elements in this view:**

- Burgerzaken (Grouping)
- Zaakgericht Werken (Grouping)
- Sociaal Domein (Grouping)
- Belastingen en Middelen (Grouping)
- Geo en Ruimte (Grouping)
- Portaal en Integratie (Grouping)
- CGS Integration Platform (Grouping)
- Landelijke Voorzieningen (Grouping)
- CGS (Application Component)
- StUF Services (Application Service)
- Query Services (Application Service)
- BRP/GBA Services (Application Service)
- Zaak Services (Application Service)
- KVK/NHR Services (Application Service)
- Integration Services (Application Service)
- iBurgerzaken (Application Component)
- CIPERS (Application Component)
- CZA (Application Component)
- WebNext (Application Component)
- Corsa (Application Component)
- Alfresco (Application Component)
- CWIZ (Application Component)
- iSamenleving (Application Component)
- CMO (Application Component)
- CBB (Application Component)
- CIN (Application Component)
- CMD (Application Component)
- CBR (Application Component)
- CGA (Application Component)
- CKD (Application Component)
- FrontOffice (Application Component)
- CPT (Application Component)
- CMG (Application Component)
- CIR (Application Component)
- CML (Application Component)
- GWS (Application Component)
- \[External\] NHR (Application Component)
- \[External\] KVK (Application Component)
- FIN (Application Component)

---
*Generated from ArchiMate model: CGS Service Landscape*