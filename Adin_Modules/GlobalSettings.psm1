#########################################################
# Write: Main
#########################################################

param(
    [parameter(Position=0,Mandatory=$false)][string]$echoPathVersionTyped,
    [parameter(Position=0,Mandatory=$false)][string]$env
)

Function logstamp {
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

$global:clustername = "middle-cluster"
$global:RunnerExePath = $pwd.Path
$global:ScriptPath2 = Split-Path -path (pwd)
$global:ScriptPath = "$ScriptPath2" + "\" + "$echoPathVersionTyped"
$global:ScriptPathLogFolder = "$ScriptPath" + "\DeployLog"
CreateLogFolders $ScriptPathLogFolder;
TestVerFolderExists $ScriptPath $echoPathVersionTyped;
$global:PathVerGetItem = Get-Item "$ScriptPath"
$global:PathVER = $PathVerGetItem.name
LogRotate -Path $ScriptPathLogFolder -Include '*.log'
$global:logfile = Enable-LogFile -Path $ScriptPathLogFolder\$env-deploy.log
$global:TimerFolder = "$scriptPath" + "\exampleTimer"
$global:DeployBody = "$scriptPath" + "\deploy.txt"
$global:TimerZipApp = "$scriptPath" + "\exampleTimer.app.zip"
$global:TimerZipService = "$scriptPath" + "\exampleTimer.service.zip"

$global:StageSecureResourceName = "Core-Stage"
#########################################################
# Write: Import
#########################################################

logstamp; Write-Host " Начало загрузки модулей - Пожалуйста подождите" -ForegroundColor 'Magenta' ;
#logstamp; Write-Host " Загрузка модулей Powershell";

#logstamp; Write-Host " Загрузка модуля управления веб-сервером IIS WebAdministration";
Import-Module WebAdministration
#logstamp; Write-Host " Загрузка модуля управления отказоустойчивыми серверами FailoverClusters";
Import-Module FailoverClusters
#logstamp; Write-Host " Загрузка модуля управления кластерами балансировки нагрузки NetworkLoadBalancingClusters";
Import-Module NetworkLoadBalancingClusters
#logstamp; Write-Host " Загрузка модуля BestPractices";
Import-Module BestPractices
#logstamp; Write-Host " Загрузка модуля Pscx";
Import-Module Pscx
#logstamp; Write-Host " Загрузка модуля Psworkflow";
Import-Module psworkflow
#logstamp; Write-Host " Загрузка модулей завершена";



#logstamp; Write-Host " Script Path: $ScriptPath" 
#logstamp; Write-Host " Версия приложения: $PathVER" 

############################################
# Write: Settings and vars
#########################################################

#logstamp; Write-Host " Запуск определения значений и переменных" -ForegroundColor 'Green';
$global:sleep = 5;
logstamp; Write-Host " Стандартное ожидание: $sleep";
$global:application = "application.example.com";
$global:applicationURL = "https://application.example.com/login";
logstamp; Write-Host " Пул приложения: $application" -ForegroundColor 'Magenta';
logstamp; Write-Host " Адрес приложения: $applicationURL" -ForegroundColor 'Magenta';
$global:Today = get-date -DisplayHint date -UFormat %C%y%m%d;
logstamp; Write-Host " Текущая дата: $Today";
$global:DistrDIR = "e$\Distr"
logstamp; Write-Host " Сетевая Директория дистрибутива: $DistrDIR";
$global:BkpDIR = "e:\backup"
logstamp; Write-Host " Локальная Директория резервных копий: $BkpDIR";
$global:BackupDIR = "e$\backup"
logstamp; Write-Host " Сетевая Директория резервных копий: $BackupDIR";
$global:InstallDIR = "e:\Distr\"
logstamp; Write-Host " Локальная Директория установки: $InstallDIR";
$global:fullpath = $InstallDIR + $PathVER + "\"
logstamp; Write-Host " Полный путь: $fullpath";
$global:EXAMPLE_TXTzip = $fullpath + "example.zip"
logstamp; Write-Host " Имя архива приложения: $EXAMPLE_TXTzip";
$global:DeployEXElog = $fullpath + "deploy.log"
$global:destination = "$BkpDIR\$today\"
logstamp; Write-Host " Путь назначения: $destination";
$now=get-Date
$dy=$now.Day.ToString()
$hr=$now.Hour.ToString()
$mi=$now.Minute.ToString()
$timeto = "$dy.$hr.$mi"
$global:zipFilename = "example-" + "$timeto" + ".zip"
$global:factDIR = "e:\wwwsites\example\application.example.com"
logstamp; Write-Host " Фактическая директория: $factDIR";
logstamp; Write-Host " Завершено: определение значений и переменных" -ForegroundColor 'Green';

$global:wwwApplicationDIR = "e$\wwwsites\example\application.example.com\"
$global:RelConfigurationDIR = "e$\wwwsites\example\application.example.com\Rel\Configuration"
$global:RelConfigurationDIRServices = "e$\wwwsites\example\application.example.com\Rel\Configuration\services.xml"
$global:RelConfigurationDIRGateways = "e$\wwwsites\example\application.example.com\Rel\Configuration\gateways.xml"

#EXAMPLE_TXT SECTION CONFIG

#SECURE SECTION

$global:secureAppSettings = "e$\wwwsites\example\application.example.com\AppSettings.Release.config"
$global:secureWebConfig = "E$\wwwsites\example\application.example.com\Web.config"

#TIMERS SECTION

$global:servicetimerconfig = "E$\wwwsites\example\service-timer\example.Processing.Timer.exe.config"
$global:servicetimernlogconfig = "E$\wwwsites\example\service-timer\NLog.config"
$global:servicetimerjoblist = "E$\wwwsites\example\service-timer\Configuration\JobsList.xml"
$global:servicetimerappsettings = "E$\wwwsites\example\service-timer\AppSettings.Config"

$global:apptimerconfig = "E$\wwwsites\example\app-timer\example.Processing.Timer.exe.config"
$global:apptimernlogconfig = "E$\wwwsites\example\app-timer\NLog.config"
$global:apptimerjoblist = "E$\wwwsites\example\app-timer\Configuration\JobsList.xml"
$global:apptimerappsettings = "E$\wwwsites\example\app-timer\AppSettings.Config"

#$TimerJobsXMLPath = 




#########################################################
# Function: Work with memcache servers
#########################################################
  
$global:Memcacheservice = "memcached Server"
$global:Memcacheservers = @{
	"md1" = "md1";
	"md2" = "md2";
	}

#########################################################
# Function: Work with FA CLUSTER
#########################################################

$global:SuperAppTimer = @{"R$" = "app";}
$global:SuperServiceTimer = @{"R$" = "service";}
#$FAScluster = $SUPERARRAY1, $SUPERARRAY2

#########################################################
# END: Work with FA CLUSTER
#########################################################

return $timerfolder, $TimerZipApp, $timerZipService, $SuperAppTimer, $SuperServiceTimer






