# Schema: igp_ontwikkel_platform_owner

> Generated: 2026-05-08
> User: hackathon (read-only)
> Database: igp_ontwikkel
> Note: FK constraints are enforced at the DB level. The `FOREIGN KEY` constraints below reflect the 9 constraints confirmed via `information_schema.referential_constraints` on 2026-05-08.

---

## Domain Map

```
DOMAIN MAP — igp_ontwikkel_platform_owner
══════════════════════════════════════════════════════════════════════════════

  ┌─────────────────────────────────────────────────────────────────────┐
  │  IDENTITY & ACCESS                                                  │
  │                                                                     │
  │  usertable          roletable          permissiontable              │
  │  ─────────          ─────────          ───────────────              │
  │  id (PK)            id (PK)            id (PK)                      │
  │  username           application        permissiontype               │
  │  password           name               application                  │
  │  realmtype          description        name / resourcename          │
  │  displayname        usergroups         allowfind/insert/update...   │
  │  emailaddress                                                       │
  │  enabled                 │                      │                   │
  │  expirytime              └──────────┐  ┌────────┘                   │
  │                                     ▼  ▼                            │
  │                          rolepermissionmapping                      │
  │                          ─────────────────────                      │
  │                          id                                         │
  │                          role_id ────────────────▶ roletable        │
  │                          permission_id ──────────▶ permissiontable  │
  │                                                                     │
  │  ldapconfiguration ◀──── roleldapgroupdn                            │
  │  ───────────────────     ───────────────                            │
  │  id (PK)                 id                                         │
  │  name / system / port    role_id ───────────────▶ roletable         │
  │  userbasedn / groupbasedn ldapconfiguration_id ──▶ ldapconfiguration│
  │  usessl / disabled       ldapgroupdn                                │
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │  JOB EXECUTION                                                      │
  │                                                                     │
  │  taskgroupdefinition ◀── taskdefinition ◀── jobexecutionlog ◀── jobactionlog
  │  ─────────────────────   ──────────────     ────────────────     ───────────
  │  id (PK)                 id (PK)            id (PK)              id (PK)
  │  application             application        taskdefinition_id    jobexecutionlog_id
  │  name / description      name               jobuuid / jobname    logtimestamp
  │                          taskgroupdef_id    starttimestamp       action / result
  │                          implementation     endtimestamp         details / stacktrace
  │                          usertask           result / parameters  logpercentagecompleted
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │  AUTO UPDATE (MAU)                                                  │
  │                                                                     │
  │  mauconfiguration    mauplanning ◀──────────── maulogging           │
  │  ──────────────────  ───────────               ──────────           │
  │  id (PK)             id (PK)                   id (PK)              │
  │  performmksbackup    mksversiontoinstall        planning_id ────────▶ mauplanning
  │  performdbbackup     installfrequency           currentversion       │
  │  emailaterror        installweekday             statusmau            │
  │  useinfomauservice   nextplannedinstallation    diskspace*           │
  │  (global defaults)   (the schedule)             (the log of a run)  │
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │  INSTALL / MIGRATION                                                │
  │                                                                     │
  │  databaseinstallhistory   postinstallresult ◀── logrecord           │
  │  ───────────────────────  ─────────────────     ─────────           │
  │  id (PK)                  id (PK)               id (PK)             │
  │  application              application           postinstallresult_id │
  │  applicationversion       name                  forname             │
  │  snapshot                 generationdate        result              │
  │  installstartedtimestamp  importstarttimestamp  inserttimestamp     │
  │  succesfullyinstalled     result                details             │
  │  installerrormessage      numberofentities                          │
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │  STANDALONE CONFIG (no relations)                                   │
  │                                                                     │
  │  platformsetting        organisationconfiguration  tenantconfiguration
  │  mediatype              licensekey                 lastgeneratedid  │
  └─────────────────────────────────────────────────────────────────────┘
```

---

## Cross-cutting Columns

These columns appear on nearly every table and are **technical, not domain concepts**. Exclude from ArchiMate model:

| Column | Purpose |
|---|---|
| `changecounter` | Optimistic locking (ORM-managed) |
| `factorysetting` | Flags rows that ship with the product |

---

## DDL

