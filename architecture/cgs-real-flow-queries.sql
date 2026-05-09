-- ============================================================================
-- CGS Flow Discovery Queries — Based on Real Database Data
-- Database: igp_ontwikkel / schema: igp_ontwikkel_cgs_owner
-- Generated: 2026-05-08 (Hackathon26)
-- ============================================================================

-- =============================================================================
-- FLOW 1: Complete End-to-End Message Path
-- Consumer → Authorization → Service → Wiring → Adapter → Endpoint → Provider
-- =============================================================================
SELECT 
  consumer_app.name AS consumer,
  sd.name AS service_name,
  sd.handling || '/' || sd.qualityofservice AS mode,
  ad.name AS adapter_name,
  ad.adaptertype AS protocol,
  ad.direction AS direction,
  ae.name AS endpoint_name,
  provider_app.name AS provider
FROM igp_ontwikkel_cgs_owner.serviceusage su
JOIN igp_ontwikkel_cgs_owner.application consumer_app ON su.application_id = consumer_app.id
JOIN igp_ontwikkel_cgs_owner.servicedefinition sd ON su.servicedefinition_id = sd.id
JOIN igp_ontwikkel_cgs_owner.servicecomponentrelation scr ON sd.id = scr.servicedefinition_id
JOIN igp_ontwikkel_cgs_owner.adapterdefinition ad ON scr.adapterdefinition_id = ad.id
LEFT JOIN igp_ontwikkel_cgs_owner.channeldefinition cd ON sd.id = cd.servicedefinition_id AND cd.active = true
LEFT JOIN igp_ontwikkel_cgs_owner.adapterendpoint ae ON cd.adapterendpoint_id = ae.id
LEFT JOIN igp_ontwikkel_cgs_owner.application provider_app ON ae.applicationalias_id = provider_app.id
WHERE sd.status = 'ACTIVE'
ORDER BY consumer_app.name, sd.name;

-- =============================================================================
-- FLOW 2: Service Categories by Naming Pattern
-- Groups 220 active services into functional domains
-- =============================================================================
SELECT 
  CASE 
    WHEN name ILIKE '%StUF%' AND name ILIKE '%BG%' THEN 'StUF-BG (Burgerzaken)'
    WHEN name ILIKE '%StUF%' AND name ILIKE '%ZKN%' THEN 'StUF-ZKN (Zaakgericht)'
    WHEN name ILIKE '%StUF%' AND name ILIKE '%WOZ%' THEN 'StUF-WOZ (Waardering)'
    WHEN name ILIKE '%StUF%' AND name ILIKE '%EF%' THEN 'StUF-EF (e-Formulieren)'
    WHEN name ILIKE '%StUF%' AND name ILIKE '%BZ%' THEN 'StUF-BZ (Belastingen)'
    WHEN name ILIKE '%StUF%' THEN 'StUF (Other)'
    WHEN name ILIKE '%CMIS%' THEN 'CMIS (Document Mgmt)'
    WHEN name ILIKE '%Ftp%' OR name ILIKE '%File%' THEN 'File Transfer'
    WHEN name ILIKE '%Test%' THEN 'Test Services'
    WHEN name ILIKE '%Digilevering%' OR name ILIKE '%Digikoppeling%' THEN 'Digikoppeling'
    WHEN name ILIKE '%Berichtenbox%' THEN 'Berichtenbox'
    WHEN name ILIKE '%BRP%' OR name ILIKE '%GBA%' THEN 'BRP/GBA (Personen)'
    WHEN name ILIKE '%KVK%' OR name ILIKE '%NHR%' THEN 'KVK/NHR (Bedrijven)'
    ELSE 'Domain Services'
  END as category,
  COUNT(*) as service_count,
  STRING_AGG(name, ', ' ORDER BY name) as services
FROM igp_ontwikkel_cgs_owner.servicedefinition
WHERE status = 'ACTIVE'
GROUP BY category
ORDER BY service_count DESC;

-- =============================================================================
-- FLOW 3: Multi-Channel Routing (Fan-out services)
-- Services with multiple channels = broadcast to multiple providers
-- =============================================================================
SELECT 
  sd.name as service_name,
  sd.handling as mode,
  COUNT(DISTINCT cd.id) as channel_count,
  COUNT(DISTINCT cd.adapterendpoint_id) as distinct_endpoints,
  COUNT(DISTINCT provider_app.name) as distinct_providers,
  STRING_AGG(DISTINCT provider_app.name, ', ' ORDER BY provider_app.name) as providers
FROM igp_ontwikkel_cgs_owner.servicedefinition sd
JOIN igp_ontwikkel_cgs_owner.channeldefinition cd ON sd.id = cd.servicedefinition_id
LEFT JOIN igp_ontwikkel_cgs_owner.adapterendpoint ae ON cd.adapterendpoint_id = ae.id
LEFT JOIN igp_ontwikkel_cgs_owner.application provider_app ON ae.applicationalias_id = provider_app.id
WHERE cd.active = true AND sd.status = 'ACTIVE'
GROUP BY sd.name, sd.handling
ORDER BY channel_count DESC
LIMIT 15;

-- =============================================================================
-- FLOW 4: Top Consumer Applications by Service Usage
-- Who is calling the most services?
-- =============================================================================
SELECT 
  a.name as application,
  COUNT(DISTINCT su.servicedefinition_id) as service_count,
  STRING_AGG(DISTINCT sd.name, ', ' ORDER BY sd.name) as services
