declare @excelObj int,
		@workBookObj int,
		@sheetObj int,
		@data nvarchar(max),
		@RC int

exec @RC = sp_oacreate 'Excel.Application', @excelObj out --create an instance of the excel application object

if @RC = 0
begin
	exec sp_oamethod @excelObj, 'Workbooks.Add', @workBookObj out--add a new workbook
	exec sp_oamethod @workBookObj, 'ActiveSheet', @sheetObj out --get reference to the active sheet
end

Select * into #customer_data from test.dbo.Customer

declare @row int = 2,
		@column int = 1

declare db_cursor cursor for
select * from #customer_data

open db_cursor
fetch next from db_cursor into @data

while @@FETCH_STATUS = 0
begin
Declare @str as nvarchar(max)
Set @str = 'Cells('+cast(@row as nvarchar(10))+','+cast(@column as nvarchar(10))+').Value'
	exec sp_oamethod @sheetObj, @str, null,@data --+cast(@row as nvarchar(10))+','+cast(@column as nvarchar(10))+
	set @row = @row + 1
	fetch next from db_cursor into @data
end

close db_cursor
deallocate db_cursor

exec sp_oamethod @workBookObj, 'SaveAs',null,'C:\Users\rober\OneDrive\Documents\exercise r\data.xlsx' --save the workbook
exec sp_oamethod @workBookObj, 'Close',null,FALSE --close the workbook without saving changes
exec sp_oamethod @excelObj, 'Quit' -- quit the excel application

--release the objects
exec sp_oadestroy @sheetObj
exec sp_oadestroy @workBookObj
exec sp_oadestroy @excelObj

drop table #customer_data