```sql
-- ============================================================
-- SCHEMA: igp_ontwikkel_platform_owner
-- FK constraints ARE enforced at the DB level.
-- 9 constraints confirmed via information_schema on 2026-05-08.
-- ============================================================

-- ── IDENTITY & ACCESS ────────────────────────────────────────

CREATE TABLE usertable (
    id                  NUMERIC         NOT NULL,
    changecounter       NUMERIC         NOT NULL DEFAULT 1,
    username            VARCHAR(100)    NOT NULL,
    password            VARCHAR(100)    NOT NULL,
    realmtype           VARCHAR(10)     NOT NULL,
    displayname         VARCHAR(100)    NOT NULL,
    emailaddress        VARCHAR(100),
    enabled             BOOLEAN         NOT NULL DEFAULT false,
    expirytime          TIMESTAMP,
    lastlogon           TIMESTAMP,
    PRIMARY KEY (id)
);

CREATE TABLE roletable (
    id                  NUMERIC         NOT NULL,
    changecounter       NUMERIC         NOT NULL DEFAULT 1,
    application         VARCHAR(10)     NOT NULL,
    name                VARCHAR(100)    NOT NULL,
    description         VARCHAR(500)    NOT NULL,
    usergroups          VARCHAR(512),
    factorysetting      BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE permissiontable (
    id                  NUMERIC         NOT NULL,
    changecounter       NUMERIC         NOT NULL DEFAULT 1,
    permissiontype      VARCHAR(15)     NOT NULL,
    application         VARCHAR(10)     NOT NULL,
    name                VARCHAR(50)     NOT NULL,
    resourcename        VARCHAR(100)    NOT NULL,
    allowallactions     BOOLEAN         NOT NULL DEFAULT false,
    allowfind           BOOLEAN         NOT NULL DEFAULT false,
    allowinsert         BOOLEAN         NOT NULL DEFAULT false,
    allowupdate         BOOLEAN         NOT NULL DEFAULT false,
    allowdelete         BOOLEAN         NOT NULL DEFAULT false,
    allowedactions      VARCHAR(1000),
    factorysetting      BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE rolepermissionmapping (
    id                  NUMERIC         NOT NULL,
    changecounter       NUMERIC         NOT NULL DEFAULT 1,
    role_id             NUMERIC         NOT NULL,
    permission_id       NUMERIC         NOT NULL,
    factorysetting      BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id),
    CONSTRAINT fk_rolepermissionmapping_role       FOREIGN KEY (role_id)       REFERENCES roletable (id),
    CONSTRAINT fk_rolepermissionmapping_permission FOREIGN KEY (permission_id) REFERENCES permissiontable (id)
);

CREATE TABLE ldapconfiguration (
    id                          NUMERIC         NOT NULL,
    changecounter               NUMERIC         NOT NULL DEFAULT 1,
    name                        VARCHAR(30)     NOT NULL,
    description                 VARCHAR(250),
    system                      VARCHAR(255)    NOT NULL,
    port                        NUMERIC         NOT NULL,
    username                    VARCHAR(150)    NOT NULL,
    password                    VARCHAR(100)    NOT NULL,
    searchbase                  VARCHAR(250),
    dontusepaging               BOOLEAN         NOT NULL DEFAULT false,
    userbasedn                  VARCHAR(250)    NOT NULL,
    usersubtree                 BOOLEAN         NOT NULL DEFAULT false,
    userobjectclass             VARCHAR(50)     NOT NULL,
    userattributedn             VARCHAR(50)     NOT NULL DEFAULT 'distinguishedName',
    userattributeuserid         VARCHAR(50)     NOT NULL,
    userattributerealname       VARCHAR(50)     NOT NULL,
    userattributeemailaddress   VARCHAR(50)     NOT NULL,
    userattributememberof       VARCHAR(50)     NOT NULL,
    userattributelastlogon      VARCHAR(50),
    groupbasedn                 VARCHAR(250)    NOT NULL,
    groupsubtree                BOOLEAN         NOT NULL DEFAULT false,
    groupobjectclass            VARCHAR(50)     NOT NULL,
    groupattributedn            VARCHAR(50)     NOT NULL,
    groupattributename          VARCHAR(50)     NOT NULL,
    groupattributedescription   VARCHAR(50)     NOT NULL,
    usessl                      BOOLEAN         NOT NULL DEFAULT false,
    disabled                    BOOLEAN         NOT NULL DEFAULT false,
    usepooling                  BOOLEAN         NOT NULL DEFAULT false,
    poolmaxsize                 NUMERIC         NOT NULL,
    poolprefsize                NUMERIC         NOT NULL,
    pooltimeout                 NUMERIC         NOT NULL,
    factorysetting              BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE roleldapgroupdn (
    id                      NUMERIC         NOT NULL,
    changecounter           NUMERIC         NOT NULL DEFAULT 1,
    role_id                 NUMERIC         NOT NULL,
    ldapconfiguration_id    NUMERIC         NOT NULL,
    ldapgroupdn             VARCHAR(500),
    factorysetting          BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id),
    CONSTRAINT fk_roleldapgroupdn_role              FOREIGN KEY (role_id)              REFERENCES roletable (id),
    CONSTRAINT fk_roleldapgroupdn_ldapconfiguration FOREIGN KEY (ldapconfiguration_id) REFERENCES ldapconfiguration (id)
);

-- ── JOB EXECUTION ────────────────────────────────────────────

CREATE TABLE taskgroupdefinition (
    id                  NUMERIC         NOT NULL,
    changecounter       NUMERIC         NOT NULL DEFAULT 1,
    application         VARCHAR(10)     NOT NULL,
    name                VARCHAR(50)     NOT NULL,
    description         VARCHAR(500)    NOT NULL,
    factorysetting      BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE taskdefinition (
    id                      NUMERIC         NOT NULL,
    changecounter           NUMERIC         NOT NULL DEFAULT 1,
    application             VARCHAR(10)     NOT NULL,
    name                    VARCHAR(50)     NOT NULL,
    taskgroupdefinition_id  NUMERIC,
    description             VARCHAR(500)    NOT NULL,
    implementation          VARCHAR(150)    NOT NULL,
    usertask                BOOLEAN         NOT NULL DEFAULT false,
    factorysetting          BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id),
    CONSTRAINT fk_taskdefinition_taskgroupdefinition FOREIGN KEY (taskgroupdefinition_id) REFERENCES taskgroupdefinition (id)
);

CREATE TABLE jobexecutionlog (
    id                      NUMERIC         NOT NULL,
    changecounter           NUMERIC         NOT NULL DEFAULT 1,
    taskdefinition_id       NUMERIC,
    jobuuid                 VARCHAR(36)     NOT NULL,
    jobname                 VARCHAR(50)     NOT NULL,
    parameters              TEXT,
    starttimestamp          TIMESTAMP       NOT NULL,
    endtimestamp            TIMESTAMP,
    result                  VARCHAR(10),
    endpercentagecompleted  NUMERIC,
    details                 TEXT,
    stacktrace              TEXT,
    PRIMARY KEY (id),
    CONSTRAINT fk_jobexecutionlog_taskdefinition FOREIGN KEY (taskdefinition_id) REFERENCES taskdefinition (id)
);

CREATE TABLE jobactionlog (
    id                      NUMERIC         NOT NULL,
    changecounter           NUMERIC         NOT NULL DEFAULT 1,
    jobexecutionlog_id      NUMERIC         NOT NULL,
    logtimestamp            TIMESTAMP       NOT NULL,
    logpercentagecompleted  NUMERIC,
    action                  VARCHAR(75),
    actionexecutedfor       VARCHAR(50),
    result                  VARCHAR(10),
    details                 TEXT,
    cgsreference            VARCHAR(20),
    stacktrace              TEXT,
    PRIMARY KEY (id),
    CONSTRAINT fk_jobactionlog_jobexecutionlog FOREIGN KEY (jobexecutionlog_id) REFERENCES jobexecutionlog (id)
);

-- ── AUTO UPDATE (MAU) ─────────────────────────────────────────

CREATE TABLE mauconfiguration (
    id                          NUMERIC         NOT NULL,
    changecounter               NUMERIC         NOT NULL DEFAULT 1,
    performmksbackup            BOOLEAN         NOT NULL DEFAULT false,
    performdbbackup             BOOLEAN         NOT NULL DEFAULT false,
    locationdbbackup            VARCHAR(255),
    performmksbackupna          BOOLEAN         NOT NULL DEFAULT false,
    performdbbackupna           BOOLEAN         NOT NULL DEFAULT false,
    bijfoutautomatischerestore  BOOLEAN         NOT NULL DEFAULT false,
    emailaterror                VARCHAR(100),
    emailatcomplete             VARCHAR(100),
    emailatnewversionorpatch    VARCHAR(100),
    removeobsoleteinstallers    BOOLEAN         NOT NULL DEFAULT false,
    neededdiskspacesystemdrive  NUMERIC,
    neededdiskspacemks          NUMERIC,
    neededdiskspacedbbackup     NUMERIC,
    lastemailedavailableversion VARCHAR(40),
    useinfomauservice           BOOLEAN         NOT NULL DEFAULT false,
    usedownloadservice          BOOLEAN         NOT NULL DEFAULT false,
    intervalnewversioncheck     NUMERIC,
    PRIMARY KEY (id)
);

CREATE TABLE mauplanning (
    id                          NUMERIC         NOT NULL,
    changecounter               NUMERIC         NOT NULL DEFAULT 1,
    mksversiontoinstall         VARCHAR(30)     NOT NULL,
    includepatches              BOOLEAN         NOT NULL DEFAULT false,
    versionofpatchtoinstall     VARCHAR(1),
    installversiontemplate      NUMERIC,
    installfrequency            VARCHAR(1)      NOT NULL,
    installweekday              NUMERIC,
    installdayoccurence         NUMERIC,
    nextplannedinstallation     TIMESTAMP       NOT NULL,
    usernameplannedby           VARCHAR(150)    NOT NULL,
    statusmaulastrun            VARCHAR(10),
    active                      BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE maulogging (
    id                              NUMERIC         NOT NULL,
    changecounter                   NUMERIC         NOT NULL DEFAULT 1,
    planning_id                     NUMERIC,
    currentversion                  VARCHAR(30)     NOT NULL,
    mksversiontoinstall             VARCHAR(30)     NOT NULL,
    includepatches                  BOOLEAN         NOT NULL DEFAULT false,
    versionofpatchtoinstall         VARCHAR(1),
    plannedinstallationtimestamp    TIMESTAMP       NOT NULL,
    startinstallationtimestamp      TIMESTAMP,
    endinstallationtimestamp        TIMESTAMP,
    usernameplannedby               VARCHAR(150)    NOT NULL,
    performmksbackup                BOOLEAN         NOT NULL DEFAULT false,
    performdbbackup                 BOOLEAN         NOT NULL DEFAULT false,
    locationdbbackup                VARCHAR(255),
    performmksbackupna              BOOLEAN         NOT NULL DEFAULT false,
    performdbbackupna               BOOLEAN         NOT NULL DEFAULT false,
    bijfoutautomatischerestore      BOOLEAN         NOT NULL DEFAULT false,
    statusmau                       VARCHAR(10),
    emailaterror                    VARCHAR(100),
    emailaterrorsenttimestamp       TIMESTAMP,
    emailatcomplete                 VARCHAR(100),
    emailatcompletesenttimestamp    TIMESTAMP,
    removeobsoleteinstallers        BOOLEAN         NOT NULL DEFAULT false,
    diskspacesystemdrive            NUMERIC,
    neededdiskspacesystemdrive      NUMERIC,
    diskspacemks                    NUMERIC,
    neededdiskspacemks              NUMERIC,
    diskspacedbbackup               NUMERIC,
    neededdiskspacedbbackup         NUMERIC,
    PRIMARY KEY (id),
    CONSTRAINT fk_maulogging_mauplanning FOREIGN KEY (planning_id) REFERENCES mauplanning (id)
);

-- ── INSTALL / MIGRATION ───────────────────────────────────────

CREATE TABLE databaseinstallhistory (
    id                      NUMERIC         NOT NULL,
    changecounter           NUMERIC         NOT NULL DEFAULT 1,
    application             VARCHAR(10)     NOT NULL,
    applicationversion      VARCHAR(30)     NOT NULL,
    snapshot                BOOLEAN         NOT NULL DEFAULT false,
    installstartedtimestamp TIMESTAMP       NOT NULL,
    installendedtimestamp   TIMESTAMP,
    succesfullyinstalled    BOOLEAN         NOT NULL DEFAULT false,
    installerrormessage     VARCHAR(800),
    installreport           TEXT,
    PRIMARY KEY (id)
);

CREATE TABLE postinstallresult (
    id                      NUMERIC         NOT NULL,
    changecounter           NUMERIC         NOT NULL DEFAULT 1,
    application             VARCHAR(10)     NOT NULL,
    name                    VARCHAR(50)     NOT NULL,
    generationdate          DATE            NOT NULL,
    importstarttimestamp    TIMESTAMP       NOT NULL,
    importendtimestamp      TIMESTAMP,
    finished                BOOLEAN         NOT NULL DEFAULT false,
    result                  VARCHAR(10),
    numberofentities        NUMERIC,
    applicationversion      VARCHAR(30)     NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE logrecord (
    id                      NUMERIC         NOT NULL,
    changecounter           NUMERIC         NOT NULL DEFAULT 1,
    forname                 VARCHAR(50)     NOT NULL,
    description             VARCHAR(75)     NOT NULL,
    details                 TEXT            NOT NULL,
    result                  VARCHAR(10)     NOT NULL,
    inserttimestamp         TIMESTAMP       NOT NULL,
    postinstallresult_id    NUMERIC         NOT NULL,
    PRIMARY KEY (id),
    CONSTRAINT fk_logrecord_postinstallresult FOREIGN KEY (postinstallresult_id) REFERENCES postinstallresult (id)
);

-- ── STANDALONE CONFIG ─────────────────────────────────────────

CREATE TABLE platformsetting (
    id              NUMERIC         NOT NULL,
    changecounter   NUMERIC         NOT NULL DEFAULT 1,
    name            VARCHAR(60)     NOT NULL,
    description     VARCHAR(255)    NOT NULL,
    settingtype     VARCHAR(15)     NOT NULL,
    settingvalue    TEXT,
    defaultvalue    TEXT,
    maxlength       NUMERIC,
    required        BOOLEAN         NOT NULL DEFAULT false,
    domainvalues    TEXT,
    factorysetting  BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE organisationconfiguration (
    id                  NUMERIC         NOT NULL,
    changecounter       NUMERIC         NOT NULL DEFAULT 1,
    name                VARCHAR(100)    NOT NULL,
    organisationcode    VARCHAR(254)    NOT NULL,
    oin                 VARCHAR(21),
    gemeentecode        VARCHAR(4),
    rsin                VARCHAR(9),
    PRIMARY KEY (id)
);

CREATE TABLE tenantconfiguration (
    id              NUMERIC         NOT NULL,
    changecounter   NUMERIC         NOT NULL DEFAULT 1,
    name            VARCHAR(100)    NOT NULL,
    tenanttype      VARCHAR(6)      NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE mediatype (
    id              NUMERIC         NOT NULL,
    changecounter   NUMERIC         NOT NULL DEFAULT 1,
    mediatype       VARCHAR(128)    NOT NULL,
    description     VARCHAR(80)     NOT NULL,
    extensions      VARCHAR(50)     NOT NULL,
    allowed         BOOLEAN         NOT NULL DEFAULT false,
    factorysetting  BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE licensekey (
    id                  NUMERIC         NOT NULL,
    changecounter       NUMERIC         NOT NULL DEFAULT 1,
    product             VARCHAR(10)     NOT NULL,
    module              VARCHAR(10)     NOT NULL,
    key                 VARCHAR(32)     NOT NULL,
    enddate             DATE            NOT NULL,
    installationdate    DATE,
    factorysetting      BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);

CREATE TABLE lastgeneratedid (
    id               NUMERIC         NOT NULL,
    changecounter    NUMERIC         NOT NULL DEFAULT 1,
    municipalitycode VARCHAR(4)      NOT NULL,
    keytype          VARCHAR(40)     NOT NULL,
    lastgenerated    NUMERIC         NOT NULL,
    factorysetting   BOOLEAN         NOT NULL DEFAULT false,
    PRIMARY KEY (id)
);
```
