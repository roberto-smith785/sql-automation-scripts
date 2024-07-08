DECLARE @tableName as nvarchar(max)
DECLARE schema_cursor CURSOR FOR
SELECT name FROM sys.objects where type_desc = 'USER_TABLE'

OPEN schema_cursor
FETCH NEXT FROM schema_cursor INTO @tableName

WHILE @@FETCH_STATUS = 0
BEGIN
Declare @createDefinition as nvarchar(max)
SELECT @createDefinition = 'create table ['+@tableName+']('+STUFF (
(SELECT ',' +char(10)+create_definitions FROM (
SELECT   
'[' + cols_info.COLUMN_NAME + '] [' + cols_info.DATA_TYPE + ']' +
(CASE WHEN cols_info.CHARACTER_MAXIMUM_LENGTH IS NULL THEN '' WHEN Cols_info.CHARACTER_MAXIMUM_LENGTH = '-1' THEN '(MAX)' ELSE '(' + CAST(cols_info.CHARACTER_MAXIMUM_LENGTH AS nvarchar(100)) + ')' END) + '' + (CASE WHEN cols_info.IS_NULLABLE = 'NO' THEN ' NOT NULL ' ELSE ' NULL' END) +
(CASE WHEN tbl_constraint.CONSTRAINT_TYPE ='PRIMARY KEY' THEN tbl_constraint.CONSTRAINT_TYPE WHEN tbl_constraint.CONSTRAINT_TYPE = 'FOREIGN KEY' THEN tbl_constraint.CONSTRAINT_TYPE + ' REFERENCES [' + key_col_use_1.TABLE_NAME
                   + '](' + key_col_use_1.COLUMN_NAME + ')' ELSE coalesce(tbl_constraint.CONSTRAINT_TYPE,'') END) AS create_definitions
FROM     
INFORMATION_SCHEMA.TABLE_CONSTRAINTS AS tbl_constraint left JOIN
INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS as ref_constraint ON tbl_constraint.CONSTRAINT_NAME =ref_constraint.CONSTRAINT_NAME left JOIN
 INFORMATION_SCHEMA.TABLE_CONSTRAINTS ON ref_constraint.UNIQUE_CONSTRAINT_NAME =INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_NAME  left JOIN
 INFORMATION_SCHEMA.KEY_COLUMN_USAGE as key_col_use_1 ON INFORMATION_SCHEMA.TABLE_CONSTRAINTS.TABLE_NAME = key_col_use_1.TABLE_NAME AND INFORMATION_SCHEMA.TABLE_CONSTRAINTS.CONSTRAINT_NAME = key_col_use_1.CONSTRAINT_NAME LEFT OUTER JOIN
INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS key_col_use ON tbl_constraint.CONSTRAINT_NAME = key_col_use.CONSTRAINT_NAME AND tbl_constraint.TABLE_NAME = key_col_use.TABLE_NAME full OUTER JOIN
                  INFORMATION_SCHEMA.COLUMNS AS cols_info ON key_col_use.TABLE_NAME = cols_info.TABLE_NAME AND key_col_use.COLUMN_NAME = cols_info.COLUMN_NAME
WHERE  (cols_info.TABLE_NAME =@tableName)
) as temp for xml path('')),1,1,'')+');'+char(10)

Print @createDefinition

FETCH NEXT FROM schema_cursor INTO @tableName

END

CLOSE schema_cursor
DEALLOCATE schema_cursor

