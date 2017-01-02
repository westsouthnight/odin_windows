#########################################################
#  WorkFlow Functions
#########################################################

Workflow DeployParallel{
  [CmdletBinding()]  
Param
 (
  [Array]$NodesA,
  [String]$echoPathVersionTyped,
  [String]$RunnerExePath,
  [Object]$superenv,
  [String]$DisableBackup
 )

  ForEach -Parallel -throttlelimit 2 ($NodeA in $NodesA) 
  {
  
	
	sequence {

	powershell.exe $RunnerExePath\DeployOnly.ps1 -servernode $NodeA -echoPathVersionTyped $echoPathVersionTyped -RunnerExePath $RunnerExePath -superenv $superenv -DisableBackup $DisableBackup

	}
   
    Checkpoint-workflow
  } 
}

Function SimpleDeploy{
[CmdletBinding()] 
  param(
    [parameter(Mandatory=$True)] 
    [string]$servernode, 
    [parameter(Mandatory=$True)] 
    [string]$DistrDir,
	[parameter(Mandatory=$True)] 
    [string]$pathVER,
	[parameter(Mandatory=$True)] 
    [string]$DisableBackup
) 
  #Начало функции выкладки
  #Прием аргумента имени сервера для начала процесса
  #$servernode = $args[0];
  #Уведомление о начале процесса на конкретном сервере
  StartNotification;  
  #Создание директорий и копирование
  Makefolders_and_copy $servernode;
  #Создание сессии на сервер
  #$session = MakeSession $credentials $servernode;
  $session=New-PSsession -Computername $servernode
  #Удаленная загрузка необходимых модулей
  RemoteImportModules $session;
  #Остановка пулов
  StopIISpool $session;
  #Создание резервной копии приложения
  if($DisableBackup -eq "true"){
  logstamp; Write-Host " BackUP: Отключен" -ForegroundColor 'Yellow';
  }
  else{
  logstamp; Write-Host " BackUP: Включен" -ForegroundColor 'Yellow';
  BackUpApplication $session;
  }
  #BackUpApplication $session;
  #Обновление приложения
  DeployIISapp $session;
  #Запуск пула
  StartIISpool $session;
  #Путь к приложению по https
  $url = "https://application.example.com/login";
  #Начало проверки выложенного приложения
  #logstamp; Write-Host " Check: Site $url on $servernode" -ForegroundColor 'Yellow';
  #logstamp; Write-Host " Test: $servernode $url ..." -ForegroundColor 'Yellow';
  #Удаленный запуск проверки на реакцию открытия приложения
  $request_status_code_result = Invoke-command -Session $session -Scriptblock ${function:request_status_code}
  #Проверка ответа приложения
  RequestCheckFunction;
  #Получение версии развернутого приложения
  $ResponseGetStreamResultData = Invoke-command -Session $session -Scriptblock ${function:application_version_check}
  #Проверка версии выложенного приложения
  $version_check_result = version_check;
  VersionCheckFunction;
  #Уведомление об окончаниии процесса
  AfterCheckNotification;
  #Конец
  }


#########################################################
#  Main Functions
#########################################################

