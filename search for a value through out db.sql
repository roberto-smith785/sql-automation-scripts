DECLARE @SearchValue NVARCHAR(255) = 'document'
DECLARE @SQL NVARCHAR(MAX) = ''
DECLARE @TableName NVARCHAR(255)
DECLARE @ColumnName NVARCHAR(255)
 
-- Cursor to go through each table and column
DECLARE col_cursor CURSOR FOR
SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext') -- Only applicable data types
ORDER BY TABLE_NAME
 
OPEN col_cursor  
FETCH NEXT FROM col_cursor INTO @TableName, @ColumnName
 
WHILE @@FETCH_STATUS = 0  
BEGIN  
    -- Construct SQL to search for the value in the current column
    SET @SQL = @SQL + 'IF EXISTS (SELECT 1 FROM [' + @TableName + '] WHERE [' + @ColumnName + '] LIKE ''%' + @SearchValue + '%'') 
                      PRINT ''Found in: ' + @TableName + '.' + @ColumnName + ''';' + CHAR(13)
 
    FETCH NEXT FROM col_cursor INTO @TableName, @ColumnName  
END  
 
CLOSE col_cursor  
DEALLOCATE col_cursor
 
-- Execute the constructed SQL
EXEC sp_executesql @SQL