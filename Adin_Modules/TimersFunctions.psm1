#########################################################
# Timer Functions
#########################################################

Function global:BackUpTimerApplication {
$TimerValue = $args[0];
$BackupDestination = $args[1];
logstamp; Write-Host " Запуск функции резервного копирования сервиса $TimerValue" -ForegroundColor 'Gray';
logstamp; Write-Host " Создание резервной копии сервиса $TimerValue" -ForegroundColor 'Gray';

		$global:body = "Запущена функция резервного копирования сервиса $TimerValue";
		$global:subject = " [START MODULE] Автоматическое обновление: Создание резервной копии сервиса $TimerValue";
		send_email;
 try{
		$FullPathToZiipedTimer = "$BackupDestination" + "\" + "$TimerzipFilename"
		write-zip $TimerPath ($FullPathToZiipedTimer)
	 }
 catch{
	 logstamp; Write-Host " Процесс создания резервной копии завершен не удачно. Отправка почты. Процесс ожидает действия оператора." -ForegroundColor 'Red';
	 $body = "Сервис $TimerValue - Процесс создания резервной копии завершен не удачно. ";
	 $subject = " [FAIL MODULE] Автоматическое обновление: Резервная копия не создана.";
	 send_email;
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}

	 #$BackupTryToContinue = Read-Host
  If ($BackupTryToContinue -eq "X") 
     {logstamp; Write-Host " Ваш выбор: остановить процесс" -ForegroundColor 'Red';
	 logstamp; Write-Host " До завершения осталось 10 секунд" -ForegroundColor 'Red';
	 exit;
	 }
	else{logstamp; Write-Host " Ваш выбор: продолжить процесс" -ForegroundColor 'Green';}
	}
 finally{
     logstamp; Write-Host "Процесс выполнения функции резервного копирования сервиса завершен. Пожалуйста, проверьте почту."  -ForegroundColor 'Green';
	     }
 logstamp; Write-Host " Стандартное ожидание: Ожидание после резервного копирования сервиса $TimerValue" -ForegroundColor 'Gray';
 Sleep 5
 
		$global:body = "Cервис $TimerValue - Процесс выполнения функции резервного копирования сервиса завершен.";
		$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Создание резервной копии сервиса $TimerValue";
		send_email;
 
 logstamp; Write-Host " Функция резервного копирования завершена" -ForegroundColor 'Gray';
 }
 
