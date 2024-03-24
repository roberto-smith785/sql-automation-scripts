Create FUNCTION [dbo].[ReadfileAsTable]
(
@Path VARCHAR(255),
@Filename VARCHAR(100)
)
RETURNS 
@File TABLE
(
[LineNo] int identity(1,1), 
Line nvarchar(max)) 
AS
BEGIN
DECLARE  @objFileSystem int
        ,@objTextStream int,
		@objErrorObject int,
		@strErrorMessage Varchar(1000),
	    @Command varchar(1000),
	    @hr int,
		@String varchar(8000),
		@YesOrNo INT

Select @strErrorMessage='opening the File System Object'
EXECUTE @hr = sp_OACreate  'Scripting.FileSystemObject' , @objFileSystem OUT

If @HR=0 
BEGIN
	Select @objErrorObject=@objFileSystem, @strErrorMessage='Opening file "'+@path+'\'+@filename+'"',@command=@path+'\'+@filename
	execute @hr = sp_OAMethod  @objFileSystem  , 'OpenTextFile', @objTextStream OUT, @command,1,false,0--for reading, FormatASCII
END

WHILE @hr=0
BEGIN
	If @HR=0 
	BEGIN
		Select @objErrorObject=@objTextStream, @strErrorMessage='finding out if there is more to read in "'+@filename+'"'
		execute @hr = sp_OAGetProperty @objTextStream, 'AtEndOfStream', @YesOrNo OUTPUT
	END

	IF @YesOrNo<>0 
	BEGIN
		break
	END

	If @HR=0
	BEGIN
		Select @objErrorObject=@objTextStream, @strErrorMessage='reading from the output file "'+@filename+'"'
		execute @hr = sp_OAMethod  @objTextStream, 'Readline', @String OUTPUT
	END
	INSERT INTO @file(line) SELECT '"'+@String+'"'
END

If @HR=0
BEGIN
	Select @objErrorObject=@objTextStream, @strErrorMessage='closing the output file "'+@filename+'"'
	execute @hr = sp_OAMethod  @objTextStream, 'Close'
END


If @hr<>0
Begin
	Declare 
		@Source varchar(255),
		@Description Varchar(255),
		@Helpfile Varchar(255),
		@HelpID int
	
	EXECUTE sp_OAGetErrorInfo  @objErrorObject,@source output,@Description output,@Helpfile output,@HelpID output
	Select @strErrorMessage='Error whilst '+coalesce(@strErrorMessage,'doing something')+', '+coalesce(@Description,'')
	Insert into @File(line) select @strErrorMessage
End
EXECUTE  sp_OADestroy @objTextStream --Fill the table variable with the rows for your result set
	
	RETURN 
END
