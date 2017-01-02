[CmdletBinding()]
  param(
    [parameter(Mandatory=$True)] 
    [Object]$env, 
    [parameter(Mandatory=$True)] 
    [Object]$echoPathVersionTyped,
	[parameter(Mandatory=$True)] 
    [Object]$TimerUpdateState,
    [parameter(Mandatory=$True)] 
    [Object]$SecureUpdateState,
	[parameter(Mandatory=$True)] 
    [Object]$DisableBackup,
	[parameter(Mandatory=$True)] 
    [Object]$RERUNSQL,
	[parameter(Mandatory=$True)] 
    [Object]$SERVICEUPDATE
) 

Function send_email {
	$FunctionNG = "Отпарвка почты"
	#########################################################
	logstamp; Write-Host " Запуск функции $FunctionNG : Отправка почты"  -ForegroundColor 'Yellow';
	try{
			$encoding = [System.Text.Encoding]::UTF8
			Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Encoding $encoding
			}
	catch{
	   #########################################################
	   $messageNG = " Функция $FunctionNG : Провалилась!"
	   $bodyNG = "Функция $FunctionNG : Провалилась!";
	   $subjectNG = "Функция $FunctionNG Провалилась!"
       #########################################################
	   logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	   #########################################################
	   #LOOP:NotificationNG;
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
				$err = $err.InnerException;
				logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
				}
			#XwaitNG P;
			}
	finally{
       logstamp; Write-Host " Функция $FunctionNG : Завершена" -ForegroundColor 'Green';
	 		}
	#########################################################
	logstamp; Write-Host " Функция $FunctionNG : Отправка завершена" -ForegroundColor 'Yellow';
}

Function global:logstamp {
$now=get-Date
$yr=$now.Year.ToString()
$mo=$now.Month.ToString()
$dy=$now.Day.ToString()
$hr=$now.Hour.ToString()
$mi=$now.Minute.ToString()
$se=$now.Second
if ($mo.length -lt 2) {
$mo='0'+$mo #pad single digit months with leading zero
}
if ($dy.length -lt 2) {
$dy='0'+$dy #pad single digit day with leading zero
}
if ($hr.length -lt 2) {
$hr='0'+$hr #pad single digit hour with leading zero
}
if ($mi.length -lt 2) {
$mi='0'+$mi #pad single digit minute with leading zero
}
if ($se.length -lt 2) {
$se='0'+$se #pad single digit minute with leading zero
}
Write-Host "$yr.$mo.$dy.$hr.$mi.$se" -nonewline -ForegroundColor 'Blue';
}

#logstamp; Write-Host " Current Env $env" -ForegroundColor 'Green';
#logstamp; Write-Host " Current echoPathVersionTyped $echoPathVersionTyped" -ForegroundColor 'Green';
#logstamp; Write-Host " Current TimerUpdateState $TimerUpdateState" -ForegroundColor 'Green';
#logstamp; Write-Host " Current SecureUpdateState $SecureUpdateState" -ForegroundColor 'Green';
#logstamp; Write-Host " Current DisableBackup $DisableBackup" -ForegroundColor 'Green';
#sleep 10
$global:superenv = $env
$global:runsql_trigger = $RERUNSQL
############################ ----- ############################

#Import-Module ".\Adin_modules\GlobalFunctions.psm1"
Import-Module ".\Adin_modules\LogRotate\LogRotate.psm1"
Import-Module ".\Adin_modules\TimersFunctions.psm1"

Import-Module ".\Adin_modules\Memcache\MemcacheFunctions.psm1"
Import-Module ".\Adin_modules\Cluster\ClusterFunctions.psm1"

############################ --SMTP-- ############################

$SMTPSettings = "Adin_modules\SMTP\"+$env+"SMTPSettings.psm1"
Import-Module .\$SMTPSettings #-Verbose
#logstamp; Write-Host " Loaded SMTPSettings $SMTPSettings" -ForegroundColor 'Green';
############################ ----- ############################

