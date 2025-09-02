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
    OutlierName     nvarchar(max)   NOT NULL,
    ClientID        INT             NOT NULL,
    MetricID        INT             NOT NULL,
    ExpiryDate      DATETIME2(0)        NULL,

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
-- Store Mapping Table
-- ==============================
CREATE TABLE dbo.ConfigurationStoreMapping (
    StoreMappingID   UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ConfigurationStoreMapping PRIMARY KEY,
    ConfigurationID  UNIQUEIDENTIFIER NOT NULL,
    StoreID          NVARCHAR(50)     NOT NULL,

    CONSTRAINT FK_ConfigurationStoreMapping_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE
);

CREATE INDEX IX_ConfigurationStoreMapping_Config
    ON dbo.ConfigurationStoreMapping (ConfigurationID);


-- ==============================
-- Criteria + Value Mapping Table
-- ==============================
CREATE TABLE dbo.ConfigurationCriteriaMapping (
    CriteriaMappingID UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ConfigurationCriteriaMapping PRIMARY KEY,
    ConfigurationID  UNIQUEIDENTIFIER NOT NULL,
    CriteriaID       INT              NOT NULL,   -- e.g. from a Criteria lookup
    Value            INT              NOT NULL,

    CONSTRAINT FK_ConfigurationCriteriaMapping_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE
);

CREATE INDEX IX_ConfigurationCriteriaMapping_Config
    ON dbo.ConfigurationCriteriaMapping (ConfigurationID);


