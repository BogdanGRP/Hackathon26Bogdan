-- ============================================================================
-- CGS Flow Analysis Queries
-- Purpose: Extract relationship data to create human-understandable flow diagrams
-- Generated: 2026-05-08
-- ============================================================================

-- These queries extract the key flows through the CGS system based on the
-- database schema relationships. Each query represents a different flow path
-- that can be visualized as a diagram.

-- ============================================================================
-- FLOW 1: Service Authorization Flow
-- Shows: Which applications can use which services
-- ArchiMate: Application (consumer) --[Association]--> ServiceDefinition --[Serving]--> Application (provider)
-- ============================================================================

-- Query 1.1: All authorized service usage relationships
SELECT 
    consumer_app.name AS consumer_application,
    consumer_app.description AS consumer_desc,
    svc.name AS service_name,
    svc.description AS service_description,
    svc.handling AS service_handling,
    svc.status AS service_status,
    COUNT(*) OVER (PARTITION BY consumer_app.id) AS services_used_by_consumer,
    COUNT(*) OVER (PARTITION BY svc.id) AS consumers_of_service
FROM igp_ontwikkel_cgs_owner.serviceusage su
JOIN igp_ontwikkel_cgs_owner.application consumer_app ON su.application_id = consumer_app.id
JOIN igp_ontwikkel_cgs_owner.servicedefinition svc ON su.servicedefinition_id = svc.id
WHERE svc.status = 'ACTIVE'
ORDER BY consumer_app.name, svc.name;

-- Query 1.2: Application integration landscape (aggregated)
SELECT 
    consumer_app.name AS application,
    COUNT(DISTINCT svc.id) AS services_used,
    COUNT(DISTINCT CASE WHEN svc.handling = 'SYN' THEN svc.id END) AS synchronous_services,
    COUNT(DISTINCT CASE WHEN svc.handling = 'ASYN' THEN svc.id END) AS asynchronous_services,
    STRING_AGG(DISTINCT svc.name, ', ' ORDER BY svc.name) AS service_list
FROM igp_ontwikkel_cgs_owner.serviceusage su
JOIN igp_ontwikkel_cgs_owner.application consumer_app ON su.application_id = consumer_app.id
JOIN igp_ontwikkel_cgs_owner.servicedefinition svc ON su.servicedefinition_id = svc.id
WHERE svc.status = 'ACTIVE'
GROUP BY consumer_app.name
ORDER BY services_used DESC;


-- ============================================================================
-- FLOW 2: Service Implementation Flow
-- Shows: How services are implemented through adapters and message definitions
-- ArchiMate: ServiceDefinition --[Composition]--> ServiceComponentRelation --[Realization]--> AdapterDefinition
--            ServiceComponentRelation --[Flow]--> MessageDefinition (request/response/fault)
-- ============================================================================

-- Query 2.1: Service to adapter implementation mapping
SELECT 
    svc.name AS service_name,
    svc.description AS service_description,
    svc.handling AS service_handling,
    adapter.name AS adapter_name,
    adapter.adaptertype AS adapter_type,
    adapter.direction AS adapter_direction,
    orch.name AS orchestration_name,
    msg_req.messagekey AS request_message,
    msg_req.namespace AS request_namespace,
    msg_resp.messagekey AS response_message,
    msg_fault.messagekey AS fault_message
FROM igp_ontwikkel_cgs_owner.servicedefinition svc
JOIN igp_ontwikkel_cgs_owner.servicecomponentrelation scr ON svc.id = scr.servicedefinition_id
JOIN igp_ontwikkel_cgs_owner.adapterdefinition adapter ON scr.adapterdefinition_id = adapter.id
LEFT JOIN igp_ontwikkel_cgs_owner.orchestrationdefinition orch ON scr.orchestrationdefinition_id = orch.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_req ON scr.messagedefinitionrequest_id = msg_req.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_resp ON scr.messagedefinitionresponse_id = msg_resp.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_fault ON scr.messagedefinitionfault_id = msg_fault.id
WHERE svc.status = 'ACTIVE'
ORDER BY svc.name;