############################ --ServersArray-- ############################
if ($SecureUpdateState -eq "true") {
$ServersArraySettings = "Adin_modules\ServersArray\"+$env+"Settings.psm1"
Import-Module .\$ServersArraySettings #-Verbose
logstamp; Write-Host " Loaded ServersArraySettings $ServersArraySettings" -ForegroundColor 'Green';
}
#logstamp; Write-Host " Loaded ServersArraySettings $ServersArraySettings" -ForegroundColor 'Green';
############################ ----- ############################

############################ --GlobalFuntions-- ############################
$GlobalFunctionsModule = "Adin_modules\GlobalFunctions.psm1"
Import-Module .\$GlobalFunctionsModule #-Verbose
#logstamp; Write-Host " Loaded GlobalFuntions $GlobalFunctionsModule" -ForegroundColor 'Green';
############################ ----- ############################

############################ --Global Settings-- ############################
$GlobalSettings = "Adin_modules\GlobalSettings.psm1"
#logstamp; Write-Host " Start Load Global GlobalSettings $GlobalSettings" -ForegroundColor 'Yellow';
Import-Module .\$GlobalSettings -ArgumentList $echoPathVersionTyped, $env
#logstamp; Write-Host " Loaded $GlobalSettings $GlobalSettings" -ForegroundColor 'Green';
############################ ----- ############################
$SQLSettings = "Adin_modules\SQL\SQLsetup.psm1"

logstamp; Write-Host " Loaded TimerFolder $TimerFolder" -ForegroundColor 'Green';

Import-Module .\$SQLSettings -ArgumentList $ScriptPath, $env

if ($env -eq "TEST") {
########################### ----- ############################
$ReplaceFuctions = "Adin_modules\Replace\"+$env+"ReplaceFunctions.psm1"
Import-Module ".\$ReplaceFuctions" #-Verbose
#logstamp; Write-Host " Loaded ReplaceFuctions $ReplaceFuctions" -ForegroundColor 'Green';
########################### ----- ############################
}

GetUserDatails;

#logstamp; Write-Host " Проверка введенных данных. Пожалуйста, подождите" -ForegroundColor 'Magenta' 
ValidateUserDetails $credentials;
#logstamp; Write-Host " Логин и пароль приняты. Спасибо!"  -ForegroundColor 'Green'

#########################################################
# Start Deploy 
#########################################################

$subject = "Автоматическое обновление: Целевая среда $Env !";
$body = "Cреда $Env : Запуск автоматического обновления среды. Приложение $application версии $PathVER";

switch ($env) 
				{ 
				"TEST" {
					    $global:To = "deploy@example.ru"
					}
				"STAGE" { 
						$global:To = "admins@example.ru", "testers@example.ru", "support@example.ru"
					}
                "LIVE" { 
						$global:To = "admins@example.ru", "testers@example.ru", "support@example.ru", "robo_check@example.ru", "commerce@example.ru", "developers@example.ru"
					}
				"DEV" { 
						$global:To = "admins@example.ru", "robot_ai@example.ru"
					}
				
				default {logstamp; Write-Host " Функция ожидания решения $FunctionNG : Стандартное значение продолжить процесс";}
				}
