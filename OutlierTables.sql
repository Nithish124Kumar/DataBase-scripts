/********************************************************************
 FINAL DEPLOYMENT SCRIPT
 Outlier Configuration Schema
********************************************************************/

-- ==============================
-- Master Table: Criteria
-- ==============================
CREATE TABLE dbo.Criteria (
    CriteriaID       UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_Criteria PRIMARY KEY,
    CriteriaName     NVARCHAR(MAX)    NOT NULL,
    OperatorSymbol   NVARCHAR(MAX)    NOT NULL,
    Overview         INT              NOT NULL,  -- Consider changing to NVARCHAR(MAX) if this is meant to be a description
    IsActive         BIT              NOT NULL CONSTRAINT DF_Criteria_IsActive DEFAULT 1,
    CreatedBy        INT              NULL,
    CreatedDate      DATETIME2(0)     NOT NULL CONSTRAINT DF_Criteria_CreatedDate DEFAULT GETDATE(),
    ModifiedBy       INT              NULL,
    ModifiedDate     DATETIME2(0)     NOT NULL CONSTRAINT DF_Criteria_ModifiedDate DEFAULT GETDATE()
);

-- Suggested index for frequent lookups
CREATE INDEX IX_Criteria_CriteriaName
    ON dbo.Criteria (CriteriaName);

-- ==============================
-- Master Table: OutlierMetrics
-- ==============================
CREATE TABLE dbo.OutlierMetrics (
    MetricID         UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_OutlierMetrics PRIMARY KEY,
    MetricsFieldName NVARCHAR(MAX)    NOT NULL,
    Overview         INT              NOT NULL,  -- Consider changing to NVARCHAR(MAX) if this is meant to be a description
    IsActive         BIT              NOT NULL CONSTRAINT DF_OutlierMetrics_IsActive DEFAULT 1,
    CreatedBy        INT              NULL,
    CreatedDate      DATETIME2(0)     NOT NULL CONSTRAINT DF_OutlierMetrics_CreatedDate DEFAULT GETDATE(),
    ModifiedBy       INT              NULL,
    ModifiedDate     DATETIME2(0)     NOT NULL CONSTRAINT DF_OutlierMetrics_ModifiedDate DEFAULT GETDATE()
);

-- Suggested index for frequent lookups
CREATE INDEX IX_OutlierMetrics_MetricsFieldName
    ON dbo.OutlierMetrics (MetricsFieldName);

-- ==============================
-- Primary Table: OutlierConfiguration
-- ==============================
CREATE TABLE dbo.OutlierConfiguration (
    ConfigurationID  UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_OutlierConfiguration PRIMARY KEY,
    OutlierName      NVARCHAR(MAX)    NOT NULL,
    ClientID         INT              NOT NULL,  -- Assuming INT for external client reference; consider UNIQUEIDENTIFIER if internal
    MetricID         UNIQUEIDENTIFIER NOT NULL,  -- Standardized to UNIQUEIDENTIFIER for consistency with OutlierMetrics
    Threshold        INT              NOT NULL CONSTRAINT DF_OutlierConfiguration_Threshold DEFAULT 1,
    ExpiryDate       DATETIME2(0)     NULL,
    LastRunDate      DATETIME2(0)     NULL,
    LastDetectedDate DATETIME2(0)     NULL,
    IsActive         BIT              NULL CONSTRAINT DF_OutlierConfiguration_IsActive DEFAULT 1,
    CreatedBy        INT              NULL,
    CreatedDate      DATETIME2(0)     NOT NULL CONSTRAINT DF_OutlierConfiguration_CreatedDate DEFAULT GETDATE(),
    ModifiedBy       INT              NULL,
    ModifiedDate     DATETIME2(0)     NOT NULL CONSTRAINT DF_OutlierConfiguration_ModifiedDate DEFAULT GETDATE(),

    CONSTRAINT FK_OutlierConfiguration_OutlierMetrics
        FOREIGN KEY (MetricID)
        REFERENCES dbo.OutlierMetrics (MetricID)
);

-- Helpful indexes
CREATE INDEX IX_OutlierConfiguration_Client_Metric
    ON dbo.OutlierConfiguration (ClientID, MetricID)
    INCLUDE (ConfigurationID);

-- Suggested additional index on MetricID for FK lookups
CREATE INDEX IX_OutlierConfiguration_MetricID
    ON dbo.OutlierConfiguration (MetricID);

