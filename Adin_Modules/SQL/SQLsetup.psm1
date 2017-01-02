#[CmdletBinding()]  
[CmdletBinding()]  

param(
[String]$ScriptPath,
[String]$env
)

#########################################################
# Start: Executing SQL scripts
#########################################################
#Установка имени инстанса
#$global:SQLinstance = "SQL12LISTENER"
#Директория с скриптами которые необходимо выполнить
#$global:DirectoryWithSQLrequests = "$ScriptPath\Database\Setup"
#Директория с выполнеными скриптами
#$global:DirectoryWithCompletedSQLrequests = "$ScriptPath\Database\Completed"
#Директория с Ошибочно выполненными скриптами
#$global:DirectoryWithCrashedSQLrequests = "$ScriptPath\Database\Crashed"
#Директория с модулем PSSQL
#$global:DirectoryWithSQLmodule = "$ScriptPath\Adin_Modules\SQLPS"
#Директория с выполнеными скриптами на Live
#$DirectoryWithCompletedSQLrequests = "$ScriptPath\Database\Completed\Live"
#Директория с выполнеными скриптами на Stage
#$DirectoryWithCompletedSQLrequests = "$ScriptPath\Database\Completed\Stage"
#Директория с выполнеными скриптами на Test
#$DirectoryWithCompletedSQLrequests = "$ScriptPath\Database\Completed\Test"
#Директория с Старыми выполненными скриптами
#$DirectoryWithOldSQLrequests = "$ScriptPath\Database\Old\Test"
#Директория с Старыми выполненными скриптами
#$DirectoryWithOldSQLrequests = "$ScriptPath\Database\Old\Stage"
#Директория с Старыми выполненными скриптами
#$DirectoryWithOldSQLrequests = "$ScriptPath\Database\Old\Live"
#Директория с Ошибочно выполненными скриптами на Stage
#$DirectoryWithCrashedSQLrequests = "$ScriptPath\Database\Crashed\Stage"
#Директория с Ошибочно выполненными скриптами на Test
#$DirectoryWithCrashedSQLrequests = "$ScriptPath\Database\Crashed\Test"

#########################################################
# Start: Executing SQL scripts
#########################################################
#Установка имени инстанса
$SQLinstance = "SQL12LISTENER"
#Директория с скриптами которые необходимо выполнить
$global:DirectoryWithSQLrequests = "$ScriptPath" + "\Database\Setup"
#Директория с выполнеными скриптами
$global:DirectoryWithCompletedSQLrequests = "$ScriptPath" + "\Database\Completed\$env"
#Директория с Старыми выполненными скриптами
$global:DirectoryWithOldSQLrequests = "$ScriptPath" + "\Database\Old\$env"
#Директория с Ошибочно выполненными скриптами
$global:DirectoryWithCrashedSQLrequests = "$ScriptPath" + "\Database\Crashed\$env"

#Директория с модулем PSSQL
$global:DirectoryWithSQLmodule = "$ScriptPath" + "\Adin_Modules\SQL\SQLPS"
#########################################################
# SQL update Functions
#########################################################