Function TestVerFolderExists {
 $Folder = $args[0];
 $PathVersionInserted = $args[1];
logstamp; Write-Host " Проверка наличия папки с приложением версии $PathVersionInserted" -ForegroundColor 'Magenta';
try{
				logstamp; Write-Host " Проверка пути - $Folder" -ForegroundColor 'Gray';
		if(!(Test-Path -Path $Folder )){
				logstamp; Write-Host " Папка не существует!" -ForegroundColor 'Red';
				#XwaitNG P;
			}
		else{
				logstamp; Write-Host " Папка существует!" -ForegroundColor 'Green';
		}
     }
 catch{
				$err = $_.Exception;
				logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
				while( $err.InnerException ) {
				$err = $err.InnerException;
				logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
				logstamp Write-Host " Проверка наличия папки провалилась!" -ForegroundColor 'Red';
		} 
 finally{
 logstamp; Write-Host " Проверка наличия папки завершена." -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Функиця проверки закончена." -ForegroundColor 'Gray';
 }
 }

Function TestFolderExists {
 $Folder = $args[0];
logstamp; Write-Host " Запуск функции проверки папки на существование: Папка для проверки - $Folder" -ForegroundColor 'Gray';
try{
				#logstamp; Write-Host " Test Folder $Folder Exists: Folder to test - $Folder" -ForegroundColor 'Green';
		if(!(Test-Path -Path $Folder )){
				logstamp; Write-Host " Тестируемая папка не существует:  Папка для проверки - $Folder" -ForegroundColor 'Red';
				#XwaitNG P;
			}
		else{
				logstamp; Write-Host " Тестируемая папка существует:  Папка для проверки - $Folder" -ForegroundColor 'Green';
				
		}
     }
 catch{
				$err = $_.Exception;
				logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
				$err = $err.InnerException;
				logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
				logstamp Write-Host " Проверка папки $Folder завершена с ошибкой!" -ForegroundColor 'Red';
		} 
 finally{
 logstamp; Write-Host " Функции проверки папки на существование завершена: Папка для проверки - $Folder" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Функция закончена." -ForegroundColor 'Gray';
 }
 }

Function send_email_with_attachment {
	$Attachment = $args[0];
	$FunctionNG = "Отпарвка почты"
	#########################################################
	logstamp; Write-Host " Запуск функции $FunctionNG : Отправка почты с вложением"  -ForegroundColor 'Yellow';
	try{
			$encoding = [System.Text.Encoding]::UTF8
			Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -Encoding $encoding -Attachment $Attachment
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

Function request_status_code {
$url = "https://application.example.com/login";
 [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true};
												$request = [System.Net.WebRequest]::Create($url);
												$request.Timeout = 300000;
												$response = $request.GetResponse();
                                                $ResponseGetStream = $response.GetResponseStream()
                                                $ResponseGetStreamResult = new-object System.IO.StreamReader $ResponseGetStream
                                                $ResponseGetStreamResultData = $ResponseGetStreamResult.ReadToEnd()
	return $request_status_code_response_result = $response.StatusCode
}
										
Function application_version_check {
$url = "https://application.example.com/login";
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true};
												$request = [System.Net.WebRequest]::Create($url);
												$request.Timeout = 300000;
												$response = $request.GetResponse();
                                                $ResponseGetStream = $response.GetResponseStream()
                                                $ResponseGetStreamResult = new-object System.IO.StreamReader $ResponseGetStream
                                                $ResponseGetStreamResultData = $ResponseGetStreamResult.ReadToEnd()
												return $ResponseGetStreamResultData
                                               
                                    } 
											
Function version_check {
 if ($ResponseGetStreamResultData -match "$pathVER")
                                                                {
                                                               #$body = "Checking site: Test $servernode $url Succeeded. Version Validation Math = OK . $PathVER";
                                                               #Write-Host " Test: $servernode $url Succeeded. Version Validation Math = OK" -ForegroundColor 'Green';
                                                               $VersionValidateResult = "OK"
													           [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null;
															   return $VersionValidateResult
                                                                }
                                                            Else
                                                            {
                                                                #Write-Host " Test: $servernode $url Fail. Version Validation Math = FAIL" -ForegroundColor 'Red';
                                                                $VersionValidateResult = "FAIL"
                                                                #$body = "Checking site: Test $servernode $url Failed! Please Stop process Auto Deploy. Version Validation Math = FAIL $PathVER";
                                                                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null;
																return $VersionValidateResult
                                                            }								
#send_email;															
}

Function Makefolders_and_copy {
logstamp; Write-Host " Запуск функции Makefolders_and_copy on $servernode" -ForegroundColor 'Gray';
$servernode = $args[0];
$TargetDistDir = "\\$servernode\$distrDIR\$pathVER"
if(!(Test-Path -Path $TargetDistDir )){
    logstamp; Write-Host " Создание директории для дистрибутива на сервере: $servernode" -ForegroundColor 'Gray';
    New-Item -ItemType directory -Path $TargetDistDir
}

$TargetBackupDir = "\\$servernode\$backupDIR\$today"
if(!(Test-Path -Path $TargetBackupDir )){
    logstamp; Write-Host " Создание директории для резервных копий на сервере $servernode" -ForegroundColor 'Gray';
    New-Item -ItemType directory -Path $TargetBackupDir
}

 try{
 
 logstamp; Write-Host " Копирование: Приложение версии $pathVER копируется на сервер $servernode" -ForegroundColor 'Gray';
 Copy-Item $scriptPath\* \\$servernode\$distrDIR\$pathVER\ -recurse;
 Sleep 10
 
     }
 catch{
logstamp; Write-Host " Копирование: Приложение версии $pathVER копируется на сервер $servernode не удалось!" -ForegroundColor 'Red';
		$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	   $body = "Копирование: Приложение версии $pathVER копируется на сервер $servernode не удалось!";
	   $subject = "Автоматическое обновление: Копирование на сервер $servernode провалено!";
	   send_email;
	   sleep 5
	   exit;
		} 
 finally{
 logstamp; Write-Host " Копирование: Приложение версии $pathVER копируется на сервер $servernode завершено" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Завершение функции создания папкок и копирования." -ForegroundColor 'Gray';
 }
 
Function global:MakeBackupFolder {
 $servernode = $args[0];
try{
$TargetBackupDir = "\\$servernode\$backupDIR\$today"
			if(!(Test-Path -Path $TargetBackupDir )){
New-Item -ItemType directory -Path $TargetBackupDir
			}
     }
 catch{
$err = $_.Exception;

			while( $err.InnerException ) {
			$err = $err.InnerException;
}
		}
 finally{
}
}

Function RemoteImportModules {
logstamp; Write-Host " Запуск функции загрузки модулей в удаленной сессии на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];
 logstamp; Write-Host " Запуск загрузки модулей в удаленной сессии на сервере: $servernode" -ForegroundColor 'Gray';
 try{
	Invoke-Command -Session $session -ScriptBlock {Import-Module NetworkLoadBalancingClusters};
	Invoke-Command -Session $session -ScriptBlock {Import-Module WebAdministration};
	Invoke-Command -Session $session -ScriptBlock {Import-Module BestPractices};
	Invoke-Command -Session $session -ScriptBlock {Import-module Pscx};
	 }
 catch{
	logstamp; Write-Host " Загрузка модулей завершена с ошибками: Отправка почты - Сервер $servernode" -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	   $body = "Загрузка модулей завершена с ошибками: Сервер $servernode";
	   $subject = "Автоматическое обновление: Загрузка модулей завершена с ошибками Сервер $servernode";
	   send_email;
	   sleep 5
	   exit;
       }
 finally{
		 logstamp; Write-Host " Загрузка модулей завершена - Сервер $servernode" -ForegroundColor 'Green';
		}
logstamp; Write-Host " Функция загрузки модулей завершена - Сервер $servernode" -ForegroundColor 'Gray';
}

Function DrainStopTheNode {
 logstamp; Write-Host " Запуск функции мягкого вывода из кластера балансировки нагрузки: Медленная остановка сервера - $servernode" -ForegroundColor 'Gray';
 $session = $args[0];
 logstamp; Write-Host " Начало медленной остановки сервера - $servernode" -ForegroundColor 'Gray';
 try{
    Invoke-Command -Session $session -ScriptBlock {Stop-NlbClusterNode $servernode -Drain -Timeout 300;};
	logstamp; Write-Host " Ожидание, после мягкого вывода сервера - $servernode" -ForegroundColor 'Gray';
	Sleep 120
	logstamp; Write-Host " Вывод сервера $servernode из кластера" -ForegroundColor 'Gray';
	Invoke-Command -Session $session -ScriptBlock {Stop-NlbClusterNode $servernode};
	}
 catch{
       logstamp; Write-Host " Мягкая остановка: Вывод сервера $servernode провалился. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	   $body = "Мягкая остановка сервера в кластере, Вывод сервера $servernode провалился";
	   $subject = "Автоматическое обновление: Мягкая остановка, Вывод сервера $servernode провалился";
	   send_email;
       }
 finally
	   {
	   logstamp; Write-Host " Мягкая остановка: Вывод сервера $servernode Завершен" -ForegroundColor 'Green';
	   }
 logstamp; Write-Host " Функция Мягкой остановка и вывода сервера $servernode завершена" -ForegroundColor 'Gray';
}

Function StopIISpool {
 logstamp; Write-Host " Запуск функции остановки пула приложения: Остановка пула на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];
 logstamp; Write-Host " Остановка пулов на сервере: $servernode" -ForegroundColor 'Gray';
 try{
     Invoke-command -Session $session -Scriptblock {param ($application);Stop-WebItem IIS:\AppPools\$application} -ArgumentList $application;
	 }
 catch{
     logstamp; Write-Host " Остановка пула на сервере: $servernode завершена с ошибками. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	 $body = "Остановка пула на сервере: $servernode завершена с ошибками.";
	 $subject = "Автоматическое обновление: Остановка пула на сервере $servernode завершена с ошибками.";
	 send_email;
	 #XwaitNG P;
	   }
 finally{
     logstamp; Write-Host " Остановка пула на сервере: $servernode завершена" -ForegroundColor 'Green';
        }	 
 logstamp; Write-Host " Ожидание после остановки пулов приложений на сервере: $servernode" -ForegroundColor 'Gray';
 Sleep 10
 logstamp; Write-Host " Функция остановки пулов приложений завершена" -ForegroundColor 'Gray';
}

Function BackUpApplication {
logstamp; Write-Host " Запуск функции резервного копирования приложения на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];
 logstamp; Write-Host " Создание резервной копии на сервере: $servernode" -ForegroundColor 'Gray';
 try{
	Invoke-command -Session $session -Scriptblock {param ($factDIR,$destination,$zipFilename);write-zip $factDIR ($destination + $zipFilename)} -ArgumentList $factDIR, $destination, $zipFilename;
	 }
 catch{
	 logstamp; Write-Host " Создание резервной копии на сервере: $servernode провалилось! Отправка почты. Процесс ожидает вмешательства оператора!" -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	 $body = "Создание резервной копии на сервере: $servernode провалилось! Процесс ожидает вмешательства оператора!";
	 $subject = "Автоматическое обновление: Создание резервной копии на сервере $servernode провалилось!";
	 send_email;
	 $BackupTryToContinue = Read-Host
  If ($BackupTryToContinue -eq "X") 
     {logstamp; Write-Host " Выбор: остановить процесс" -ForegroundColor 'Red';
	 exit;
	 }
	else{logstamp; Write-Host " Выбор: продолжить процесс" -ForegroundColor 'Green';}
	}
 finally{
     logstamp; Write-Host " Создание резервной копии на сервере: $servernode завершено! Отправка почты."  -ForegroundColor 'Green';
	     }
 logstamp; Write-Host " Стандартное ожидание после создания бекапа на сервере: $servernode" -ForegroundColor 'Gray';
 Sleep 10
 logstamp; Write-Host " Функция создания резервной копии завершена" -ForegroundColor 'Gray';
 }

Function DeployIISapp {
logstamp; Write-Host " Запуск функции обновления приложения на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];
 logstamp; Write-Host " Запуск обновления приложения до версии $PathVER на сервере $servernode" -ForegroundColor 'Gray';
 try{
    Invoke-Command -Session $session -ScriptBlock {param ($EXAMPLE_TXTzip, $DeployEXElog); msdeploy.exe -verb:sync -source:package=$EXAMPLE_TXTzip -dest:iisApp=application.example.com > $DeployEXElog} -ArgumentList $EXAMPLE_TXTzip;$DeployEXElog 
	 
	 #send log
	 
	 }
 catch{
	logstamp; Write-Host " Обновление приложения до версии $PathVER на сервере $servernode завершено с ошибками. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	 $body = "Обновление приложения до версии $PathVER на сервере $servernode завершено с ошибками.";
	 $subject = "Автоматическое обновление: Обновление приложения до версии $PathVER на сервере $servernode завершено с ошибками.";
	 send_email;
	}
 finally{
	logstamp; Write-Host " Обновление приложения до версии $PathVER на сервере $servernode завершено."  -ForegroundColor 'Green';
	}
 logstamp; Write-Host " Ожидание после обновления приложения до версии $PathVER на сервере $servernode" -ForegroundColor 'Gray';
 Sleep 10
 logstamp; Write-Host " Функция обновления приложения до версии $PathVER на сервере $servernode завершена." -ForegroundColor 'Gray'
}

Function send_email {
	$FunctionNG = "Отправка почты"
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

Function StartIISpool {
logstamp; Write-Host " Запуск функции включения пулов сайта на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];
 logstamp; Write-Host " Запуск пулов приложений на сервере $servernode";
 try{
		Invoke-command -Session $session -Scriptblock {param ($application);Start-WebItem IIS:\AppPools\$application} -ArgumentList $application;
     }
 catch{
        logstamp; Write-Host " Запуск пулов приложений на сервере $servernode провалился. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	    $body = "Запуск пулов приложений на сервере $servernode провалился";
		$subject = "Автоматическое обновление: Запуск пулов приложений на сервере $servernode провалился";
	    send_email;
		} 
 finally{
        logstamp; Write-Host " Запуск пулов приложений на сервере $servernode завершен." -ForegroundColor 'Green';
 }		
 Sleep 10
 logstamp; Write-Host " Функция запуска пулов завершена" -ForegroundColor 'Gray';
}

Function AddServernodeToNLB {
logstamp; Write-Host " Запуск функции введения сервера $servernode в боевой режим кластера распределения нагрузки" -ForegroundColor 'Gray';
$session = $args[0];
  logstamp; Write-Host " Ввод сервера $servernode ";
  try{
		Invoke-Command -Session $session -ScriptBlock {Start-NlbClusterNode $servernode};
      }
  catch{
		logstamp; Write-Host " Ввод сервера $servernode в кластер распределения нагрузки не удался" -ForegroundColor 'Red';
		logstamp; Write-Host " Критическая ошибка: Автообновление сервера $servernode не завершено." -ForegroundColor 'Red';
		$body = "Критическая ошибка: Автообновление сервера $servernode не завершено. Сервер $servernode не введен в кластер с приложением $application версии $PathVER";
		$subject = "Автообновление сервера: Критическая ошибка сервера $servernode";
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
		sleep 1
		send_email;
		#XwaitNG P;
		}
  finally{
		
			logstamp; Write-Host " Ввод сервера $servernode в кластер распределения нагрузки прошел успешно" -ForegroundColor 'Green';
			logstamp; Write-Host " Завершено. Автоматическое обновление приложения на сервере $servernode окончено." -ForegroundColor 'Green';
			$body = "Завершено. Автоматическое обновление приложения на сервере $servernode окончено. Сервер $servernode введен в строй с приложением $application версии $PathVER";
			$subject = "Автоматическое обновление: Сервер $servernode обновлен";
			sleep 1
			send_email;
		
		
		}  
   sleep 1
   logstamp; Write-Host " Функция перевода сервера в боевой режим закончена" -ForegroundColor 'Gray';
}

Function CheckWaitOperator {
#Функция проверки на ошибки
logstamp; Write-Host " Auto Choice: Checking last errors" -ForegroundColor 'Yellow';
#Получение значения для проверки.
$continue = $wait4
#Проверка есть ли ошибки
  If ($continue -eq "1") 
     #Есть ошибка, пишем об этом в консоль
     {logstamp; Write-Host " Process have some Errors: you want to stop process?" -ForegroundColor 'Red';
	 #Заполняем заголовок письма
	 $subject = $crtitical_message_subject
	 #Заполняем тело письма полученной ошибкой
	 $body = $crtitical_message_body
	 #Отправка письма
	 send_email;
	 #exit;
	  #Ожидание реакции оператора после ошибки
	  $Xcontinue = Read-Host
	  #Проверка выбора оператора
	  If ($Xcontinue -eq "X") 
      {
	  #Выбор оператора остановить процесс
	  Write-Host "$NowPipe Choice: stop process";
	  #Выход из программы
	  exit;
	  }
	else{logstamp; Write-Host " Выбор: продолжить процесс" -ForegroundColor 'Green';}
	  #Выбор оператора продолжить процесс
	 }
	#Нет ошибок, пишем об этом в консоль
	else{logstamp; Write-Host " Auto Choice: next process" -ForegroundColor 'Green';}
    #Окончание функции
}

Function VersionCheckFunction {
 if ($version_check_result -eq "FAIL")
    {
     logstamp; Write-Host " Тестирование сайта с сервера $servernode путь к приложению $url провалено. Номер версии приложения не совпадает!" -ForegroundColor 'Red';
     $body = "Тестирование сайта с сервера $servernode путь к приложению $url провалено. Номер версии приложения не совпадает! Версия $PathVER";
	 $subject = "Автоматическое обновление: Тестирование сайта на сервере $servernode провалено!";
     send_email;
     sleep 5
     #Break;
     #exit;
	 $wait4 = "1"
	 $crtitical_message_body = $body
	 return $wait4
	 return $crtitical_message_body
    }
    else
    {
     logstamp; Write-Host " Тестирование сайта с сервера $servernode путь к приложению $url прошло успешно. Номер версии приложения совпадает" -ForegroundColor 'Green';
     $body = "Тестирование сайта с сервера $servernode путь к приложению $url прошло успешно. Номер версии приложения совпадает! Версия $PathVER";
	 $subject = "Автоматическое обновление: Тестирование сайта на сервере $servernode успешно!";
     send_email;
    }
 
}

Function RequestCheckFunction {
if ($request_status_code_result.Value -eq "OK")
 {
  #echo "200 OK"
  #Write-Host " Тестирование сервера: $servernode по пути $url успешно!" -ForegroundColor 'Green';
  $body = "Тестирование сервера: $servernode по пути $url успешно! Процесс автоматического обновления до версии $PathVER завершен успешно!";
  $subject = "Автоматическое обновление: Тестирование сервера $servernode успешно!";
  send_email;
 }
 else
 {
#echo "fail"
Write-Host " Тестирование сервера: $servernode по пути $url провалено!" -ForegroundColor 'Red';
#Write-Host " Остановка процесса." -ForegroundColor 'Red';
$body = "Тестирование сервера: $servernode по пути $url провалено! Остановка процесса автоматического обновления до версии $PathVER";
$subject = "Автоматическое обновление: Тестирование сервера $servernode провалено!";
send_email;
#Break;
#exit;
$wait4 = "1"
$crtitical_message_body = $body
return $wait4
return $crtitical_message_body
}
}

Function AfterCheckNotification {
 $body = "Завершено: Автоматическое обновление сервера $servernode. Пожалуйста проверьте и решите, что делать дальше. Кластер балансировки нагрузки ожидает ввода сервера $servernode с приложением $application версии $PathVER";
 $subject = "Автоматическое обновление: На сервере $servernode ожидание!";
 send_email;
}

Function StartNotification {
  #logstamp; Write-Host " Запуск: Автоматическое обновление сервера $servernode приложением версии $PathVER" -ForegroundColor 'Yellow';
  $body = "Запуск: Автоматическое обновление сервера $servernode приложением версии $PathVER";
  $subject = "Автоматическое обновление: На сервере $servernode запущено!";
  sleep 5
  send_email;
  sleep 1
}

Function XwaitNG{
$Xcontinue = $args[0];
#########################################################
$FunctionNG = "XwaitNG"
	if ($Xcontinue -eq $null)
	{}
	else
	{
		
		switch ($Xcontinue)
				{
				"P" {
					
					$Xcontinue = Read-Host 
						If ($Xcontinue -eq "X") 
							{
											
											
											exit;
											break;
							}
						else
							{
											
							}
					}
				"X" { 
											
											exit;
					}
				"10" { 
											
											sleep 100
											exit;
					}
				"20" { 
											
											sleep 200
											exit;
					}
				"30" {
											
											sleep 300
											exit;
					}
				default {}
				}
	}
}

Function NotificationNG {
  logstamp; Write-Host " $messageNG $servernode" -ForegroundColor 'Yellow';
  $global:subject = $subjectNG
  $global:body = "$servernode";
  SendEmailNG;
}

Function CreateLogFolders {
$ScriptPathLogFolder = $args[0];

 if(!(Test-Path -Path $ScriptPathLogFolder)){
    New-Item -ItemType directory -Path $ScriptPathLogFolder
}
}

Function PreDeploy(){
$runsql_trigger = $args[0];
logstamp; Write-Host " runsql_trigger $runsql_trigger" -ForegroundColor 'Yellow';
StopMemcache;

if ( $runsql_trigger -eq "true" ){
logstamp; Write-Host " runsql_trigger $runsql_trigger eq true - start exec sql" -ForegroundColor 'Yellow';
ExecuteSQLdeployScripts;
}
logstamp; Write-Host " runsql_trigger $runsql_trigger eq false - no exec sql" -ForegroundColor 'Yellow';

}
Function Get-MD5{
  [CmdletBinding(SupportsShouldProcess=$false)]
  param
  (
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, HelpMessage="file(s) to create hash for")]
    [Alias("File", "Path", "PSPath", "String")]
    [ValidateNotNull()]
    $InputObject
  )

  begin
  {
    $cryptoServiceProvider    = [System.Security.Cryptography.MD5CryptoServiceProvider]
    $hashAlgorithm            = new-object $cryptoServiceProvider
  }

  process
  {
    $hashByteArray = ""

    $item = Get-Item $InputObject -ErrorAction SilentlyContinue
    if ($item -is [System.IO.DirectoryInfo])
    {
      throw "Cannot create hash for directory"
    }

    if ($item)
    {
      $InputObject = $item
    }

    if ($InputObject -is [System.IO.FileInfo])
    {
      $stream         = $null;
      $hashByteArray  = $null

      try
      {
        $stream         = $InputObject.OpenRead();
        $hashByteArray  = $hashAlgorithm.ComputeHash($stream);
      }
      finally
      {
        if ($stream -ne $null)
        {
          $stream.Close();
        }
      }
    }
    else
    {
      $utf8             = new-object -TypeName "System.Text.UTF8Encoding"
      $hashByteArray    = $hashAlgorithm.ComputeHash($utf8.GetBytes($InputObject.ToString()));
    }

    Write-Output ([BitConverter]::ToString($hashByteArray)).Replace("-","")
  }
}

Function AfterDeploy(){
$env = $args[0];

switch ($env) 
				{ 
				"STAGE" {
											logstamp; Write-Host " Окружение $env : не запускаем Memcached";
					}
				"DEV" { 			
											logstamp; Write-Host " Окружение $env : В данной среде сервис Memcached отсутствует";
					}
				"LIVE" { 
											logstamp; Write-Host " Окружение $env : запускаем Memcached";
											StartMemcache;
					}
				"TEST" { 
											logstamp; Write-Host " Окружение $env : запускаем Memcached";
											StartMemcache;
					}
				default {logstamp; Write-Host " Окружение $env : не запускаем Memcached";}
				}

}

Function GetUserDatails {
try{
		$global:credentials2 = Get-Credential 
	}
catch{
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
				$err = $err.InnerException;
				logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
				logstamp; Write-Host " Функция проверки введенных данных : Исключение!" -ForegroundColor 'Green';
				XwaitNG P;
			}
	}
finally{
		if (!$credentials2) { 
		logstamp; Write-Host " Функция проверки введенных данных пользователя : Значение пустое!" -ForegroundColor 'Green';
		sleep 10
		XwaitNG P;
		}
		
	}
	New-Variable -Name "credentials" -Value $credentials2 -Scope Global
 return $global:credentials2, $global:credentials1
}

Function SendEmailNG {
	$FunctionNG = "Отпарвка почты"
	#########################################################
	logstamp; Write-Host " Запуск функции $FunctionNG : Отправка почты"  -ForegroundColor 'Yellow';
	try{	
			$encoding = [System.Text.Encoding]::UTF8
			Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -SmtpServer $SMTPServer -port $SMTPPort -encoding $encoding
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

Function ValidateUserDetails {
$cred = $args[0]; 
$username = $cred.username
$password = $cred.GetNetworkCredential().password

# Get current domain using logged-on user's credentials
$CurrentDomain = "LDAP://" + ([ADSI]"").distinguishedName
$domain = New-Object System.DirectoryServices.DirectoryEntry($CurrentDomain,$UserName,$Password)

if ($domain.name -eq $null)
{
	#XwaitNG P;
}
else
{

}
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