-- Query 2.2: Adapter usage summary
SELECT 
    adapter.name AS adapter_name,
    adapter.adaptertype AS adapter_type,
    adapter.direction AS direction,
    COUNT(DISTINCT svc.id) AS services_implemented,
    STRING_AGG(DISTINCT svc.name, ', ' ORDER BY svc.name) AS services_list
FROM igp_ontwikkel_cgs_owner.adapterdefinition adapter
JOIN igp_ontwikkel_cgs_owner.servicecomponentrelation scr ON adapter.id = scr.adapterdefinition_id
JOIN igp_ontwikkel_cgs_owner.servicedefinition svc ON scr.servicedefinition_id = svc.id
WHERE svc.status = 'ACTIVE'
GROUP BY adapter.name, adapter.adaptertype, adapter.direction
ORDER BY services_implemented DESC;


-- ============================================================================
-- FLOW 3: Service Routing Flow
-- Shows: How services are routed to specific endpoints with transformations
-- ArchiMate: ServiceDefinition --[Flow]--> ChannelDefinition --[Flow]--> AdapterEndpoint --[Serving]--> Application
--            ChannelDefinition --[Access]--> TransformationDefinition (request/response)
-- ============================================================================

-- Query 3.1: Complete routing configuration
SELECT 
    svc.name AS service_name,
    channel.description AS channel_description,
    channel.active AS channel_active,
    provider_app.name AS provider_application,
    endpoint.name AS adapter_endpoint,
    adapter.name AS adapter_type,
    filter_msg.messagekey AS filter_message,
    channel.filterxpath AS filter_xpath,
    req_trans_orig.messagekey AS request_transform_from,
    req_trans_target.messagekey AS request_transform_to,
    resp_trans_orig.messagekey AS response_transform_from,
    resp_trans_target.messagekey AS response_transform_to
FROM igp_ontwikkel_cgs_owner.channeldefinition channel
JOIN igp_ontwikkel_cgs_owner.servicedefinition svc ON channel.servicedefinition_id = svc.id
JOIN igp_ontwikkel_cgs_owner.application provider_app ON channel.filterprovidingapplication_id = provider_app.id
LEFT JOIN igp_ontwikkel_cgs_owner.adapterendpoint endpoint ON channel.adapterendpoint_id = endpoint.id
LEFT JOIN igp_ontwikkel_cgs_owner.adapterdefinition adapter ON endpoint.adapterdefinition_id = adapter.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition filter_msg ON channel.filtermessagedefinition_id = filter_msg.id
LEFT JOIN igp_ontwikkel_cgs_owner.transformationdefinition req_trans ON channel.requesttransformation_id = req_trans.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition req_trans_orig ON req_trans.messagedefinitionoriginal_id = req_trans_orig.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition req_trans_target ON req_trans.messagedefinitiontarget_id = req_trans_target.id
LEFT JOIN igp_ontwikkel_cgs_owner.transformationdefinition resp_trans ON channel.responsetransformation_id = resp_trans.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition resp_trans_orig ON resp_trans.messagedefinitionoriginal_id = resp_trans_orig.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition resp_trans_target ON resp_trans.messagedefinitiontarget_id = resp_trans_target.id
WHERE channel.active = true
ORDER BY svc.name, provider_app.name;

-- Query 3.2: Endpoint deployment summary
SELECT 
    provider_app.name AS provider_application,
    endpoint.name AS endpoint_name,
    endpoint.description AS endpoint_description,
    adapter.name AS adapter_type,
    adapter.adaptertype AS adapter_protocol,
    COUNT(DISTINCT channel.servicedefinition_id) AS services_routed,
    COUNT(DISTINCT channel.id) AS active_channels
