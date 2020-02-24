/* Variable input @FlightName,@FlightServiceId */

DECLARE 
	@Enabled AS int,
	@RecId AS bigint

SELECT @Enabled = [ENABLED], @RecId = SYSFLIGHTING.RECID
FROM SYSFLIGHTING
JOIN [PARTITIONS] ON [PARTITIONS].Recid = SYSFLIGHTING.PARTITION
WHERE FLIGHTNAME = @FlightName
  AND PARTITIONKEY = 'initial'

if (@Enabled = 1)
	UPDATE SYSFLIGHTING SET ENABLED = 0 WHERE RECID = @RecId
