## 1. Document Scaffold & Narrative

- [x] 1.1 Create `openspec/specs/cgs-schema-docs.md` with header, generation date, and table of contents skeleton
- [x] 1.2 Write domain narrative section: end-to-end message flow through CGS (application → serviceusage → servicedefinition → channeldefinition → adapterendpoint → endpointconfiguration)

## 2. Document Domain Groups

- [x] 2.1 Document Service Bus Core domain (servicedefinition, channeldefinition, servicecomponentrelation, serviceusage, orchestrationdefinition, orchestrationsetting): table purposes, key column semantics, relationship rationale
- [x] 2.2 Document Application domain (application, applicationopeningperiod, certificate): table purposes, key column semantics, self-reference explanation
- [x] 2.3 Document Adapter/Endpoint domain (adapterdefinition, adapterendpoint, endpointconfiguration, adaptersetting): table purposes, key column semantics, relationship chain
- [x] 2.4 Document Message/Transformation domain (messagedefinition, elementdefinition, transformationdefinition, xsltcontent): table purposes, key column semantics, transformation pipeline
- [x] 2.5 Document Validation domain (validator, validatoraction, validatoractioncfg, messagevalidation, messagevalidationaction, messagevalidationactioncfg): table purposes, junction table explanations
- [x] 2.6 Document CMIS domain (cmisproviderconfiguration, cmisproviderproperty, cmisconsumerproperty, cmisrepository, cmispropertymapping): table purposes, property mapping semantics
- [x] 2.7 Document ebMS Messaging domain (ebmscpa, ebmsmessage, ebmsattachment, ebmssendevent, ebmsmapping): table purposes, CPA/message lifecycle
- [x] 2.8 Document Logging domain (logmessage, logservicerequest, logroute, logaction, logattachment): table purposes, request-route-action hierarchy
- [x] 2.9 Document System & Audit tables (cgssetting, revinfo, all _aud tables): brief purpose, Envers audit pattern explanation

## 3. Finalize

- [x] 3.1 Complete table of contents with anchor links to all domain sections and tables
- [x] 3.2 Review document for completeness: every core table covered, all FK relationships explained
