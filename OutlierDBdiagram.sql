/********************************************************************
 FINAL DEPLOYMENT SCRIPT
 Outlier Configuration Schema
********************************************************************/

-- ==============================
-- Primary table: OutlierConfiguration
-- ==============================
CREATE TABLE dbo.OutlierConfiguration (
    ConfigurationID UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_OutlierConfiguration PRIMARY KEY,
    ClientID        INT             NOT NULL,
    MetricID        INT             NOT NULL,
    Value           INT                 NULL,
    ExpiryDate      DATETIME2(0)        NULL,

    -- Guard against invalid values
    CONSTRAINT CK_OutlierConfiguration_Value_NonNegative
        CHECK (Value IS NULL OR Value >= 0)
);

-- Helpful indexes
CREATE INDEX IX_OutlierConfiguration_Client_Metric
    ON dbo.OutlierConfiguration (ClientID, MetricID)
    INCLUDE (ConfigurationID);

-- Ensure only one *active* config per (ClientID, MetricID)
CREATE UNIQUE INDEX UX_OutlierConfiguration_Active_ByClientMetric
    ON dbo.OutlierConfiguration (ClientID, MetricID)
    WHERE ExpiryDate IS NULL;


-- ==============================
-- ConfigurationMapping
-- ==============================
CREATE TABLE dbo.ConfigurationMapping (
    MappingID        UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ConfigurationMapping PRIMARY KEY,
    ConfigurationID  UNIQUEIDENTIFIER NOT NULL,
    Criteria         INT              NOT NULL,
    StoreID          INT			  NOT NULL, 

    CONSTRAINT FK_ConfigurationMapping_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE
);

CREATE INDEX IX_ConfigurationMapping_ConfigurationID
    ON dbo.ConfigurationMapping (ConfigurationID);


-- ==============================
-- MappingRunHistory
-- ==============================
CREATE TABLE dbo.MappingRunHistory (
    RunDate          DATETIME2(0)    NOT NULL
        CONSTRAINT PK_MappingRunHistory PRIMARY KEY,
    RunStatus        BIT             NOT NULL,  -- 1=success, 0=failure
    Stores           INT			 NOT NULL, -- kept for backward compatibility
    DetectionStatus  BIT             NOT NULL, -- 1=detected, 0=not detected
    EmailRecipient   NVARCHAR(MAX)       NULL  -- kept for backward compatibility
);


-- ==============================
-- Normalized Child Tables
-- ==============================

-- 1. Stores targeted by a configuration mapping
CREATE TABLE dbo.ConfigurationMappingStore (
    MappingID  UNIQUEIDENTIFIER NOT NULL,
    StoreID    INT              NOT NULL,
    CONSTRAINT PK_ConfigurationMappingStore
        PRIMARY KEY (MappingID, StoreID),
    CONSTRAINT FK_ConfigurationMappingStore_ConfigurationMapping
        FOREIGN KEY (MappingID)
        REFERENCES dbo.ConfigurationMapping (MappingID)
        ON DELETE CASCADE
);

CREATE INDEX IX_ConfigurationMappingStore_StoreID
    ON dbo.ConfigurationMappingStore (StoreID);


-- 2. Stores included in a specific run
CREATE TABLE dbo.MappingRunHistoryStore (
    RunDate   DATETIME2(0) NOT NULL,
    StoreID   INT          NOT NULL,
    CONSTRAINT PK_MappingRunHistoryStore
        PRIMARY KEY (RunDate, StoreID),
    CONSTRAINT FK_MappingRunHistoryStore_MappingRunHistory
        FOREIGN KEY (RunDate)
        REFERENCES dbo.MappingRunHistory (RunDate)
        ON DELETE CASCADE
);


-- 3. Email recipients for a specific run
CREATE TABLE dbo.MappingRunHistoryRecipient (
    RunDate   DATETIME2(0)   NOT NULL,
    Email     NVARCHAR(320)  NOT NULL,  -- 320 allows full Unicode
    CONSTRAINT PK_MappingRunHistoryRecipient
        PRIMARY KEY (RunDate, Email),
    CONSTRAINT FK_MappingRunHistoryRecipient_MappingRunHistory
        FOREIGN KEY (RunDate)
        REFERENCES dbo.MappingRunHistory (RunDate)
        ON DELETE CASCADE
);

-- Basic email format check (lightweight, not RFC-complete)
ALTER TABLE dbo.MappingRunHistoryRecipient
ADD CONSTRAINT CK_MappingRunHistoryRecipient_Email_Format
CHECK (Email LIKE '%@%.%');