Function global:InitDeploySQL () {
$exedata = $args[0];
$global:body = "Автоматическое обновление: Запуск выполнения скрипта $exedata";
$global:subject = " [START MODULE] Автоматическое обновление: Запуск выполнения скрипта";
send_email;
try{
	Invoke-Sqlcmd -InputFile "$exedata" -ServerInstance "$SQLinstance" -ErrorAction Stop;
	$executestderror = "0"
	}
catch{
		logstamp; Write-Host " При выполении запроса $exedata возникли ошибки!" -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	
	$executestderror = "1"
	sleep 1
	
	switch ($env) 
				{ 
				"TEST" {
						CopyCrashedScript $exedata;
					}
				"STAGE" { 
						MoveCrashedScript $exedata;
					}
                "LIVE" { 
						MoveCrashedScript $exedata;
					}
				"DEV" { 
						CopyCrashedScript $exedata;
					}
				default {logstamp; Write-Host " ";}
				}
	}
finally{
	logstamp; Write-Host " Выполнение запроса $exedata завершено!" -ForegroundColor 'Green';
	if ($executestderror -eq "1")
	    {
		logstamp; Write-Host " Внимание! Выполненный скрипт $exedata не избежал ошибок!" -ForegroundColor 'Red' -backgroundcolor 'yellow';
	    $global:body = "Автоматическое обновление: При выполении запроса $exedata имеются ошибки!";
		$global:subject = " [ALERT MODULE] Автоматическое обновление: Выполнение запроса провалено";
		send_email;
		$executestderror = "0"
		}
	else
		{
		logstamp; Write-Host " Выполнение запроса $exedata окончено!" -ForegroundColor 'Green';
		$global:body = "Автоматическое обновление: Выполнение запроса $exedata успешно!";
		$global:subject = " [COMPLETE  MODULE] Автоматическое обновление: Выполнение запроса успешно";
		send_email;
		$executestderror = "0"
		}
}
}
Function global:DeploySQL () {

$global:body = "Автоматическое обновление: Запуск выполнения скриптов";
$global:subject = " [START MODULE] Автоматическое обновление: Запуск выполнения скриптов в базу данных";
send_email;

try{
foreach ($inputupdata in $inputsql) {InitDeploySQL $inputupdata};
$executestderror = "0"
}
catch{
Write-Host " Выполеннные скрипты содержат ошибки!" -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	
	$executestderror = "1"
	sleep 5
}
finally{
logstamp; Write-Host " Executing scripts complete!" -ForegroundColor 'Green';
	if ($executestderror -eq "1")
	    {
		$global:body = "Автоматическое обновление: Выполеннные скрипты содержат ошибки!";
		$global:subject = " [ALERT MODULE] Автоматическое обновление: Выполеннные скрипты содержат ошибки!";
		send_email;
		$executestderror = "0"
		}
	else
		{
		$global:body = "Автоматическое обновление: Скрипты выполнены без ошибок!";
		$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Скрипты выполнены без ошибок!";
		send_email;
		$executestderror = "0"
		}
	sleep 5
}
}



