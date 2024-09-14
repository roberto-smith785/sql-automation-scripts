USE test_dup
DECLARE @clientName AS NVARCHAR(MAX),
        @tableName AS NVARCHAR(MAX),
        @totalRecords AS INT = 0,
        @emailTo AS NVARCHAR(MAX),
        @emailToUserName AS NVARCHAR(MAX),
        @emailCC AS NVARCHAR(MAX),
        @emailSubject AS NVARCHAR(MAX),
        @emailBody AS NVARCHAR(MAX),
        @emailMessage AS NVARCHAR(MAX),
        @emailAttachFileName AS NVARCHAR(MAX),
        @sql AS NVARCHAR(MAX),
        @emailProfileName AS NVARCHAR(MAX)

BEGIN TRY

SET @clientName = 'ClientName'
SET @tableName = 'order'

    -- Count records from the table
    SET @sql = 'SELECT @totalRecords = COUNT(*) FROM ' + @tableName;
    EXEC sp_executesql @sql, N'@totalRecords INT OUTPUT', @totalRecords OUTPUT;

    -- Set up email details
    SET @emailTo = 'robertosmith785@gmail.com'
    SET @emailToUserName = 'Roberto Smith'
    SET @emailCC = 'roberto@compnay.com.na'
    SET @emailSubject = @clientName + ' Weekly Import - ' + FORMAT(GETDATE(), 'dd/MM/yyyy')
    SET @emailAttachFileName = REPLACE(@clientName,' ','') + 'WeeklyImport_' + FORMAT(GETDATE(), 'ddMMyyyy') + '.csv'
    SET @emailProfileName = 'system'

    IF @totalRecords > 0
    BEGIN
        SET @emailMessage = 'Kindly find the attached file for ' + @clientName + ' Weekly Import for (' + FORMAT(GETDATE(), 'dd/MM/yyyy') + '), showing the records to be imported. <br/>';
    END
    ELSE
    BEGIN
        SET @emailMessage = 'Please take note that no data was found for ' + @clientName + ' Weekly Import for (' + FORMAT(GETDATE(), 'dd/MM/yyyy') + '). <br/>';
    END

    SET @emailBody = 
    '<!DOCTYPE html>
    <html>
    <head><meta charset="UTF-8"><title>Email</title></head>
    <body>
    <div>
    Good day ' + @emailToUserName + ',<br/><br/>
    ' + @emailMessage + '
    <u>Total records to import : ' + CAST(@totalRecords AS VARCHAR) + '</u><br/><br/>
    Kind regards<br/>
    ------------<br/>
    <span style= "color:#B31B34;">
    Database server<br/><br/>
    </span>
    <span style = "color:##2f5267";>
    E-mail address: support@company.com.na <br/>
    Phone: +264 61 24 0000 0000 <br/>
    Address: company address
    </span><br/><br/>
    <i style= "color:#B31B34;">Please note: This is an automated message. If you have any questions or require assistance, kindly contact our support team.</i>
    </body>
    </html>';

    -- Send the email based on total records
    IF @totalRecords > 0 
    BEGIN
        DECLARE @tab CHAR(1) = CHAR(9);
        DECLARE @newLine CHAR(2) = CHAR(13) + CHAR(10);

        -- Step 1: Generate the dynamic header
        DECLARE @header NVARCHAR(MAX);
        SELECT @header = STRING_AGG(QUOTENAME(COLUMN_NAME) + ' AS [' + COLUMN_NAME + ']', ', ')
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = @tableName;

        -- Step 2: Dynamically generate the SELECT statement with all values cast to NVARCHAR and format dates
        DECLARE @data NVARCHAR(MAX);
        SELECT @data = STRING_AGG(
            CASE 
                WHEN DATA_TYPE IN ('date', 'datetime', 'datetime2') THEN 
                    'FORMAT(' + QUOTENAME(COLUMN_NAME) + ', ''dd/MM/yyyy'') AS [' + COLUMN_NAME + ']' 
                ELSE 
                    'CAST(' + QUOTENAME(COLUMN_NAME) + ' AS NVARCHAR(MAX)) AS [' + COLUMN_NAME + ']' 
            END, 
            ', '
        )
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_NAME = @tableName;

        -- Combine the header and data into a single query
        DECLARE @query NVARCHAR(MAX);
        SET @query = 'SELECT ' + @header + ' UNION ALL SELECT ' + @data + ' FROM [' + @tableName + ']';

        -- Step 3: Use sp_send_dbmail to send the email with the dynamically generated CSV
       EXEC msdb.dbo.sp_send_dbmail
            @profile_name = @emailProfileName,  
            @recipients = @emailTo,  
            @subject = @emailSubject,
            @body = @emailBody,
            @body_format = 'HTML',
            @query = @query,  
            @attach_query_result_as_file = 1,
            @query_attachment_filename = @emailAttachFileName,
            @query_result_separator = @tab,
            @query_result_no_padding = 1,  
            @query_result_width = 32767;
		
    END
    ELSE
    BEGIN
       EXEC msdb.dbo.sp_send_dbmail
            @profile_name = @emailProfileName,  
            @recipients = @emailTo,  
            @subject = @emailSubject,
            @body = @emailBody,
            @body_format = 'HTML';
			
    END
END TRY
BEGIN CATCH
    -- Capture error details
	Set @emailSubject = 'Error in Weekly Import Process for '+ @clientName
	Declare @errorEmailToUserName as nvarchar(max) = 'Roberto Smith'
    Declare @errorMessage as nvarchar(max) = ERROR_MESSAGE();
	Declare @errorEmailMessage as nvarchar(max) = 'An error occurred during the process: ' + @errorMessage
	Declare @errorEmailBody as nvarchar(max) = '<!DOCTYPE html>
	<html>
    <head><meta charset="UTF-8"><title>Email</title></head>
    <body>
    <div>
    Good day ' + @errorEmailToUserName + ',<br/><br/>
    ' + @errorEmailMessage + '
    <br/><br/>
    Kind regards<br/>
    ------------<br/>
    <span style= "color:#B31B34;">
    Database server<br/><br/>
    </span>
    <span style = "color:##2f5267";>
    E-mail address: support@company.com.na <br/>
    Phone: +264 61 24 0000 0000 <br/>
    Address: company address
    </span><br/><br/>
    <i style= "color:#B31B34;">Please note: This is an automated message. If you have any questions or require assistance, kindly contact our support team.</i>
    </body>
    </html>'
   
	
    -- Log the error or send a notification
    EXEC msdb.dbo.sp_send_dbmail
        @profile_name = @emailProfileName,  
        @recipients = @emailTo,  
        @subject = @emailSubject,
        @body = @emailBody,
        @body_format = 'HTML';
		
END CATCH;