FROM igp_ontwikkel_cgs_owner.adapterendpoint endpoint
JOIN igp_ontwikkel_cgs_owner.application provider_app ON endpoint.applicationalias_id = provider_app.id
JOIN igp_ontwikkel_cgs_owner.adapterdefinition adapter ON endpoint.adapterdefinition_id = adapter.id
LEFT JOIN igp_ontwikkel_cgs_owner.channeldefinition channel ON endpoint.id = channel.adapterendpoint_id AND channel.active = true
GROUP BY provider_app.name, endpoint.name, endpoint.description, adapter.name, adapter.adaptertype
ORDER BY services_routed DESC;


-- ============================================================================
-- FLOW 4: Message Transformation Flow
-- Shows: How messages are transformed between formats
-- ArchiMate: MessageDefinition (source) --[Flow]--> TransformationDefinition --[Flow]--> MessageDefinition (target)
--            TransformationDefinition --[Access]--> XSLTContent
-- ============================================================================

-- Query 4.1: All message transformations with XSLT details
SELECT 
    trans.id AS transformation_id,
    msg_original.messagekey AS source_message,
    msg_original.namespace AS source_namespace,
    msg_original.description AS source_description,
    msg_target.messagekey AS target_message,
    msg_target.namespace AS target_namespace,
    msg_target.description AS target_description,
    xslt.description AS xslt_description,
    LENGTH(xslt.content) AS xslt_content_size,
    -- Find which channels use this transformation
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition 
     WHERE requesttransformation_id = trans.id) AS used_in_request_channels,
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition 
     WHERE responsetransformation_id = trans.id) AS used_in_response_channels
FROM igp_ontwikkel_cgs_owner.transformationdefinition trans
JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_original ON trans.messagedefinitionoriginal_id = msg_original.id
JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_target ON trans.messagedefinitiontarget_id = msg_target.id
LEFT JOIN igp_ontwikkel_cgs_owner.xsltcontent xslt ON trans.content_id = xslt.id
ORDER BY trans.id;

-- Query 4.2: Message definition usage analysis
SELECT 
    msg.messagekey,
    msg.namespace,
    msg.description,
    msg.validationactive,
    -- Count relationships
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.servicecomponentrelation 
     WHERE messagedefinitionrequest_id = msg.id) AS used_as_request,
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.servicecomponentrelation 
     WHERE messagedefinitionresponse_id = msg.id) AS used_as_response,
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.servicecomponentrelation 
     WHERE messagedefinitionfault_id = msg.id) AS used_as_fault,
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.transformationdefinition 
     WHERE messagedefinitionoriginal_id = msg.id) AS used_as_transform_source,
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.transformationdefinition 
     WHERE messagedefinitiontarget_id = msg.id) AS used_as_transform_target,
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition 
     WHERE filtermessagedefinition_id = msg.id) AS used_as_filter
FROM igp_ontwikkel_cgs_owner.messagedefinition msg
ORDER BY 
    (used_as_request + used_as_response + used_as_fault + 
     used_as_transform_source + used_as_transform_target + used_as_filter) DESC;


-- ============================================================================
-- FLOW 5: Runtime Message Flow (from logs)
-- Shows: Actual message flows captured in production logs
-- ArchiMate: Application (consumer) --[Flow]--> ServiceDefinition --[Flow]--> Application (provider)
--            LogServiceRequest --[Composition]--> LogRoute --[Composition]--> LogAction
-- ============================================================================

-- Query 5.1: Recent service request flows
SELECT 
    lsr.id AS request_id,
    lsr.requesttimestamp,
    lsr.responsetimestamp,
    lsr.status,
    lsr.erroroccurred,
    lsr.consumer AS consumer_application,
    lsr.servicename AS service_called,
    lsr.provider AS provider_application,
    lsr.servicehandling AS handling_type,
    lsr.responseisfault AS is_fault,
    -- Calculate duration
    EXTRACT(EPOCH FROM (lsr.responsetimestamp - lsr.requesttimestamp)) * 1000 AS duration_ms,
    -- Count routes taken
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.logroute 
     WHERE logservicerequest_id = lsr.id) AS route_count
