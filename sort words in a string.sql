create function SortWords (@InputString nvarchar(max))
returns nvarchar(max)
as 
begin
DECLARE @SortedWords NVARCHAR(MAX);

SELECT 
        @SortedWords = STRING_AGG(Word, ' ') WITHIN GROUP (ORDER BY Word)
    FROM (
        SELECT LTRIM(RTRIM(value)) AS Word
        FROM STRING_SPLIT(@InputString, ' ')
    ) AS Words;

return @SortedWords
end