#########################################################
# Start: Definition of servers in Stage
#########################################################

logstamp; Write-Host " Start: Definition of servers in an STAGE";

$global:NodesB  = @{
	"middle1" = "middle1";
	"middle2" = "middle2";
	}

$global:NodesA = $global:NodesB.Values

logstamp; Write-Host " Complete: Definition of servers in an STAGE";
logstamp; Write-Host " Array: $NodesA";