FROM igp_ontwikkel_cgs_owner.logservicerequest lsr
WHERE lsr.requesttimestamp >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY lsr.requesttimestamp DESC
LIMIT 100;

-- Query 5.2: Service call frequency and performance
SELECT 
    lsr.servicename AS service_name,
    lsr.consumer AS consumer_application,
    lsr.provider AS provider_application,
    COUNT(*) AS call_count,
    COUNT(CASE WHEN lsr.erroroccurred THEN 1 END) AS error_count,
    ROUND(COUNT(CASE WHEN lsr.erroroccurred THEN 1 END)::numeric / COUNT(*) * 100, 2) AS error_rate_pct,
    ROUND(AVG(EXTRACT(EPOCH FROM (lsr.responsetimestamp - lsr.requesttimestamp)) * 1000), 2) AS avg_duration_ms,
    ROUND(MIN(EXTRACT(EPOCH FROM (lsr.responsetimestamp - lsr.requesttimestamp)) * 1000), 2) AS min_duration_ms,
    ROUND(MAX(EXTRACT(EPOCH FROM (lsr.responsetimestamp - lsr.requesttimestamp)) * 1000), 2) AS max_duration_ms
FROM igp_ontwikkel_cgs_owner.logservicerequest lsr
WHERE lsr.requesttimestamp >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY lsr.servicename, lsr.consumer, lsr.provider
HAVING COUNT(*) >= 5  -- Only show flows with at least 5 calls
ORDER BY call_count DESC;

-- Query 5.3: Multi-hop routing flows
SELECT 
    lsr.id AS request_id,
    lsr.servicename AS service_name,
    lsr.consumer AS initial_consumer,
    lr.provider AS route_provider,
    lr.outgoingcomponenttype AS component_type,
    lr.outgoingcomponent AS component_name,
    lr.adapterendpointname AS endpoint_used,
    lr.requesttimestamp AS route_start,
    lr.responsetimestamp AS route_end,
    EXTRACT(EPOCH FROM (lr.responsetimestamp - lr.requesttimestamp)) * 1000 AS route_duration_ms,
    lr.status AS route_status,
    lr.erroroccurred AS route_error,
    lr.requesttransformationname AS request_transform,
    lr.responsetransformationname AS response_transform
FROM igp_ontwikkel_cgs_owner.logservicerequest lsr
JOIN igp_ontwikkel_cgs_owner.logroute lr ON lsr.id = lr.logservicerequest_id
WHERE lsr.requesttimestamp >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY lsr.requesttimestamp DESC, lr.requesttimestamp ASC
LIMIT 200;


-- ============================================================================
-- FLOW 6: Endpoint Configuration Flow
-- Shows: How endpoints are configured with protocols, certificates, and settings
-- ArchiMate: AdapterEndpoint --[Composition]--> EndpointConfiguration
--            EndpointConfiguration --[Association]--> Certificate
-- ============================================================================

-- Query 6.1: Endpoint configuration details
SELECT 
    provider_app.name AS provider_application,
    endpoint.name AS endpoint_name,
    adapter.name AS adapter_type,
    cfg.endpointtype AS protocol_type,
    cfg.configuration AS config_name,
    cfg.url AS endpoint_url,
    cfg.username AS auth_username,
    cfg.soapversion AS soap_version,
    cfg.enablewsaddressing AS ws_addressing,
    cfg.enablewssecurity AS ws_security,
    cert_tls.canonicalname AS tls_certificate_cn,
    cert_signing.canonicalname AS signing_certificate_cn,
    cfg.system AS mq_system,
    cfg.manager AS mq_manager,
    cfg.channel AS mq_channel