Function global:UpdateTimerApplicationFunction {
[CmdletBinding()] 
	param(            
        [Parameter(Position = 0, Mandatory=$true, ValueFromPipeline=$false)]            
        [string]$DisableBackup,            
        [Parameter(Position = 1, Mandatory=$true, ValueFromPipeline=$false)]            
        [string]$env		
	)

#$TimerValue = $args[0];
logstamp; Write-Host " Запуск функции обновления сервисов" -ForegroundColor 'Gray';
logstamp; Write-Host " Начало процесса обновления" -ForegroundColor 'Gray';

		$global:body = "Запущена функция обновления сервисов";
		$global:subject = " [START MODULE] Автоматическое обновление: Запуск функции обновления сервисов";
		send_email;

 try{
    logstamp; Write-Host " Проверка таймеров на необходимость обновлений" -ForegroundColor 'Gray';
	if ($FAScluster -eq $NULL) {
			logstamp; Write-Host " Обновление таймеров не требуется" -ForegroundColor 'Yellow';
		}
	else{
			logstamp; Write-Host " Обновление таймеров требуется" -ForegroundColor 'Green';
			logstamp; Write-Host " Подготовлены к обновлению: $FAScluster.Values" -ForegroundColor 'Gray';
			foreach ($element in $FAScluster){
				logstamp; Write-Host " Тут мы приехали с массивом таймеров на обновление" -ForegroundColor 'White';
				$Value = $element.Values
				logstamp; Write-Host " Имя таймера: $Value" -ForegroundColor 'White';
				$Drive = $element.Keys 
				logstamp; Write-Host " Имя диска: $Drive" -ForegroundColor 'White';
				logstamp; Write-Host " Собираем полное имя таймера" -ForegroundColor 'White';
				$TimerValue = "$value" + "-timer"
				$NewTimerValue = "exampleTimer." + "$value" + ".zip"
				logstamp; Write-Host " Полное имя таймера: $TimerValue" -ForegroundColor 'White';
				logstamp; Write-Host " Собираем предварительный путь" -ForegroundColor 'White';
				$TimerPrepath = "$Value" + ".example.loc" + "\" + "$value" + ".timer\"
				logstamp; Write-Host " Предварительный путь: $TimerPrepath" -ForegroundColor 'White';
				logstamp; Write-Host " Собираем путь до места работы таймера" -ForegroundColor 'White';
				$TimerPath = "\\core-$Value\$Drive\wwwsites\example\$TimerPrepath";
				$PathToTimerRestore = "\\core-$Value\$Drive\wwwsites\example\" + "$Value" + ".example.loc" + "\"
				logstamp; Write-Host " Рабочая директория таймера: $TimerPath" -ForegroundColor 'White';
				logstamp; Write-Host " Имя архива для создания резервной копии текущего таймера." -ForegroundColor 'White';
				$now=get-Date
				$dy=$now.Day.ToString()
				$hr=$now.Hour.ToString()
				$mi=$now.Minute.ToString()
				$timeto = "$dy.$hr.$mi"
				logstamp; Write-Host " Текущее время $timeto" -ForegroundColor 'Green';
				$TimerZipFilename = "$value" + "-timer-" + "$timeto" +".zip"
				logstamp; Write-Host " Имя фаила резервной копии: $TimerZipFilename" -ForegroundColor 'White';
				logstamp; Write-Host " Собираем Путь к архиву таймера которым будем обновлять таймер." -ForegroundColor 'White';
				$TimerPathZipFile = "$ScriptPath" + "\" + "exampleTimer." + "$value" + ".zip"
				logstamp; Write-Host " Путь к архиву таймера которым будем обновлять сервис: $TimerPathZipFile" -ForegroundColor 'White';
				logstamp; Write-Host " Вычисляем какая нода кластера исполняет таймер в данный момент." -ForegroundColor 'White';
				logstamp; Write-Host " Выполняем команду Get-ClusterResourceOwnerNG с значениями: $TimerValue $clustername" -ForegroundColor 'White';
				Get-ClusterResourceOwnerNG $TimerValue $clustername
				logstamp; Write-Host " Забираем из всего об этом сервисе только ноду владельца, и присваиваем переменную" -ForegroundColor 'White';
				$CurrentOwnerServiceNode = Get-Variable ClusterResourceOwner$TimerValue -Valueonly
				logstamp; Write-Host " Получение значения получившейся переменной: Владелец роли - $CurrentOwnerServiceNode" -ForegroundColor 'White';
				logstamp; Write-Host " Останавливаем таймер. Тепеерь Знаем где, как и что останавливать." -ForegroundColor 'White';
				Stop-ClusterResourceNG $TimerValue $clustername
				
				
				if($DisableBackup -eq "true"){
					logstamp; Write-Host " BackUP: Отключен" -ForegroundColor 'Yellow';
				}
				else{
					logstamp; Write-Host " BackUP: Включен" -ForegroundColor 'Yellow';
					logstamp; Write-Host " Делаем резервную копию таймера, предварительно создав директорию под бекапы." -ForegroundColor 'White';
					MakeBackupFolder $CurrentOwnerServiceNode
					logstamp; Write-Host " Определяем таргет для бекапа." -ForegroundColor 'White';
					$TargetBackupDir = "\\$CurrentOwnerServiceNode\$backupDIR\$today"
					logstamp; Write-Host " Создаем резервную копию" -ForegroundColor 'White';
					BackUpTimerApplication $Value $TargetBackupDir;
				}
				sleep 100
				UpdateTimer;
				sleep 10
				if($env -eq "TEST"){
					$m = "service"
					$JobsXMLfullPath = $PathToTimerRestore + "$Value" + ".timer" +"\Configuration\JobsList.xml"
						if ($Value -eq $m){
							logstamp; Write-Host " Убираем значение MTTDailyRegisterJob из Service.timer" -ForegroundColor 'White';
							ChangeTimerJobsXML $JobsXMLfullPath;
						}
				}
				
				logstamp; Write-Host " Запускаем таймер" -ForegroundColor 'White';
				#
				sleep 10
				#
				Start-ClusterResourceNG $TimerValue $clustername
				logstamp; Write-Host " Закончили!" -ForegroundColor 'White';
			}
	
		}
	}
 catch{
											$err = $_.Exception;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											while( $err.InnerException ) {
											$err = $err.InnerException;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											}
	logstamp; Write-Host " В процессе обновления возникли ошибки. Отправка почты. Ожидание команды от оператора." -ForegroundColor 'Red';
	 
	$global:body = "Обновление сервисов прошло с ошибками, проверьте журнал событий";
	$global:subject = " [FAIL MODULE] Автоматическое обновление: Обновление сервисов прошло с ошибками";
	send_email;
	 
	 #$BackupTryToContinue = Read-Host
  If ($BackupTryToContinue -eq "X") 
     {logstamp; Write-Host " Выбор: остановить процесс" -ForegroundColor 'Red';
	 exit;
	 }
	else{logstamp; Write-Host " Выбор: продолжить процесс" -ForegroundColor 'Green';}
	}
 finally{
     logstamp; Write-Host " Процесс обновления завершен. Проверьте почту на предмет ошибок"  -ForegroundColor 'Green';
	 logstamp; Write-Host " Процесс обновления завершен. Проверьте почту на предмет ошибок"  -ForegroundColor 'Magenta';
	     }
 logstamp; Write-Host " Ожидание после процесса обновления таймеров" -ForegroundColor 'Gray';
 
 Sleep 5
 
	$global:body = "Обновление сервисов завершено";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Обновление сервисов завершено";
	send_email;
 
 logstamp; Write-Host " Функции обновления сервисов завершена" -ForegroundColor 'Gray';
 }

