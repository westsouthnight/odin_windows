#########################################################
# Write: Main
#########################################################
#param(
#param(
#    [parameter(Position=0,Mandatory=$false)][string]$echoPathVersionTyped,
#    [parameter(Position=0,Mandatory=$false)][string]$env,
#	[parameter(Position=0,Mandatory=$false)][string]$RunnerExePath
#)

param(
	[parameter(Position=0,Mandatory=$false)][string]$env
)

$pathVER = $echoPathVersionTyped
Import-Module "$RunnerExePath\Adin_modules\LogRotate\LogRotate.psm1"
logstamp; Write-Host " RunnerExePath $RunnerExePath" -ForegroundColor 'Magenta' ;

#cd $RunnerExePath;
#$clustername = "core-cluster"

$ScriptPath2 = Split-Path -path (pwd)
$ScriptPath = "$ScriptPath2" + "\" + "$echoPathVersionTyped"
logstamp; Write-Host " Корневая директория запуска потока $ScriptPath" -ForegroundColor 'Magenta' ;
$ScriptPathLogFolder = "$ScriptPath" + "\DeployLog" + "\" + "$servernode"
$SMTPSettings = "$RunnerExePath\Adin_modules\SMTP\"+$env+"SMTPSettings.psm1"
Import-Module $SMTPSettings #-Verbose
CreateLogFolders $ScriptPathLogFolder;
TestVerFolderExists $ScriptPath $echoPathVersionTyped;
#$PathVerGetItem = Get-Item "$ScriptPath"
#$PathVER = $PathVerGetItem.name
LogRotate -Path $ScriptPathLogFolder -Include '*.log'
$logfile = Enable-LogFile -Path $ScriptPathLogFolder\"$servernode"-deploy.log
$TimerFolder = "$scriptPath" + "\exampleTimer"
$DeployBody = "$scriptPath" + "\deploy.txt"

#########################################################
# Write: Import
#########################################################

logstamp; Write-Host " $servernode : Начало загрузки модулей" -ForegroundColor 'Magenta' ;
logstamp; Write-Host " $servernode : Загрузка модулей Powershell";
#Set-ExecutionPolicy RemoteSignеed -force;
logstamp; Write-Host " $servernode : Загрузка модуля управления веб-сервером IIS WebAdministration";
Import-Module WebAdministration
logstamp; Write-Host " $servernode : Загрузка модуля управления отказоустойчивыми серверами FailoverClusters";
Import-Module FailoverClusters
logstamp; Write-Host " $servernode : Загрузка модуля управления кластерами балансировки нагрузки NetworkLoadBalancingClusters";
Import-Module NetworkLoadBalancingClusters
logstamp; Write-Host " $servernode : Загрузка модуля BestPractices";
Import-Module BestPractices
logstamp; Write-Host " $servernode : Загрузка модуля Pscx";
Import-Module Pscx
logstamp; Write-Host " $servernode : Загрузка модулей завершена";
Import-Module psworkflow

logstamp; Write-Host " $servernode : Script Path: $ScriptPath" 
logstamp; Write-Host " $servernode : Версия приложения: $PathVER" 

#########################################################
# Start: Definition of servers in an NLB
#########################################################
#########################################################
# Write: Settings and vars
#########################################################

logstamp; Write-Host " $servernode : Запуск определения значений и переменных" -ForegroundColor 'Green';
$sleep = 1;
logstamp; Write-Host " $servernode : Стандартное ожидание: $sleep";
$application = "application.example.com";
$applicationURL = "https://application.example.com/login";
logstamp; Write-Host " $servernode : Пул приложения: $application" -ForegroundColor 'Magenta';
logstamp; Write-Host " $servernode : Адрес приложения: $applicationURL" -ForegroundColor 'Magenta';
$Today = get-date -DisplayHint date -UFormat %C%y%m%d;
logstamp; Write-Host " $servernode : Текущая дата: $Today";
$DistrDIR = "e$\Distr"
logstamp; Write-Host " $servernode : Сетевая Директория дистрибутива: $DistrDIR";
$BkpDIR = "e:\backup"
logstamp; Write-Host " $servernode : Локальная Директория резервных копий: $BkpDIR";
$BackupDIR = "e$\backup"
logstamp; Write-Host " $servernode : Сетевая Директория резервных копий: $BackupDIR";
$InstallDIR = "e:\Distr\"
logstamp; Write-Host " $servernode : Локальная Директория установки: $InstallDIR";
$fullpath = $InstallDIR + $PathVER + "\"
logstamp; Write-Host " $servernode : Полный путь: $fullpath";
$EXAMPLE_TXTzip = $fullpath + "example.zip"
logstamp; Write-Host " $servernode : Имя архива приложения: $EXAMPLE_TXTzip";
$DeployEXElog = $fullpath + "deploy.log"
$destination = "$BkpDIR\$today\"
logstamp; Write-Host " $servernode : Путь назначения: $destination";

$now=get-Date
$dy=$now.Day.ToString()
$hr=$now.Hour.ToString()
$mi=$now.Minute.ToString()
$timeto = "$dy.$hr.$mi"
logstamp; Write-Host " Текущее время $timeto" -ForegroundColor 'Green';
#$zipFilename = "example.zip"
$zipFilename = "example-" + "$timeto" +".zip"
logstamp; Write-Host " $servernode : Имя архива резервной копии: $zipFilename";
$factDIR = "e:\wwwsites\example\application.example.com"
logstamp; Write-Host " $servernode : Фактическая директория: $factDIR";
logstamp; Write-Host " $servernode : Завершено: определение значений и переменных" -ForegroundColor 'Green';

$wwwApplicationDIR = "e$\wwwsites\example\application.example.com\"
$RelConfigurationDIR = "e$\wwwsites\example\application.example.com\Rel\Configuration"
$RelConfigurationDIRServices = "e$\wwwsites\example\application.example.com\Rel\Configuration\services.xml"
$RelConfigurationDIRGateways = "e$\wwwsites\example\application.example.com\Rel\Configuration\gateways.xml"

#########################################################
# Write: Mail Settings for Monitoring process ADIN
#########################################################

$From = "auto.report@example.ru"
$To = "deploy@example.ru"
$subject = "$env AUTO UPDATE: Deploy Mailer"
$SMTPServer = "md2.example.loc"
$SMTPUsername = "auto.report@example.ru"
$SMTPPassword = "7539148620qQ"
$global:SMTPPort = "25"
$emailattachment = $logfile.path