FROM igp_ontwikkel_cgs_owner.endpointconfiguration cfg
JOIN igp_ontwikkel_cgs_owner.adapterendpoint endpoint ON cfg.adapterendpoint_id = endpoint.id
JOIN igp_ontwikkel_cgs_owner.application provider_app ON endpoint.applicationalias_id = provider_app.id
JOIN igp_ontwikkel_cgs_owner.adapterdefinition adapter ON endpoint.adapterdefinition_id = adapter.id
LEFT JOIN igp_ontwikkel_cgs_owner.certificate cert_tls ON cfg.certificate_id = cert_tls.id
LEFT JOIN igp_ontwikkel_cgs_owner.certificate cert_signing ON cfg.signingcertificate_id = cert_signing.id
ORDER BY provider_app.name, endpoint.name, cfg.configuration;

-- Query 6.2: Protocol distribution summary
SELECT 
    cfg.endpointtype AS protocol_type,
    COUNT(DISTINCT cfg.adapterendpoint_id) AS endpoint_count,
    COUNT(*) AS configuration_count,
    COUNT(CASE WHEN cfg.enablewssecurity THEN 1 END) AS ws_security_enabled,
    COUNT(CASE WHEN cfg.certificate_id IS NOT NULL THEN 1 END) AS tls_configured
FROM igp_ontwikkel_cgs_owner.endpointconfiguration cfg
GROUP BY cfg.endpointtype
ORDER BY endpoint_count DESC;


-- ============================================================================
-- FLOW 7: CMIS Document Management Flow
-- Shows: How document management integrates with the service bus
-- ArchiMate: CMISRepository --[Serving]--> AdapterEndpoint
--            CMISPropertyMapping --[Flow]--> CMISConsumerProperty/CMISProviderProperty
-- ============================================================================

-- Query 7.1: CMIS repository configuration
SELECT 
    repo.name AS repository_name,
    repo.repositoryid AS repository_id,
    repo.vendorname AS vendor_name,
    repo.productname AS product_name,
    repo.productversion AS product_version,
    repo.cmiscompliant AS cmis_compliant,
    provider_cfg.name AS provider_config_name,
    provider_cfg.vendortype AS provider_type,
    endpoint.name AS adapter_endpoint,
    provider_app.name AS provider_application,
    -- Count property mappings
    (SELECT COUNT(*) FROM igp_ontwikkel_cgs_owner.cmispropertymapping 
     WHERE cmisrepository_id = repo.id) AS property_mappings_count
FROM igp_ontwikkel_cgs_owner.cmisrepository repo
JOIN igp_ontwikkel_cgs_owner.cmisproviderconfiguration provider_cfg ON repo.cmisproviderconfiguration_id = provider_cfg.id
JOIN igp_ontwikkel_cgs_owner.adapterendpoint endpoint ON repo.adapterendpoint_id = endpoint.id
JOIN igp_ontwikkel_cgs_owner.application provider_app ON endpoint.applicationalias_id = provider_app.id
ORDER BY repo.name;

-- Query 7.2: CMIS property mapping flow
SELECT 
    repo.name AS repository_name,
    consumer_prop.name AS consumer_property,
    consumer_prop.datatype AS consumer_datatype,
    consumer_prop.levelfield AS consumer_level,
    provider_prop_in.name AS provider_property_in,
    provider_prop_in.datatype AS provider_datatype_in,
    provider_prop_out.name AS provider_property_out,
    provider_prop_out.datatype AS provider_datatype_out