Function global:UpdateTimer() {
$TimerValue = $args[0];
$Aworker = $args[1];
$TimerPathZipFile = $args[2];
$TimerPathDestination = $args[3];
$TimerPathDestinationReal = $TimerPathDestination + "\" + "$Aworker" + ".timer"

logstamp; Write-Host " Запуск функции: Обновление таймера - $TimerValue" -ForegroundColor 'Magenta';

		$global:body = "Запущена функция обновления таймера - $TimerValue";
		$global:subject = " [START MODULE] Автоматическое обновление: Обновление таймера - $TimerValue";
		send_email;

		try{
			logstamp; Write-Host " Попытка обновить сервис $TimerValue на сервере $Aworker" -ForegroundColor 'Green';
			logstamp; Write-Host " Путь к архиву с обновлением: $TimerPathZipFile" -ForegroundColor 'Green';
			logstamp; Write-Host " Создание сессии на сервер $CurrentOwnerServiceNode" -ForegroundColor 'Green';
			$session=New-PSsession -Computername $CurrentOwnerServiceNode
			logstamp; Write-Host " Создание сессии завершено" -ForegroundColor 'Green';
			$TimerIISsiteName = "$value" + ".timer.example.com"
			Makefolders_and_copy $CurrentOwnerServiceNode;
			$removedistrpath = "e:\Distr\" + "$PathVer" + "\" + "$NewTimerValue"
			$DeployServiceEXElog = "e:\Distr\" + "$PathVer" + "\"+ "$value" + ".deploy.log"
			logstamp; Write-Host " DeployServiceEXElog $DeployServiceEXElog" -ForegroundColor 'Green';
			logstamp; Write-Host " Removedistrpath $removedistrpath" -ForegroundColor 'Green';
			logstamp; Write-Host " TimerIISsiteName $TimerIISsiteName" -ForegroundColor 'Green';
			logstamp; Write-Host " Выполнение команды обновления" -ForegroundColor 'Green';
			Invoke-Command -Session $session -ScriptBlock {param ($removedistrpath, $TimerIISsiteName, $DeployServiceEXElog); msdeploy.exe -verb:sync -source:package=$removedistrpath -dest:iisApp=$TimerIISsiteName > $DeployServiceEXElog } -ArgumentList $removedistrpath,$TimerIISsiteName,$DeployServiceEXElog 
		}
		catch{
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
			logstamp; Write-Host " Внимание! Обновление сервиса $TimerValue на сервере $Aworker не завершено!" -ForegroundColor 'Red';	
			
			$global:body = "Внимание! Обновление сервиса $TimerValue на сервере $Aworker не завершено!";
			$global:subject = " [FAIL MODULE] Автоматическое обновление: Обновление сервиса $TimerValue завершено с ошибками";
			send_email;
			
		}
		finally{
			logstamp; Write-Host " Функция обновления таймера $TimerValue на сервере $Aworker завершена" -ForegroundColor 'Green';	
		}
		
	$global:body = "Функция обновления таймера $TimerValue на сервере $Aworker завершена";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Обновление таймера - $TimerValue";
	send_email;
	
}

