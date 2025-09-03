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
    OutlierName       nvarchar(max)   NOT NULL,
    ClientID          INT             NOT NULL,	
    MetricID          INT             NOT NULL,
    Threshold         INT DEFAULT 1   NOT NULL,
    ExpiryDate        DATETIME2(0)        NULL,
	LastRunDate       DATETIME2(0)        NULL,
	LastDetectedDate  DATETIME2(0)        NULL,
	IsActive          BIT				  NULL,
	CreatedBy         INT                 NULL,
	CreatedDate       DATETIME2(0)    NOT NULL, 
	ModifiedBy        INT                 NULL,
	ModifiedDate      DATETIME2(0)    NOT NULL, 

);

-- Helpful indexes
CREATE INDEX IX_OutlierConfiguration_Client_Metric
    ON dbo.OutlierConfiguration (ClientID, MetricID)
    INCLUDE (ConfigurationID);



-- ==============================
-- Store Mapping Table
-- ==============================
CREATE TABLE dbo.ConfigurationStoreMapping (
    StoreMappingID   UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_ConfigurationStoreMapping PRIMARY KEY,
    ConfigurationID  UNIQUEIDENTIFIER NOT NULL,
    StoreID          NVARCHAR(50)     NOT NULL,
	CreatedBy        INT                 NULL,
	CreatedDate      DATETIME2(0)     NOT NULL,

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
    Amount           INT              NOT NULL,
	CreatedBy		 INT                 NULL,
	CreatedDate      DATETIME2(0)     NOT NULL,

    CONSTRAINT FK_ConfigurationCriteriaMapping_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE
);

CREATE INDEX IX_ConfigurationCriteriaMapping_Config
    ON dbo.ConfigurationCriteriaMapping (ConfigurationID);


-- ==============================
-- Criteria Master Table
-- ==============================
CREATE TABLE dbo.Criteria (
    CriteriaID       UNIQUEIDENTIFIER NOT NULL
    CriteriaName     NVARCHAR(MAX)    NOT NULL,
    Operatorsymbol   NVARCHAR(MAX)    NOT NULL,
    Overview         INT              NOT NULL,
	IsActive         BIT DEFAULT 1    NOT NULL,
	CreatedBy		 INT                 NULL,
	CreatedDate      DATETIME2(0)     NOT NULL,
	ModifiedBy		 INT                 NULL,
	ModifiedDate     DATETIME2(0)     NOT NULL,
);

-- ==============================
-- Metric Master Table
-- ==============================
CREATE TABLE dbo.OutlierMetrics (
    MetricID         UNIQUEIDENTIFIER NOT NULL
    MetricsFieldName NVARCHAR(MAX)    NOT NULL,
    Overview         INT              NOT NULL,
	IsActive         BIT DEFAULT 1    NOT NULL,
	CreatedBy		 INT                 NULL,
	CreatedDate      DATETIME2(0)     NOT NULL,
	ModifiedBy		 INT                 NULL,
	ModifiedDate     DATETIME2(0)     NOT NULL,

);


-- ==============================
-- RunHistory
-- ==============================
CREATE TABLE dbo.OutlierRunHistory (
    RunHistoryID     UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_RunHistoryID PRIMARY KEY,
    RunDate          DATETIME2(0)    NOT NULL
    RunStatus        NVARCHAR(100)             NOT NULL, 
    Stores           INT			 NOT NULL, 
    IsDetected		 BIT             NOT NULL, 
    EmailRecipient   NVARCHAR(MAX)       NULL  
	CreatedBy		 INT                 NULL,
	CreatedDate      DATETIME2(0)     NOT NULL,

		CONSTRAINT FK_OutlierRunHistory_OutlierConfiguration
        FOREIGN KEY (ConfigurationID)
        REFERENCES dbo.OutlierConfiguration (ConfigurationID)
        ON DELETE CASCADE
);

-- ==============================
-- RunHistory Recipient
-- ==============================
CREATE TABLE dbo.NotificationRecipients (
    RecipientID     UNIQUEIDENTIFIER NOT NULL
        CONSTRAINT PK_RecipientID  PRIMARY KEY,
    RecipientAddress NVARCHAR(100)             NOT NULL, 
    Stores           INT			 NOT NULL, 
    IsDetected		 BIT             NOT NULL, 
    EmailRecipient   NVARCHAR(MAX)       NULL  
	CreatedBy		 INT                 NULL,
	CreatedDate      DATETIME2(0)     NOT NULL,

	    CONSTRAINT FK_NotificationRecipients_OutlierRunHistory
        FOREIGN KEY (RunHistoryID)
        REFERENCES dbo.OutlierRunHistory (RunHistoryID)
        ON DELETE CASCADE
);