FROM igp_ontwikkel_cgs_owner.cmispropertymapping mapping
JOIN igp_ontwikkel_cgs_owner.cmisrepository repo ON mapping.cmisrepository_id = repo.id
JOIN igp_ontwikkel_cgs_owner.cmisconsumerproperty consumer_prop ON mapping.cmisconsumerproperty_id = consumer_prop.id
JOIN igp_ontwikkel_cgs_owner.cmisproviderproperty provider_prop_in ON mapping.cmisproviderproperty_in_id = provider_prop_in.id
JOIN igp_ontwikkel_cgs_owner.cmisproviderproperty provider_prop_out ON mapping.cmisproviderproperty_out_id = provider_prop_out.id
ORDER BY repo.name, consumer_prop.name;


-- ============================================================================
-- FLOW 8: Hub Table Relationship Summary
-- Shows: Central hub tables and their connection density
-- Purpose: Identify the most connected tables for diagram focus
-- ============================================================================

-- Query 8.1: Table relationship density analysis
WITH table_relationships AS (
    SELECT 'application' AS table_name, 
           COUNT(*) AS outgoing_fk FROM igp_ontwikkel_cgs_owner.serviceusage GROUP BY 1
    UNION ALL
    SELECT 'application', COUNT(*) FROM igp_ontwikkel_cgs_owner.adapterendpoint GROUP BY 1
    UNION ALL
    SELECT 'application', COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition GROUP BY 1
    UNION ALL
    SELECT 'servicedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.serviceusage GROUP BY 1
    UNION ALL
    SELECT 'servicedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.servicecomponentrelation GROUP BY 1
    UNION ALL
    SELECT 'servicedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition GROUP BY 1
    UNION ALL
    SELECT 'messagedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.servicecomponentrelation WHERE messagedefinitionrequest_id IS NOT NULL GROUP BY 1
    UNION ALL
    SELECT 'messagedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition WHERE filtermessagedefinition_id IS NOT NULL GROUP BY 1
    UNION ALL
    SELECT 'messagedefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.transformationdefinition GROUP BY 1
    UNION ALL
    SELECT 'adapterendpoint', COUNT(*) FROM igp_ontwikkel_cgs_owner.channeldefinition GROUP BY 1
    UNION ALL
    SELECT 'adapterendpoint', COUNT(*) FROM igp_ontwikkel_cgs_owner.endpointconfiguration GROUP BY 1
    UNION ALL
    SELECT 'adapterdefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.adapterendpoint GROUP BY 1
    UNION ALL
    SELECT 'adapterdefinition', COUNT(*) FROM igp_ontwikkel_cgs_owner.servicecomponentrelation GROUP BY 1
    UNION ALL
    SELECT 'logmessage', COUNT(*) FROM igp_ontwikkel_cgs_owner.logservicerequest WHERE request_id IS NOT NULL GROUP BY 1
    UNION ALL
    SELECT 'logmessage', COUNT(*) FROM igp_ontwikkel_cgs_owner.logroute WHERE transformedrequest_id IS NOT NULL GROUP BY 1
)
SELECT 
    table_name,
    SUM(outgoing_fk) AS total_relationships,
    COUNT(*) AS relationship_types
FROM table_relationships
GROUP BY table_name
ORDER BY total_relationships DESC;


-- ============================================================================
-- FLOW 9: Complete End-to-End Flow Query
-- Shows: Full flow from consumer authorization through routing to logging
-- Purpose: Generate a single comprehensive flow diagram
-- ============================================================================

-- Query 9.1: Complete service flow with all hops
SELECT 
    'AUTHORIZATION' AS flow_step,
    1 AS step_order,
    consumer_app.name AS source_entity,
    'Application' AS source_type,
    svc.name AS target_entity,
    'ServiceDefinition' AS target_type,
    'Association' AS relationship_type,
    'can use' AS relationship_label,
    NULL AS detail
FROM igp_ontwikkel_cgs_owner.serviceusage su
JOIN igp_ontwikkel_cgs_owner.application consumer_app ON su.application_id = consumer_app.id
JOIN igp_ontwikkel_cgs_owner.servicedefinition svc ON su.servicedefinition_id = svc.id
WHERE svc.status = 'ACTIVE'

