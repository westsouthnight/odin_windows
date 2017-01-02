Function global:Stop-ClusterResourceNG () {
# example of function with template
$service = $args[0];
$clustername = $args[1];
$FunctionNG = "Stop-ClusterResourceNG"
logstamp; Write-Host " Запуск функции $FunctionNG : Stop Service $service on Cluster $clustername" -ForegroundColor 'Gray';

$global:body = "Автоматическое обновление: Остановка сервиса $service запущена на кластере $clustername";
$global:subject = " [START MODULE] Автоматическое обновление: Остановка сервиса $service";
send_email;

	try{
			Stop-ClusterResource $service -Cluster $clustername
			}
	catch{
	   #########################################################
	   $messageNG = " Function $FunctionNG : Stop Service $service on Cluster $clustername Failed!"
	   $bodyNG = "Function $FunctionNG : Stop Service $service on Cluster $clustername Failed!";
	   $subjectNG = "Function $FunctionNG have Errors!"
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   $global:body = "Автоматическое обновление: Остановка сервиса $service на кластере $clustername провалена.";
	   $global:subject = " [ALERT MODULE] Автоматическое обновление: Остановка сервиса $service провалена";
	   send_email;
	   #NotificationNG;
	   #XwaitNG;
			}
	finally{
       logstamp; Write-Host " Function $FunctionNG : Stop Service $service on Cluster $clustername Complete" -ForegroundColor 'Green';
			}
			
	$global:body = "Автоматическое обновление: Функция остановки сервиса $service завершена на кластере $clustername";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Функция остановки сервиса $service завершена";
	send_email;
	logstamp; Write-Host " Function $FunctionNG : Function $FunctionNG end." -ForegroundColor 'Gray';
}

Function global:Start-ClusterResourceNG () {
# example of function with template
$service = $args[0];
$clustername = $args[1];
$FunctionNG = "Start-ClusterResourceNG"
logstamp; Write-Host " Start Function $FunctionNG : Start Service $service on Cluster $clustername" -ForegroundColor 'Gray';

$global:body = "Автоматическое обновление: Начало запуска сервиса $service на кластере $clustername";
$global:subject = " [START MODULE] Автоматическое обновление: Запуск сервиса $service";
send_email;

	try{
			Start-ClusterResource $service -Cluster $clustername
			}
	catch{
	   #########################################################
	   $messageNG = " Function $FunctionNG : Start Service $service on Cluster $clustername Failed!"
	   $bodyNG = "Function $FunctionNG : Start Service $service on Cluster $clustername Failed!";
	   $subjectNG = "Function $FunctionNG have Errors!"
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   $global:body = "Автоматическое обновление: Запуск сервиса $service на кластере $clustername не состоялся";
	   $global:subject = " [ALERT MODULE] Автоматическое обновление: Запуск сервиса $service не состоялся";
	   send_email;
	   #NotificationNG;
	   #XwaitNG;
			}
	finally{
       logstamp; Write-Host " Function $FunctionNG : Start Service $service on Cluster $clustername Complete" -ForegroundColor 'Green';
			}
			
	$global:body = "Автоматическое обновление: Функция запуска сервиса $service завершена на кластере $clustername";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Функция запуска сервиса $service завершена";
	send_email;
	logstamp; Write-Host " Function $FunctionNG : Function $FunctionNG end." -ForegroundColor 'Gray';
}