Function global:ExecuteSQLdeployScripts() {

if(!(Test-Path -Path $DirectoryWithSQLrequests ))
    {
    logstamp; Write-Host " SQL Выполнение: Нет папки с запросами на выполнение" -ForegroundColor 'Magenta';
	#########################################################
	$global:body = "Автоматическое обновление: SQL Выполнение: Нет папки с запросами на выполнение";
	$global:subject = " [INFO MODULE] Автоматическое обновление: Нет папки с запросами на выполнение";
	send_email;
	#########################################################
    }
else
	{
	logstamp; Write-Host " SQL Выполнение: Найдена папка с запросами" -ForegroundColor 'Magenta';	
	#########################################################
	$global:body = "Автоматическое обновление: SQL Выполнение: Найдена папка с запросами";
	$global:subject = " [START MODULE] Автоматическое обновление: Найдена папка с запросами";
	send_email;
	#########################################################
	
	$inputsql = Get-ChildItem $DirectoryWithSQLrequests | Foreach-Object {$DirectoryWithSQLrequests + "\" + $_.Name}
	
	if ($inputsql -eq $null)
		{
			logstamp; Write-Host " SQL Выполнение: Нет запросов в папке" -ForegroundColor 'Red';	
			
			switch ($env) 
				{ 
				"TEST" {
						##########################################################
						
						#########################################################
						CheckSQLCompleted #arg
						CheckSQLCrashed #arg
						
						logstamp; Write-Host " Среда $env - SQL запросы уже были выполнены" -ForegroundColor 'Green';
					}
				"STAGE" { 
						CheckSQLCompleted #arg
						CheckSQLCrashed #arg
				
						logstamp; Write-Host " Среда $env - SQL запросы уже были выполнены" -ForegroundColor 'Green';
					}
                "LIVE" { 
						CheckSQLCompleted #arg
						CheckSQLCrashed #arg
				
				
						logstamp; Write-Host " Среда $env - SQL запросы уже были выполнены" -ForegroundColor 'Green';
					}
				"DEV" { 
						CheckSQLCompleted #arg
						CheckSQLCrashed #arg
				
				
				
						logstamp; Write-Host " Среда $env - SQL запросы уже были выполнены" -ForegroundColor 'Green';
					}
				
				default {logstamp; Write-Host " ";}
				}

		}
	else
			{
			
			logstamp; Write-Host " SQL Выполение: Найдены запросы в папке" -ForegroundColor 'Red';	
			
			foreach ($echoscripts in $inputsql) {logstamp; Write-Host " Найден запрос SQL: $echoscripts" -ForegroundColor 'Green'; }
			
			switch ($env) 
				{ 
				"TEST" {
						CheckSQLCompleted;
						CheckSQLCrashed;
						MoveToOldSQLScript;
						DeploySQL;
						SQLDirectoryCompleteMaker;
						CopyCompleteScript;
						
					}
				"STAGE" { 
						CheckSQLCompleted;
						CheckSQLCrashed;
						MoveToOldSQLScript
						DeploySQL;
						SQLDirectoryCompleteMaker;
						CopyCompleteScript;
						
					}
                "LIVE" { 
						CheckSQLCompleted;
						CheckSQLCrashed;
						MoveToOldSQLScript;
						CheckSQLCompleted "$ScriptPath\Database\Completed\Stage";
						if ($completereqfolder -eq "true")
						{
							SQLDirectoryCompleteMaker;
							MoveCompleteScript;
						}
						else
						{
							DeploySQL;
							SQLDirectoryCompleteMaker;
							MoveCompleteScript;
						}
					}
				"DEV" { 
						CheckSQLCompleted;
						CheckSQLCrashed;
						MoveToOldSQLScript;
						DeploySQL;
						SQLDirectoryCompleteMaker;
						MoveCompleteScript;
					}
				
				default {logstamp; Write-Host " ";}
				}

			}
	}
}

Function CheckSQLCompleted() {
[CmdletBinding()]  

param(
[bool]$DirectoryWithCompletedSQLrequests
)
if(!(Test-Path -Path $DirectoryWithCompletedSQLrequests ))
				{
				logstamp; Write-Host " SQL Выполнение: Нет папки с уже выполненными запросами" -ForegroundColor 'Magenta';	
				$completereqfolder = "false"
				}	
				else
				{
				$completereqfolder = "true"
				$completedinputsql = Get-ChildItem $DirectoryWithCompletedSQLrequests | Foreach-Object {$DirectoryWithCompletedSQLrequests + "\" + $_.Name};
				foreach ($completedechoscripts in $completedinputsql) {
				logstamp; Write-Host " SQL запрос уже был выполнен: $completedinputsql" -ForegroundColor 'Green'; }
				
				}

}

Function FirstCheckSQLCompletedFolderParent() {
[CmdletBinding()]  

param(
[bool]$DirectoryWithCompletedSQLrequests
)

if(!(Test-Path -Path $DirectoryWithCompletedSQLrequests ))
				{
				logstamp; Write-Host " SQL Выполнение: Нет папки с уже выполненными запросами" -ForegroundColor 'Magenta';	
				$completereqfolder = "false"
				}	
				else
				{
				$completereqfolder = "true"
				$completedinputsql = Get-ChildItem $DirectoryWithCompletedSQLrequests | Foreach-Object {$DirectoryWithCompletedSQLrequests + "\" + $_.Name};
				foreach ($completedechoscripts in $completedinputsql) {
				logstamp; Write-Host " SQL запрос уже был выполнен: $completedinputsql" -ForegroundColor 'Green'; 
				$globalcompletedcount++
				}
				
				logstamp; Write-Host " Количество элементов в папке: $globalcompletedcount" -ForegroundColor 'Green'; }
				return $globalcompletedcount
}

Function CheckSQLCrashed() {
[CmdletBinding()]  

param(
[bool]$DirectoryWithCrashedSQLrequests
)
if(!(Test-Path -Path $DirectoryWithCrashedSQLrequests))
				{
				logstamp; Write-Host " SQL Выполнение: Нет папки с запросами которые выполнились с ошибками" -ForegroundColor 'Magenta';
				$crashedreqfolder = "false"
				}	
				else
				{
				$crashedreqfolder = "true"
				$crashedinputsql = Get-ChildItem $DirectoryWithCrashedSQLrequests | Foreach-Object {$DirectoryWithCrashedSQLrequests + "\" + $_.Name}
				logstamp; Write-Host " SQL Выполнение: Найдена папка с запросами которые выполнились с ошибками" -ForegroundColor 'Red';
				foreach ($completedechoscripts in $crashedinputsql) {
				logstamp; Write-Host " SQL запрос выполненный с ошибкой $crashedinputsql" -ForegroundColor 'Green'; }
				}

}

Function SQLDirectoryCompleteMaker () {

if(!(Test-Path -Path $DirectoryWithCompletedSQLrequests )){
			logstamp; Write-Host " Создание директории с выполненными скриптами" -ForegroundColor 'Gray';
			New-Item -ItemType directory -Path $DirectoryWithCompletedSQLrequests
			}

}

Function MoveCompleteScript() {
$inputsql = $args[0];
foreach ($deletescripts in $inputsql) 
				{
				logstamp; Write-Host " SQL запрос для перемещения: $deletescripts" -ForegroundColor 'Magenta'; 
				move-item -path $deletescripts -destination $DirectoryWithCompletedSQLrequests
				}
}

Function CopyCompleteScript() {
$inputsql = $args[0];
foreach ($deletescripts in $inputsql) 
				{
				logstamp; Write-Host " SQL запрос для перемещения: $deletescripts" -ForegroundColor 'Magenta'; 
				copy-item -path $deletescripts -destination $DirectoryWithCompletedSQLrequests
				}
}

Function MoveCrashedScript() {
$crashedscript = $args[0];
	if(!(Test-Path -Path $DirectoryWithCrashedSQLrequests )){
	logstamp; Write-Host " Создание директории с скриптами которые содержали ошибки при выполнении" -ForegroundColor 'Red';
	New-Item -ItemType directory -Path $DirectoryWithCrashedSQLrequests
	}
	move-item -path $crashedscript -destination $DirectoryWithCrashedSQLrequests
}
Function CopyCrashedScript() {
$crashedscript = $args[0];
	if(!(Test-Path -Path $DirectoryWithCrashedSQLrequests )){
	logstamp; Write-Host " Создание директории с скриптами которые содержали ошибки при выполнении" -ForegroundColor 'Red';
	New-Item -ItemType directory -Path $DirectoryWithCrashedSQLrequests
	}
	copy-item -path $crashedscript -destination $DirectoryWithCrashedSQLrequests
}

Function MoveToOldSQLScript() {
#$oldscript = $args[0];

if(!(Test-Path -Path $DirectoryWithOldSQLrequests )){
	logstamp; Write-Host " Перемещение старых скриптов" -ForegroundColor 'Red';
	New-Item -ItemType directory -Path $DirectoryWithOldSQLrequests
	}

$Oldsql1 = Get-ChildItem $DirectoryWithCompletedSQLrequests | Foreach-Object {$DirectoryWithCompletedSQLrequests + "\" + $_.Name}
$Oldsql2 = Get-ChildItem $DirectoryWithCrashedSQLrequests | Foreach-Object {$DirectoryWithCrashedSQLrequests + "\" + $_.Name}

foreach ($oldscript in $Oldsql1) {
move-item -path $oldscript -destination $DirectoryWithOldSQLrequests
}

foreach ($oldscript in $Oldsql2) {
move-item -path $oldscript -destination $DirectoryWithOldSQLrequests
}
	
}
