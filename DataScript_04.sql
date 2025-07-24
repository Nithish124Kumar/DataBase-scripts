/*
===============================================================================
 Script Name   : Assign Menu to Reportmaster - Menu Master for Admin Panel
 Author        : Nithish
 Summary       : 
     This script ensures that the Report "Admin Panel" is assigned 
     access to the menu "Menu Master". It fetches the corresponding ReportmasterID 
     and Menu ID, and Upadte the mapping into the 'Menu' table only 
     if it does not already exist. The operation is wrapped in a transaction 
     with error handling to ensure safe execution.
===============================================================================
*/

BEGIN TRANSACTION;
BEGIN TRY
    DECLARE 
        @MenuMaster NVARCHAR(MAX) = 'Menu Master',
		@AdminPanel NVARCHAR(MAX) = 'Admin Panel',
        @ReportmasterID_AdminPanel INT,
        @MenuMasterID INT;

    -- Get ReportMaster ID 
    SELECT @ReportmasterID_AdminPanel = r.reportmasterid
    FROM [ReportMaster] r
    WHERE r.reportname = @AdminPanel;

    -- Get Menu ID
    SELECT @MenuMasterID = m.menuid
    FROM Menu m
    WHERE m.MenuName = @MenuMaster;	

    -- UPDATE MENU RECORD
	UPDATE MENU SET REPORTMASTERID = @ReportmasterID_AdminPanel
	WHERE MENUID  = @MenuMasterID
	AND (reportmasterid IS NULL) 

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    SELECT ERROR_MESSAGE() AS ErrorMessage;
    PRINT 'Rollback transaction complete';
END CATCH;