Function global:Get-ClusterResourceOwnerNG () {
# example of function with template
# ClusterResourceOwner$service
$service = $args[0];
$clustername = $args[1];
$FunctionNG = "Get-ClusterResourceOwnerNG"
logstamp; Write-Host " Start Function $FunctionNG : Get Service Owner Node for $service on Cluster $clustername" -ForegroundColor 'Gray';

$global:body = "Автоматическое обновление: Начало запуска получения имени сервера владельца службы $service на кластере $clustername";
$global:subject = " [START MODULE] Автоматическое обновление: Получение владельца службы $service";
send_email;

	try{
			$ClusterServiceOwner = Get-ClusterResource $service -Cluster $clustername | Select-Object OwnerNode
			$ClusterServiceOwner.OwnerNode.Name
			
			$i = $ClusterServiceOwner.OwnerNode.Name
			$iv = Test-Path variable:\ClusterResourceOwner$service
			if ($iv -eq $false)
				{
				logstamp; Write-Host " Global Variable ClusterResourceOwner$service does not exist" -ForegroundColor 'Green';
				logstamp; Write-Host " Writing Current Owner For Service to Dynamic Variable ClusterResourceOwner$service" -ForegroundColor 'Green';
				New-Variable -Name "ClusterResourceOwner$service" -Value $i -Scope Global
				}
			else
				{
				logstamp; Write-Host " Global Variable ClusterResourceOwner$service does exist" -ForegroundColor 'Red';
				logstamp; Write-Host " Removing Global Variable ClusterResourceOwner$service" -ForegroundColor 'Magenta';
				Remove-variable "ClusterResourceOwner$service" -Scope Global
				New-Variable -Name "ClusterResourceOwner$service" -Value $i -Scope Global
				}
			logstamp; Write-Host " Current Owner will be ClusterResourceOwner$service for server $service" -ForegroundColor 'Green';
				
				$global:body = "Автоматическое обновление: Информация о владельце сервиса $service на кластере $clustername - текущий владелец ClusterResourceOwner$service";
				$global:subject = " [INFO MODULE] Автоматическое обновление: Информация о владельце сервиса $service";
				send_email;
			
			}
	catch{
	   #########################################################
	   $messageNG = " Function $FunctionNG : Get Service Owner Node for $service on Cluster $clustername Failed!"
	   $bodyNG = "Function $FunctionNG : Get Service Owner Node for $service on Cluster $clustername Failed!";
	   $subjectNG = "Function $FunctionNG have Errors!"
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   $global:body = "Автоматическое обновление: Получение владельца службы $service провалено";
	   $global:subject = " [ALERT MODULE] Автоматическое обновление: Получение владельца службы $service провалено";
	   send_email;
	   #NotificationNG;
	   #XwaitNG;
			}
	finally{
       logstamp; Write-Host " Function $FunctionNG : Get Service Owner Node for $service on Cluster $clustername Complete" -ForegroundColor 'Green';
			}
			
	$global:body = "Автоматическое обновление: Функция получения имя сервера владельца сервиса $service завершена на кластере $clustername";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Функция получения владельца сервиса $service завершена";
	send_email;
	logstamp; Write-Host " Function $FunctionNG : Function $FunctionNG end." -ForegroundColor 'Gray';
}

Function global:Move-ClusterResourceNG () {
# example of function with template
$clustergroup = $args[0];
$servernode = $args[1];
$cluster = $args[2];
$FunctionNG = "Move-ClusterResourceNG"
logstamp; Write-Host " Start Function $FunctionNG : Move ClusterGroup $clustergroup to servernode $servernode" -ForegroundColor 'Gray';
	
	$global:body = "Автоматическое обновление: Начало смены владельца службы $service в кластерной группе $clustergroup на кластере $cluster";
	$global:subject = " [START MODULE] Автоматическое обновление: Начало смены владельца службы $service";
	send_email;
	
	try{
			Move-ClusterGroup $clustergroup -Node $servernode -Cluster $cluster
			}
	catch{
	   #########################################################
	   $messageNG = " Function $FunctionNG : Move ClusterGroup $clustergroup to servernode $servernode Failed!"
	   $bodyNG = "Function $FunctionNG : Move ClusterGroup $clustergroup to servernode $servernode Failed!";
	   $subjectNG = "Function $FunctionNG have Errors!"
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   global:body = "Автоматическое обновление: Смена владельца службы $service в кластерной группе $clustergroup на кластере $cluster провалена";
	   $global:subject = " [ALERT MODULE] Автоматическое обновление: Смена владельца службы $service провалена";
	   send_email;
	   #NotificationNG;
	   #XwaitNG;
			}
	finally{
       logstamp; Write-Host " Function $FunctionNG : Move ClusterGroup $clustergroup to servernode $servernode Complete" -ForegroundColor 'Green';
			}
			
	$global:body = "Автоматическое обновление: Функция смены владельца службы $service в кластерной группе $clustergroup на кластере $cluster завершена";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Функция смены владельца службы $service завершена";
	send_email;
	logstamp; Write-Host " Function $FunctionNG : Function $FunctionNG end." -ForegroundColor 'Gray';
}

