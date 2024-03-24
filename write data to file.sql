Create Procedure spWriteStringToFile
 (
@String Varchar(max), --8000 in SQL Server 2000
@Path VARCHAR(255),
@Filename VARCHAR(100)

--
)
AS
DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@fileAndPath varchar(80)

Set nocount on

Select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT

Select @FileAndPath=@path+'\'+@filename

If @HR=0 
Begin
	Select @objErrorObject=@objFileSystem , @strErrorMessage='Creating file "'+@FileAndPath+'"'
	execute @hr = sp_OAMethod   @objFileSystem   , 'CreateTextFile', @objTextStream OUT, @FileAndPath,0,False
end

If @HR=0 
Begin
	Select @objErrorObject=@objTextStream, @strErrorMessage='writing to the file "'+@FileAndPath+'"'
	execute @hr = sp_OAMethod  @objTextStream, 'Write', Null, @String
End

If @HR=0 
Begin
	Select @objErrorObject=@objTextStream, @strErrorMessage='closing the file "'+@FileAndPath+'"'
	execute @hr = sp_OAMethod  @objTextStream, 'Close'
End

If @hr<>0
Begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject, @source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '+coalesce(@strErrorMessage,'doing something')+', '+coalesce(@Description,'')
	Raiserror (@strErrorMessage,16,1)
End

EXECUTE  sp_OADestroy @objTextStream
EXECUTE sp_OADestroy @objFileSystem