sleep 1
send_email;
sleep 1
#$To = "sysadmin@example.ru"
$To = "admins@example.ru", "testers@example.ru", "support@example.ru"
$global:To = "admins@example.ru", "testers@example.ru", "support@example.ru"
#########################################################
#Процедура обновления сервисов
#########################################################
if ($SERVICEUPDATE -eq "true"){
logstamp; Write-Host " Процедура обновления сервисов требуется"
switch ($env) 
				{ 
				"TEST" {
						logstamp; Write-Host " Среда $env - Начало обновления сервисов"
					    #ServicesUpdater;
						logstamp; Write-Host " Среда $env - Обновления сервисов завершено"
					}
				"STAGE" { 
						logstamp; Write-Host " Среда $env - Начало обновления сервисов"
						#ServicesUpdater;
						logstamp; Write-Host " Среда $env - Обновления сервисов завершено"
					}
                "LIVE" { 
						logstamp; Write-Host " Среда $env - Начало обновления сервисов"
						#ServicesUpdater;
						logstamp; Write-Host " Среда $env - Обновления сервисов завершено"
					}
				"DEV" { 
						logstamp; Write-Host " Среда DEV выполнение данных процедур не требуется";
					}
				
				default {logstamp; Write-Host " Функция ожидания решения $FunctionNG : Стандартное значение продолжить процесс";}
				}
}
else
{
logstamp; Write-Host " Процедура обновления сервисов не требуется, текущая среда $env"
}
#########################################################
#Процедура перед обновлением приложения
#########################################################


switch ($env) 
				{ 
				"TEST" {
					    PreDeploy $runsql_trigger;
					}
				"STAGE" { 
						PreDeploy $runsql_trigger;
					}
                "LIVE" { 
						PreDeploy $runsql_trigger;
					}
				"DEV" { 
						logstamp; Write-Host " Среда DEV выполнение данных процедур не требуется";
					}
				
				default {logstamp; Write-Host " Функция ожидания решения $FunctionNG : Стандартное значение продолжить процесс";}
				}

#PreDeploy;

#########################################################
#Процедура обновления таймера
#########################################################

if ($TimerUpdateState -eq "true") {

	switch ($env) 
				{ 
				"TEST" {
					    ClusteredTimerUpdate -DisableBackup $DisableBackup -Env $env;	
					}
				"STAGE" { 
						ClusteredTimerUpdate -DisableBackup $DisableBackup -Env $env;
					}
                "LIVE" { 
						ClusteredTimerUpdate -DisableBackup $DisableBackup -Env $env;
					}
				"DEV" { 
						logstamp; Write-Host " Среда DEV выполнение данных процедур не требуется";
					}
				
				default {logstamp; Write-Host " Функция ожидания решения $FunctionNG : Стандартное значение продолжить процесс";}
				}

};