Function global:SetGet-ClusterGroupsNG () {
# example of function with template
# ClusterResourceGroup-$i
#$service = $args[0];
$clustername = $args[0];
$FunctionNG = "SetGet-ClusterGroupsNG"
logstamp; Write-Host " Start Function $FunctionNG : Determine and Set\Get ClusterGroup Roles on Cluster $clustername" -ForegroundColor 'Gray';

	try{
			$ClusterGroupsNG = Get-ClusterGroup -Cluster $clustername | Select-Object Name
			
			Foreach ($i in $ClusterGroupsNG){
				$ib = $i.name
				$iv = Test-Path variable:\ClusterResourceGroup$ib
				if ($iv -eq $false)
					{
					logstamp; Write-Host " Global Variable ClusterResourceGroup$ib does not exist" -ForegroundColor 'Green';
					logstamp; Write-Host " Writing Current Cluster Group to Dynamic Variable ClusterResourceGroup$ib" -ForegroundColor 'Green';
					New-Variable -Name "ClusterResourceGroup$ib" -Value $ib -Scope Global
					}
				else
					{
					logstamp; Write-Host " Global Variable ClusterResourceGroup$ib does exist" -ForegroundColor 'Red';
					logstamp; Write-Host " Removing Global Variable ClusterResourceGroup$ib" -ForegroundColor 'Magenta';
					Remove-variable "ClusterResourceGroup$ib" -Scope Global
					New-Variable -Name "ClusterResourceGroup$ib" -Value $ib -Scope Global
					}
				logstamp; Write-Host " Current Global Variable For Cluster Group $ib will be ClusterResourceGroup$ib" -ForegroundColor 'Green';
			
				}
			}
	catch{
	   #########################################################
	   $messageNG = " Function $FunctionNG : Determine and Set\Get ClusterGroup Roles on Cluster $clustername Failed!"
	   $bodyNG = "Function $FunctionNG : Determine and Set\Get ClusterGroup Roles on Cluster $clustername Failed!";
	   $subjectNG = "Function $FunctionNG have Errors!"
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   NotificationNG;
	   XwaitNG;
			}
	finally{
			logstamp; Write-Host " Function $FunctionNG : Determine and Set\Get ClusterGroup Roles on Cluster $clustername Complete" -ForegroundColor 'Green';
			}
		return $ClusterGroupsNG;
logstamp; Write-Host " Function $FunctionNG : Function $FunctionNG end." -ForegroundColor 'Gray';
}