UNION ALL

SELECT 
    'IMPLEMENTATION' AS flow_step,
    2 AS step_order,
    svc.name AS source_entity,
    'ServiceDefinition' AS source_type,
    adapter.name AS target_entity,
    'AdapterDefinition' AS target_type,
    'Realization' AS relationship_type,
    'implemented by' AS relationship_label,
    msg_req.messagekey AS detail
FROM igp_ontwikkel_cgs_owner.servicedefinition svc
JOIN igp_ontwikkel_cgs_owner.servicecomponentrelation scr ON svc.id = scr.servicedefinition_id
JOIN igp_ontwikkel_cgs_owner.adapterdefinition adapter ON scr.adapterdefinition_id = adapter.id
LEFT JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_req ON scr.messagedefinitionrequest_id = msg_req.id
WHERE svc.status = 'ACTIVE'

UNION ALL

SELECT 
    'ROUTING' AS flow_step,
    3 AS step_order,
    svc.name AS source_entity,
    'ServiceDefinition' AS source_type,
    endpoint.name AS target_entity,
    'AdapterEndpoint' AS target_type,
    'Flow' AS relationship_type,
    'routed to' AS relationship_label,
    provider_app.name AS detail
FROM igp_ontwikkel_cgs_owner.channeldefinition channel
JOIN igp_ontwikkel_cgs_owner.servicedefinition svc ON channel.servicedefinition_id = svc.id
JOIN igp_ontwikkel_cgs_owner.adapterendpoint endpoint ON channel.adapterendpoint_id = endpoint.id
JOIN igp_ontwikkel_cgs_owner.application provider_app ON channel.filterprovidingapplication_id = provider_app.id
WHERE channel.active = true

UNION ALL

SELECT 
    'TRANSFORMATION' AS flow_step,
    4 AS step_order,
    msg_orig.messagekey AS source_entity,
    'MessageDefinition' AS source_type,
    msg_target.messagekey AS target_entity,
    'MessageDefinition' AS target_type,
    'Flow' AS relationship_type,
    'transformed to' AS relationship_label,
    'XSLT' AS detail
FROM igp_ontwikkel_cgs_owner.transformationdefinition trans
JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_orig ON trans.messagedefinitionoriginal_id = msg_orig.id
JOIN igp_ontwikkel_cgs_owner.messagedefinition msg_target ON trans.messagedefinitiontarget_id = msg_target.id

UNION ALL

SELECT 
    'ENDPOINT_SERVING' AS flow_step,
    5 AS step_order,
    endpoint.name AS source_entity,
    'AdapterEndpoint' AS source_type,
    provider_app.name AS target_entity,
    'Application' AS target_type,
    'Serving' AS relationship_type,
    'connects to' AS relationship_label,
    adapter.adaptertype AS detail
FROM igp_ontwikkel_cgs_owner.adapterendpoint endpoint
JOIN igp_ontwikkel_cgs_owner.application provider_app ON endpoint.applicationalias_id = provider_app.id
JOIN igp_ontwikkel_cgs_owner.adapterdefinition adapter ON endpoint.adapterdefinition_id = adapter.id

ORDER BY step_order, source_entity, target_entity;


-- ============================================================================
-- END OF QUERIES
-- ============================================================================

-- Usage Notes:
-- 1. Each query can be executed independently to explore different flow aspects
-- 2. Results can be exported to CSV and visualized using:
--    - PlantUML (sequence/activity diagrams)
--    - ArchiMate (using the relationship_type column values)
--    - Graphviz (network diagrams)
--    - D3.js/Mermaid (interactive web visualizations)
-- 3. The "Complete End-to-End Flow Query" (9.1) provides a single unified view
--    that can be directly imported into diagramming tools
-- 4. All queries follow the relationship conventions defined in:
--    /openspec/specs/relationship-type-conventions/spec.md