-- ==============================
-- Mapping Table: ConfigurationStoreMapping
-- ==============================
CREATE TABLE dbo.ConfigurationStoreMapping (
    StoreMappingID   UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ConfigurationStoreMapping PRIMARY KEY,
    ConfigurationID  UNIQUEIDENTIFIER NOT NULL,
    StoreID          NVARCHAR(50)     NOT NULL,
    CreatedBy        INT              NULL,
    CreatedDate      DATETIME2(0)     NOT NULL CONSTRAINT DF_ConfigurationStoreMapping_CreatedDate DEFAULT GETDATE(),

    CONSTRAINT FK_ConfigurationStoreMapping_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE
);

-- Helpful indexes
CREATE INDEX IX_ConfigurationStoreMapping_Config
    ON dbo.ConfigurationStoreMapping (ConfigurationID);

-- Suggested additional index on StoreID for queries filtering by store
CREATE INDEX IX_ConfigurationStoreMapping_StoreID
    ON dbo.ConfigurationStoreMapping (StoreID);

-- ==============================
-- Mapping Table: ConfigurationCriteriaMapping
-- ==============================
CREATE TABLE dbo.ConfigurationCriteriaMapping (
    CriteriaMappingID UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ConfigurationCriteriaMapping PRIMARY KEY,
    ConfigurationID   UNIQUEIDENTIFIER NOT NULL,
    CriteriaID        UNIQUEIDENTIFIER NOT NULL,  -- Standardized to UNIQUEIDENTIFIER for consistency with Criteria
    Amount            INT              NOT NULL,
    CreatedBy         INT              NULL,
    CreatedDate       DATETIME2(0)     NOT NULL CONSTRAINT DF_ConfigurationCriteriaMapping_CreatedDate DEFAULT GETDATE(),

    CONSTRAINT FK_ConfigurationCriteriaMapping_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE,

    CONSTRAINT FK_ConfigurationCriteriaMapping_Criteria
        FOREIGN KEY (CriteriaID)
        REFERENCES dbo.Criteria (CriteriaID)
);

-- Helpful indexes
CREATE INDEX IX_ConfigurationCriteriaMapping_Config
    ON dbo.ConfigurationCriteriaMapping (ConfigurationID);

-- Suggested additional index on CriteriaID for FK lookups
CREATE INDEX IX_ConfigurationCriteriaMapping_CriteriaID
    ON dbo.ConfigurationCriteriaMapping (CriteriaID);

-- ==============================
-- History Table: OutlierRunHistory
-- ==============================
CREATE TABLE dbo.OutlierRunHistory (
    RunHistoryID     UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_OutlierRunHistory PRIMARY KEY,
    ConfigurationID  UNIQUEIDENTIFIER NOT NULL,  -- Added missing column for relationship
    RunDate          DATETIME2(0)     NOT NULL,
    RunStatus        NVARCHAR(100)    NOT NULL,
    Stores           INT              NOT NULL,
    IsDetected       BIT              NOT NULL,
    CreatedBy        INT              NULL,
    CreatedDate      DATETIME2(0)     NOT NULL CONSTRAINT DF_OutlierRunHistory_CreatedDate DEFAULT GETDATE(),

    CONSTRAINT FK_OutlierRunHistory_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE
);

-- Suggested indexes
CREATE INDEX IX_OutlierRunHistory_ConfigurationID
    ON dbo.OutlierRunHistory (ConfigurationID);

CREATE INDEX IX_OutlierRunHistory_RunDate
    ON dbo.OutlierRunHistory (RunDate);

-- ==============================
-- Recipients Table: NotificationRecipients
-- ==============================
CREATE TABLE dbo.NotificationRecipients (
    RecipientID      UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_NotificationRecipients PRIMARY KEY,
    RunHistoryID     UNIQUEIDENTIFIER NOT NULL,  -- Added missing column for relationship
    RecipientAddress NVARCHAR(255)    NOT NULL,  -- Standardized length for email addresses
    CreatedBy        INT              NULL,
    CreatedDate      DATETIME2(0)     NOT NULL CONSTRAINT DF_NotificationRecipients_CreatedDate DEFAULT GETDATE(),

    CONSTRAINT FK_NotificationRecipients_OutlierRunHistory
        FOREIGN KEY (RunHistoryID)
        REFERENCES dbo.OutlierRunHistory (RunHistoryID)
        ON DELETE CASCADE
);

-- Suggested indexes
CREATE INDEX IX_NotificationRecipients_RunHistoryID
    ON dbo.NotificationRecipients (RunHistoryID);

CREATE INDEX IX_NotificationRecipients_RecipientAddress
    ON dbo.NotificationRecipients (RecipientAddress);

