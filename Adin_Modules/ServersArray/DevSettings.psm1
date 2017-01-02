#########################################################
# Start: Definition of servers in Dev
#########################################################

logstamp; Write-Host " Start: Definition of servers in an Dev";

$global:NodesB  = @{
	"stage1" = "stage1";
	}

$global:NodesA = $global:NodesB.Values

logstamp; Write-Host " Complete: Definition of servers in an Dev";
logstamp; Write-Host " Array: $NodesA";