#########################################################
#Процедура парралельного обновления приложения
#########################################################
Function SwitchDeploy{
try{
#logstamp; Write-Host " TARGET DistrDir ! $DistrDir !";
#logstamp; Write-Host " TARGET pathVER ! $pathVER !";
if ($SecureUpdateState -eq "true") {
        logstamp; Write-Host "Version defined";
		switch ($env) 
				{ 
				"TEST" {
					    logstamp; Write-Host " Обновление среды Test";
					    DeployParallel -NodesA $NodesA -echoPathVersionTyped $echoPathVersionTyped -RunnerExePath $RunnerExePath -superenv $superenv -DisableBackup $DisableBackup
						logstamp; Write-Host " Обновление среды Test завершено";
					}
				"STAGE" { 
						logstamp; Write-Host " Обновление среды Stage";
						logstamp; Write-Host " Определяем полрядок обновления среды Stage";
						Get-ClusterResourceOwnerNG $StageSecureResourceName $clustername
						logstamp; Write-Host " Забираем из всего об этом сервисе только ноду владельца, и присваиваем переменную" -ForegroundColor 'White';
						$CurrentTargetStageSecureResourceName = Get-Variable ClusterResourceOwner$StageSecureResourceName -Valueonly
						logstamp; Write-Host " Получение значения получившейся переменной: Владелец роли - $CurrentTargetStageSecureResourceName" -ForegroundColor 'White';
				
						if ($CurrentTargetStageSecureResourceName -eq "middle1")
							{
							logstamp; Write-Host " Владелец middle1 начинаем с него" -ForegroundColor 'White';
							SimpleDeploy -servernode "middle1" -DistrDir $DistrDir -pathVER $pathVER -DisableBackup $DisableBackup
							logstamp; Write-Host " Перемещаем Stage на middle2" -ForegroundColor 'White';
							Move-ClusterResourceNG "core-middle" "middle2" $clustername
							logstamp; Write-Host " Обновляем middle2" -ForegroundColor 'White';
							SimpleDeploy -servernode "middle2" -DistrDir $DistrDir -pathVER $pathVER -DisableBackup $DisableBackup
							}
						else
							{
							logstamp; Write-Host " Владелец middle2 начинаем с него" -ForegroundColor 'White';
							SimpleDeploy -servernode "middle2" -DistrDir $DistrDir -pathVER $pathVER -DisableBackup $DisableBackup
							logstamp; Write-Host " Перемещаем Stage на middle1" -ForegroundColor 'White';
							Move-ClusterResourceNG "core-middle" "middle1" $clustername
							logstamp; Write-Host " Обновляем middle1" -ForegroundColor 'White';
							SimpleDeploy -servernode "middle1" -DistrDir $DistrDir -pathVER $pathVER -DisableBackup $DisableBackup
							}
							#foreach ($NodeA in $NodesA) {SimpleDeploy -servernode $NodeA -DistrDir $DistrDir -pathVER $pathVER -DisableBackup $DisableBackup};
						logstamp; Write-Host " Обновление среды Stage завершено";
					}
                "LIVE" { 
						logstamp; Write-Host " Обновление среды Live";
                        #SecureStarterNG $NodesA $echoPathVersionTyped $credentials $RunnerExePath;					
                        DeployParallel -NodesA $NodesA -echoPathVersionTyped $echoPathVersionTyped -RunnerExePath $RunnerExePath -superenv $superenv -DisableBackup $DisableBackup
						logstamp; Write-Host " Обновление среды Live завершено";						
					}
				"DEV" { 
						logstamp; Write-Host " Обновление среды Dev";
						foreach ($NodeA in $NodesA) {SimpleDeploy -servernode $NodeA -DistrDir $DistrDir -pathVER $pathVER -DisableBackup $DisableBackup};
                        #SecureStarterNG $NodesA $echoPathVersionTyped $credentials $RunnerExePath;
						logstamp; Write-Host " Обновление среды Dev завершено";							
					}
				
				default {logstamp; Write-Host " Функция ожидания решения $FunctionNG : Стандартное значение продолжить процесс";}
				}

} Else {
        logstamp; Write-Host "Env not defined";
}
}
catch{
						$err = $_.Exception;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											while( $err.InnerException ) {
											$err = $err.InnerException;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
						}}
finally{}
}

SwitchDeploy;
#########################################################
#Процедура после обновления приложения
#########################################################

AfterDeploy $superenv;

#########################################################
# Process Auto Deploy Comlete
#########################################################

logstamp; Write-Host " Завершено: Автоматическое обновление сайта и сервисов на всех серверах завершено." -ForegroundColor 'Green';
#$To = "admins@example.ru, testers@example.ru, support@example.ru, pg@example.ru"
#$To = "sysadmin@example.ru, r.grigoryev@example.ru"
switch ($env) 
				{ 
				"TEST" {
					    $global:To = "deploy@example.ru"
					}
				"STAGE" { 
						$global:To = "admins@example.ru", "testers@example.ru", "support@example.ru"
					}
                "LIVE" { 
						$global:To = "admins@example.ru", "testers@example.ru", "support@example.ru", "robo_check@example.ru", "commerce@example.ru", "developers@example.ru"
					}
				"DEV" { 
						$global:To = "admins@example.ru", "robot_ai@example.ru"
					}
				
				default {logstamp; Write-Host " Функция ожидания решения $FunctionNG : Стандартное значение продолжить процесс";}
				}
$subject = "Автоматическое обновление среды $Env окончено!"
$body = "Cреда $Env : Автоматическое обновления среды окончено! Версия установленного приложения: $PathVER ";
#$body = Get-Content $DeployBody;
$LogFile | Disable-LogFile 
sleep 5
send_email;
#send_email;
sleep 1
exit;