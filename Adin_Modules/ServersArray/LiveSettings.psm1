#########################################################
# Start: Definition of servers in an NLB
#########################################################


###### NORMAL ADMINS WAY

logstamp; Write-Host " Запуск: Получение списка серверов в кластере балансировки нагрузки";

# FYI: You can actually knowing the name of a server to specify a list of servers in the cluster and define them in an array.
 $global:FirstNode = "web1"
 $global:NodesA = Split-Path -leaf (Get-NlbClusterNode -HostName $FirstNode) | Sort-Object

logstamp; Write-Host " Завершено: Определение узлов кластера балансировки нагрузки NLB" -ForegroundColor 'Magenta' ;
logstamp; Write-Host " Массив серверов: $global:NodesA"  -ForegroundColor 'Magenta' ; 

#############