Function global:TimersToUpdate() {
$FAXcontinue = $args[0]; 
#########################################################
$FunctionNG = "CheckTimersToUpdate"
#########################################################

		$global:body = "Запуск функции проверки необходимости обновления таймеров";
		$global:subject = " [START MODULE] Автоматическое обновление: Проверка наличия сервисов в пакете";
		send_email;

logstamp; Write-Host " Запуск функции проверки необходимости обновления таймеров" -ForegroundColor 'Magenta';
logstamp; Write-Host " Проверка поступившего значения - пустое или нет" -ForegroundColor 'Green';
	if ($FAXcontinue -eq $null)
	{
		logstamp; Write-Host " Нет таймеров для обновления!" -ForegroundColor 'Green';
		$global:FAScluster = $NULL
		logstamp; Write-Host " Нет таймеров для обновления, значения проверяемых переменных пустые"  -ForegroundColor 'Red';	
		
		$global:body = "Нет таймеров для обновления, значения проверяемых переменных пустые";
		$global:subject = " [INFO MODULE] Автоматическое обновление: Проверка наличия сервисов в пакете";
		send_email;
	}
	else 
	{
		
		logstamp; Write-Host " Проверка поступившего значения на совпадение с схемой обновления";
		switch ($FAXcontinue) 
				{ 
				"A" {
											logstamp; Write-Host " Функция проверки необходимости обновления таймеров : Необходимо обновить только App-Timer"  -ForegroundColor 'Magenta';
											#$FAScluster = $SUPERARRAY1, $SUPERARRAY2
											$global:FAScluster = $SuperAppTimer
											
											$global:body = "Функция проверки необходимости обновления таймеров : Необходимо обновить только App-Timer";
											$global:subject = " [INFO MODULE] Автоматическое обновление: Проверка наличия сервисов в пакете";
											send_email;
											
											logstamp; Write-Host " Функция проверки необходимости обновления таймеров : ECHO = $global:FAScluster"  -ForegroundColor 'Red';
					}
				"S" { 			
											logstamp; Write-Host " Функция проверки необходимости обновления таймеров : Необходимо обновить только Service-Timer"  -ForegroundColor 'Magenta';
											$global:FAScluster = $SuperServiceTimer
											
											$global:body = "Функция проверки необходимости обновления таймеров : Необходимо обновить только Service-Timer";
											$global:subject = " [INFO MODULE] Автоматическое обновление: Проверка наличия сервисов в пакете";
											send_email;
											
											logstamp; Write-Host " Функция проверки необходимости обновления таймеров : ECHO = $global:FAScluster"  -ForegroundColor 'Red';	
					}
				"B" { 
											logstamp; Write-Host " Функция проверки необходимости обновления таймеров : Необходимо обновить оба таймера!"  -ForegroundColor 'Green';	
											$global:FAScluster = $SuperAppTimer, $SuperServiceTimer
											
											$global:body = "Функция проверки необходимости обновления таймеров : Необходимо обновить оба таймера!";
											$global:subject = " [INFO MODULE] Автоматическое обновление: Проверка наличия сервисов в пакете";
											send_email;
											
											logstamp; Write-Host " Функция проверки необходимости обновления таймеров : ECHO = $global:FAScluster.values"  -ForegroundColor 'Red';	
					}
				default {logstamp; Write-Host " Получено отличное от ожидаемых значение : продолжаем процесс";}
				}
	}
	logstamp; Write-Host "Функция проверки необходимости обновления таймеров завершена" -ForegroundColor 'Green';
	
	$global:body = "Функция проверки необходимости обновления таймеров завершена";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Проверка наличия сервисов в пакете";
	send_email;
	
	return $global:FAScluster
}

Function global:TimerCheckerZip() {
logstamp; Write-Host " Функция поиска дистрибутивов с таймерами" -ForegroundColor 'Green';

	if (Test-Path $TimerZipApp){
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: $TimerZipApp присутствует" -ForegroundColor 'Green';
		if (Test-Path $TimerZipService) {
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: $TimerZipService присутствует так же" -ForegroundColor 'Green';
		logstamp; Write-Host " Вывод: Оба таймера присутствуют и требуют обновления. Устанавливаем соответствующую переменную" -ForegroundColor 'Green';
		$global:FAXcontinue = "B"
		}
		else {
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: $TimerZipService No exists" -ForegroundColor 'Red';
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: Необходимо обновить только $TimerZipApp" -ForegroundColor 'Yellow';
		$global:FAXcontinue = "A"
		}
		
	}
	else
	{
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: $TimerZipApp не присутствует" -ForegroundColor 'Green';
		if (Test-Path $TimerZipService) {
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: $TimerZipService Присутствует" -ForegroundColor 'Green';
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: Необходимо обновить только $TimerZipService" -ForegroundColor 'Yellow';
		$global:FAXcontinue = "S"
		}
		else {
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: Внимание директория не содержит дистрибутивов!" -ForegroundColor 'Red';
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: Внимание директория не содержит дистрибутивов!" -ForegroundColor 'Yellow';
		logstamp; Write-Host " Функция поиска дистрибутивов с таймерами: Устанавливаем пустое значение в переменную!" -ForegroundColor 'Green';
		$global:FAXcontinue = $NULL
		}
		
	}
}

Function global:ClusteredTimerUpdate() {
[CmdletBinding()] 
	param(            
        [Parameter(Position = 0, Mandatory=$true, ValueFromPipeline=$false)]            
        [string]$DisableBackup,            
        [Parameter(Position = 1, Mandatory=$true, ValueFromPipeline=$false)]            
        [string]$env		
	)
TimerCheckerZip;
TimersToUpdate $FAXcontinue;
logstamp; Write-Host " Обновление приложение в среде $env" -ForegroundColor 'Green';
UpdateTimerApplicationFunction -DisableBackup $DisableBackup -Env $env;
}