FROM igp_ontwikkel_cgs_owner.application a
JOIN igp_ontwikkel_cgs_owner.serviceusage su ON a.id = su.application_id
JOIN igp_ontwikkel_cgs_owner.servicedefinition sd ON su.servicedefinition_id = sd.id
WHERE sd.status = 'ACTIVE'
GROUP BY a.name
ORDER BY service_count DESC
LIMIT 20;

-- =============================================================================
-- FLOW 5: Adapter Protocol Distribution
-- What protocols are used and how (IN vs OUT)?
-- =============================================================================
SELECT 
  ad.adaptertype as protocol,
  ad.direction,
  COUNT(*) as adapter_count,
  STRING_AGG(DISTINCT ad.name, ', ' ORDER BY ad.name) as adapter_names
FROM igp_ontwikkel_cgs_owner.adapterdefinition ad
GROUP BY ad.adaptertype, ad.direction
ORDER BY adapter_count DESC;

-- =============================================================================
-- FLOW 6: Message Format Usage
-- Which message definitions are used most across services?
-- =============================================================================
SELECT 
  md.messagekey,
  md.namespace,
  COUNT(DISTINCT CASE WHEN scr.messagedefinitionrequest_id = md.id THEN scr.id END) as as_request,
  COUNT(DISTINCT CASE WHEN scr.messagedefinitionresponse_id = md.id THEN scr.id END) as as_response,
  COUNT(DISTINCT CASE WHEN scr.messagedefinitionfault_id = md.id THEN scr.id END) as as_fault,
  COUNT(DISTINCT td.id) as in_transformations
FROM igp_ontwikkel_cgs_owner.messagedefinition md
LEFT JOIN igp_ontwikkel_cgs_owner.servicecomponentrelation scr 
  ON md.id IN (scr.messagedefinitionrequest_id, scr.messagedefinitionresponse_id, scr.messagedefinitionfault_id)
LEFT JOIN igp_ontwikkel_cgs_owner.transformationdefinition td 
  ON md.id IN (td.messagedefinitionoriginal_id, td.messagedefinitiontarget_id)
GROUP BY md.messagekey, md.namespace
HAVING COUNT(DISTINCT scr.id) + COUNT(DISTINCT td.id) > 5
ORDER BY (COUNT(DISTINCT scr.id) + COUNT(DISTINCT td.id)) DESC
LIMIT 15;

-- =============================================================================
-- FLOW 7: Production Traffic Patterns (from logs)
-- What consumer→service→provider paths are actually used?
-- =============================================================================
SELECT 
  lsr.consumer, 
  lsr.servicename, 
  lsr.provider,
  lsr.servicehandling,
  lsr.erroroccurred,
  COUNT(*) as call_count
FROM igp_ontwikkel_cgs_owner.logservicerequest lsr
GROUP BY lsr.consumer, lsr.servicename, lsr.provider, lsr.servicehandling, lsr.erroroccurred
ORDER BY call_count DESC
LIMIT 20;

-- =============================================================================
-- FLOW 8: Table Row Counts (Scale Reference)
-- Complete overview of database size
-- =============================================================================
SELECT 'application' as table_name, COUNT(*) as row_count FROM igp_ontwikkel_cgs_owner.application
UNION ALL SELECT 'adapterdefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.adapterdefinition
UNION ALL SELECT 'adapterendpoint', COUNT(*) FROM igp_ontwikkel_cgs_owner.adapterendpoint
UNION ALL SELECT 'endpointconfiguration', COUNT(*) FROM igp_ontwikkel_cgs_owner.endpointconfiguration
UNION ALL SELECT 'servicedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.servicedefinition
UNION ALL SELECT 'serviceusage', COUNT(*) FROM igp_ontwikkel_cgs_owner.serviceusage
UNION ALL SELECT 'servicecomponentrelation', COUNT(*) FROM igp_ontwikkel_cgs_owner.servicecomponentrelation
UNION ALL SELECT 'channeldefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition
UNION ALL SELECT 'messagedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.messagedefinition
UNION ALL SELECT 'transformationdefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.transformationdefinition
UNION ALL SELECT 'orchestrationdefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.orchestrationdefinition
UNION ALL SELECT 'logservicerequest', COUNT(*) FROM igp_ontwikkel_cgs_owner.logservicerequest
UNION ALL SELECT 'logroute', COUNT(*) FROM igp_ontwikkel_cgs_owner.logroute
UNION ALL SELECT 'logaction', COUNT(*) FROM igp_ontwikkel_cgs_owner.logaction
UNION ALL SELECT 'logmessage', COUNT(*) FROM igp_ontwikkel_cgs_owner.logmessage
UNION ALL SELECT 'certificate', COUNT(*) FROM igp_ontwikkel_cgs_owner.certificate
UNION ALL SELECT 'revinfo', COUNT(*) FROM igp_ontwikkel_cgs_owner.revinfo
ORDER BY row_count DESC;

-- =============================================================================
-- FLOW 9: Service Handling Modes (SYN vs ASYN)
-- How many services use synchronous vs asynchronous processing?
-- =============================================================================
SELECT 
  handling,
  qualityofservice,
  status,
  COUNT(*) as service_count
FROM igp_ontwikkel_cgs_owner.servicedefinition
GROUP BY handling, qualityofservice, status
ORDER BY status, service_count DESC;