Function global:SuperMove-ClusterGroupsNG () {
# example of function with template
# ClusterResourceGroup-$i
$ClusterGroupsNG = $args[0];
$Servernode = $args[1];
$FunctionNG = "SuperMove-ClusterGroupsNG"
logstamp; Write-Host " Start Function $FunctionNG : Move All ClusterGroups to servernode $servernode" -ForegroundColor 'Gray';

	try{

			Foreach ($i in $ClusterGroupsNG){
				$ib = $i.name
				$iv = Test-Path variable:\ClusterResourceGroup$ib
				if ($iv -eq $false)
					{
					logstamp; Write-Host " Global Variable ClusterResourceGroup$ib does not exist" -ForegroundColor 'Yellow';
					logstamp; Write-Host " Writing Current Cluster Group to Dynamic Variable ClusterResourceGroup$ib" -ForegroundColor 'Green';
					#New-Variable -Name "ClusterResourceGroup-$i" -Value $ib -Scope Global
					logstamp; Write-Host " !!! Global Variable ClusterResourceGroup$ib does not exist !!!" -ForegroundColor 'Magenta';
					}
				else
					{
					logstamp; Write-Host " Global Variable ClusterResourceGroup$ib does exist" -ForegroundColor 'Green';
					logstamp; Write-Host " Start Moving Variable ClusterResourceGroup$ib to $Servernode" -ForegroundColor 'Green';
					$select = Get-Variable ClusterResourceGroup$ib -Valueonly
					Move-ClusterResourceNG $select $Servernode $clustername
					logstamp; Write-Host " Removing Global Variable ClusterResourceGroup$ib" -ForegroundColor 'Magenta';
					Remove-variable "ClusterResourceGroup$ib" -Scope Global
					}
				}
			logstamp; Write-Host " Move All ClusterGroups to servernode $servernode Done!" -ForegroundColor 'Green';
			}
	catch{
	   #########################################################
	   $messageNG = " Function $FunctionNG : Determine and Set\Get ClusterGroup Roles on Cluster $clustername Failed!"
	   $bodyNG = "Function $FunctionNG : Determine and Set\Get ClusterGroup Roles on Cluster $clustername Failed!";
	   $subjectNG = "Function $FunctionNG have Errors!"
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   NotificationNG;
	   XwaitNG;
			}
	finally{
			logstamp; Write-Host " Function $FunctionNG : Determine and Set\Get ClusterGroup Roles on Cluster $clustername Complete" -ForegroundColor 'Green';
			}
			return $ClusterGroupsNG;
logstamp; Write-Host " Function $FunctionNG : Function $FunctionNG end." -ForegroundColor 'Gray';
}

Function global:SetGet-ClusterResourceNG () {
# example of function with template
# ClusterServiceResource-$i
#$service = $args[0];
$clustername = $args[0];
$FunctionNG = "SetGet-ClusterResourceNG"
logstamp; Write-Host " Start Function $FunctionNG : Determine and Set\Get Cluster Group Services Resources on Cluster $clustername" -ForegroundColor 'Gray';

	try{
			$ClusterServiceResourcesNG = Get-ClusterResource -Cluster $clustername | Select-Object Name
			Foreach ($i in $ClusterServiceResourcesNG){
				$ib = $i.name
				$iv = Test-Path variable:\ClusterServiceResource$ib
				if ($iv -eq $false)
					{
					logstamp; Write-Host " Global Variable ClusterServiceResource$ib does not exist" -ForegroundColor 'Green';
					logstamp; Write-Host " Writing Current Cluster Group to Dynamic Variable ClusterServiceResource$ib" -ForegroundColor 'Green';
					New-Variable -Name "ClusterServiceResource$ib" -Value $ib -Scope Global
					}
				else
					{
					logstamp; Write-Host " Global Variable ClusterServiceResource$ib does exist" -ForegroundColor 'Red';
					logstamp; Write-Host " Removing Global Variable ClusterServiceResource$ib" -ForegroundColor 'Magenta';
					Remove-variable "ClusterServiceResource$ib" -Scope Global
					New-Variable -Name "ClusterServiceResource$ib" -Value $ib -Scope Global
					}
				logstamp; Write-Host " Current Global Variable For Cluster Group $ib will be ClusterServiceResource$ib" -ForegroundColor 'Green';
			
				}
			}
	catch{
	   #########################################################
	   $messageNG = " Function $FunctionNG : Determine and Set\Get Cluster Group Services Resources on Cluster $clustername Failed!"
	   $bodyNG = "Function $FunctionNG : Determine and Set\Get Cluster Group Services Resources on Cluster $clustername Failed!";
	   $subjectNG = "Function $FunctionNG have Errors!"
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   NotificationNG;
	   XwaitNG;
			}
	finally{
			logstamp; Write-Host " Function $FunctionNG : Determine and Set\Get Cluster Group Services Resources on Cluster $clustername Complete" -ForegroundColor 'Green';
			}
		return $ClusterGroupsNG;
logstamp; Write-Host " Function $FunctionNG : Function $FunctionNG end." -ForegroundColor 'Gray';
}


#$servernode = "app1"
#$clustername = "core-cluster"
#SetGet-ClusterGroupsNG $clustername
#SuperMove-ClusterGroupsNG $ClusterGroupsNG $servernode