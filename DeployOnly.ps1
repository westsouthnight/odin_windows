[CmdletBinding()]  

param(
[String]$servernode,
[String]$echoPathVersionTyped,
[String]$RunnerExePath,
[Object]$superenv,
[String]$DisableBackup
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
Function Makefolders_and_copy {
logstamp; Write-Host " Запуск функции Makefolders_and_copy on $servernode" -ForegroundColor 'Gray';
$servernode = $args[0];

	   $global:body = "Копирование на сервер $servernode запущено";
	   $global:subject = " [START MODULE] Автоматическое обновление: Копирование на сервер $servernode запущено!";
	   send_email;

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
		Sleep 5
     }
 catch{
		logstamp; Write-Host " Копирование: Приложение версии $pathVER копируется на сервер $servernode не удалось!" -ForegroundColor 'Red';
		$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	   
	   $global:body = "Копирование: Приложение версии $pathVER на сервер $servernode не скопировано!";
	   $global:subject = " [FAIL MODULE] Автоматическое обновление: Копирование на сервер $servernode провалено!";
	   send_email;
	   
	   sleep 5
	   exit;
		} 
 finally{
 logstamp; Write-Host " Копирование: Приложение версии $pathVER копируется на сервер $servernode завершено" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Завершение функции создания папкок и копирования." -ForegroundColor 'Gray';
 
 $global:body = "Копирование: Приложение версии $pathVER скопировано на сервер $servernode удалось!";
 $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Копирование на сервер $servernode успешно!";
 send_email;
 
 }

Function RemoteImportModules {
logstamp; Write-Host " $servernode : Запуск функции загрузки модулей в удаленной сессии на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];

	   $global:body = "$servernode : Запуск функции загрузки модулей в удаленной сессии на сервере: $servernode";
	   $global:subject = " [START MODULE] Автоматическое обновление: Загрузка модулей на сервер $servernode ";
	   send_email;

 logstamp; Write-Host " $servernode : Запуск загрузки модулей в удаленной сессии на сервере: $servernode" -ForegroundColor 'Gray';
 try{
	Invoke-Command -Session $session -ScriptBlock {Import-Module NetworkLoadBalancingClusters};
	Invoke-Command -Session $session -ScriptBlock {Import-Module WebAdministration};
	Invoke-Command -Session $session -ScriptBlock {Import-Module BestPractices};
	Invoke-Command -Session $session -ScriptBlock {Import-module Pscx};
	 }
 catch{
	logstamp; Write-Host " $servernode : Загрузка модулей завершена с ошибками: Отправка почты - Сервер $servernode" -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
			
	   $global:body = "Загрузка модулей завершена с ошибками: Сервер $servernode";
	   $global:subject = " [FAIL MODULE] Автоматическое обновление: Загрузка модулей завершена с ошибками на сервере $servernode";
	   send_email;
	   
	   sleep 5
	   exit;
       }
 finally{
		 logstamp; Write-Host " $servernode : Загрузка модулей завершена - Сервер $servernode" -ForegroundColor 'Green';
		}
		
	$global:body = "$servernode : Загрузка модулей завершена - Сервер $servernode";
	$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Загрузки модулей на сервере $servernode выполнена!";
	send_email;
	
logstamp; Write-Host " $servernode : Функция загрузки модулей завершена - Сервер $servernode" -ForegroundColor 'Gray';
}
Function DrainStopTheNode {
 logstamp; Write-Host " $servernode : Запуск функции мягкого вывода из кластера балансировки нагрузки: Медленная остановка сервера - $servernode" -ForegroundColor 'Gray';
 $session = $args[0];
 
 $global:body = "$servernode : Среднее время ожидания 420 секунд : Запуск функции мягкого вывода из кластера балансировки нагрузки : Медленная остановка сервера - $servernode ;";
 $global:subject = " [START MODULE] Автоматическое обновление: Вывод сервера $servernode стартовал!";
 send_email;
 
 logstamp; Write-Host " $servernode : Начало медленной остановки сервера - $servernode" -ForegroundColor 'Gray';
 try{
    Invoke-Command -Session $session -ScriptBlock {Stop-NlbClusterNode $servernode -Drain -Timeout 300;};
	logstamp; Write-Host " $servernode : Ожидание, после мягкого вывода сервера - $servernode" -ForegroundColor 'Gray';
	Sleep 120
	logstamp; Write-Host " $servernode : Вывод сервера $servernode из кластера" -ForegroundColor 'Gray';
	Invoke-Command -Session $session -ScriptBlock {Stop-NlbClusterNode $servernode};
	}
 catch{
       logstamp; Write-Host " $servernode : Мягкая остановка: Вывод сервера $servernode провалился. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	   $global:body = "Мягкая остановка сервера в кластере, Вывод сервера $servernode провалился";
	   $global:subject = " [FAIL MODULE] Автоматическое обновление: Мягкая остановка, Вывод сервера $servernode провалился";
	   send_email;
       }
 finally
	   {
	   logstamp; Write-Host " $servernode : Мягкая остановка: Вывод сервера $servernode Завершен" -ForegroundColor 'Green';
	   }
	   
	   $global:body = "$servernode : Функция Мягкой остановка и вывода сервера $servernode завершена ;";
       $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Вывод сервера $servernode завершен!";
       send_email;
 logstamp; Write-Host " $servernode : Функция Мягкой остановка и вывода сервера $servernode завершена" -ForegroundColor 'Gray';
}
Function StopIISpool {
 logstamp; Write-Host " $servernode : Запуск функции остановки пула приложения: Остановка пула на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];
	
	 $global:body = "$servernode : Запуск функции остановки пула приложения: Остановка пула на сервере: $servernode";
	 $global:subject = " [START MODULE] Автоматическое обновление: Остановка пула на сервере $servernode стартовала";
	 send_email;

 logstamp; Write-Host " $servernode : Остановка пулов на сервере: $servernode" -ForegroundColor 'Gray';
 try{
     Invoke-command -Session $session -Scriptblock {param ($application);Stop-WebItem IIS:\AppPools\$application} -ArgumentList $application;
	 }
 catch{
     logstamp; Write-Host " $servernode : Остановка пула на сервере: $servernode завершена с ошибками. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	 $global:body = "Остановка пула на сервере: $servernode завершена с ошибками.";
	 $global:subject = " [FAIL MODULE] Автоматическое обновление: Остановка пула на сервере $servernode завершена с ошибками.";
	 send_email;
	 #XwaitNG P;
	   }
 finally{
     logstamp; Write-Host " $servernode : Остановка пула на сервере: $servernode завершена" -ForegroundColor 'Green';
        }	 
 logstamp; Write-Host " $servernode : Ожидание после остановки пулов приложений на сервере: $servernode" -ForegroundColor 'Gray';
 Sleep $sleep
 
	 $global:body = "Остановка пула на сервере: $servernode завершена";
	 $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Остановка пула на сервере $servernode завершена";
	 send_email;
 
 logstamp; Write-Host " $servernode : Функция остановки пулов приложений завершена" -ForegroundColor 'Gray';
}
Function BackUpApplication {
logstamp; Write-Host " $servernode : Запуск функции резервного копирования приложения на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];

 $global:body = "$servernode : Запуск функции резервного копирования приложения на сервере: $servernode ;";
 $global:subject = " [START MODULE] Автоматическое обновление: Резервное копирование приложения на сервере $servernode стартовало!";
 send_email;

 logstamp; Write-Host " $servernode : Создание резервной копии на сервере: $servernode" -ForegroundColor 'Gray';
 try{
	Invoke-command -Session $session -Scriptblock {param ($factDIR,$destination,$zipFilename);write-zip $factDIR ($destination + $zipFilename)} -ArgumentList $factDIR, $destination, $zipFilename;
	 }
 catch{
	 logstamp; Write-Host " $servernode : Создание резервной копии на сервере: $servernode провалилось! Отправка почты. Процесс ожидает вмешательства оператора!" -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	 $global:body = "Создание резервной копии на сервере: $servernode провалилось! Процесс ожидает вмешательства оператора!";
	 $global:subject = " [FAIL MODULE] Автоматическое обновление: Создание резервной копии на сервере $servernode провалилось!";
	 send_email;
	 $BackupTryToContinue = Read-Host
  If ($BackupTryToContinue -eq "X") 
     {logstamp; Write-Host " Выбор: остановить процесс" -ForegroundColor 'Red';
	 exit;
	 }
	else{logstamp; Write-Host " Выбор: продолжить процесс" -ForegroundColor 'Green';}
	}
 finally{
     logstamp; Write-Host " $servernode : Создание резервной копии на сервере: $servernode завершено! Отправка почты."  -ForegroundColor 'Green';
	     }
 logstamp; Write-Host " $servernode : Стандартное ожидание после создания бекапа на сервере: $servernode" -ForegroundColor 'Gray';
 Sleep $sleep
 
 $global:body = "$servernode : Создание резервной копии на сервере: $servernode завершено! ;";
 $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Резервное копирование приложения на сервере $servernode окончено!";
 send_email;
 
 logstamp; Write-Host " $servernode : Функция создания резервной копии завершена" -ForegroundColor 'Gray';
 }
Function DeployIISapp {
logstamp; Write-Host " $servernode : Запуск функции обновления приложения на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];

 $global:body = "$servernode : Запуск функции обновления приложения на сервере: $servernode";
 $global:subject = " [START MODULE] Автоматическое обновление: Обновление приложения на сервере $servernode запущено!";
 send_email;

 logstamp; Write-Host " $servernode : Запуск обновления приложения до версии $PathVER на сервере $servernode" -ForegroundColor 'Gray';
 try{
    Invoke-Command -Session $session -ScriptBlock {param ($EXAMPLE_TXTzip, $DeployEXElog); msdeploy.exe -verb:sync -source:package=$EXAMPLE_TXTzip -dest:iisApp=application.example.com > $DeployEXElog} -ArgumentList $EXAMPLE_TXTzip;$DeployEXElog;
	
	 }
 catch{
	logstamp; Write-Host " $servernode : Обновление приложения до версии $PathVER на сервере $servernode завершено с ошибками. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	 $global:body = "Обновление приложения до версии $PathVER на сервере $servernode завершено с ошибками.";
	 $global:subject = " [FAIL MODULE] Автоматическое обновление: Обновление приложения до версии $PathVER на сервере $servernode завершено с ошибками.";
	 send_email;
	}
 finally{
	logstamp; Write-Host " $servernode : Обновление приложения до версии $PathVER на сервере $servernode завершено."  -ForegroundColor 'Green';
	}
 logstamp; Write-Host " $servernode : Ожидание после обновления приложения до версии $PathVER на сервере $servernode" -ForegroundColor 'Gray';
 Sleep $sleep
 
 $global:body = "$servernode : Функция обновления приложения до версии $PathVER на сервере $servernode завершена.";
 $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Обновление приложения на сервере $servernode завершено!";
 send_email;
 
 logstamp; Write-Host " $servernode : Функция обновления приложения до версии $PathVER на сервере $servernode завершена." -ForegroundColor 'Gray'
}
Function send_email {
	$FunctionNG = "Отпарвка почты"
	#########################################################
	logstamp; Write-Host " $servernode : Запуск функции $FunctionNG : Отправка почты"  -ForegroundColor 'Yellow';
	try{
			Send-MailMessage -From $Global:From -to $Global:To -Subject $Global:Subject -Body $Global:Body -SmtpServer $Global:SMTPServer -port $Global:SMTPPort
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
       logstamp; Write-Host " $servernode : Функция $FunctionNG : Завершена" -ForegroundColor 'Green';
	 		}
	#########################################################
	logstamp; Write-Host " $servernode : Функция $FunctionNG : Отправка завершена" -ForegroundColor 'Yellow';
}
Function StartIISpool {
logstamp; Write-Host " $servernode : Запуск функции включения пулов сайта на сервере: $servernode" -ForegroundColor 'Gray';
$session = $args[0];

	 $global:body = "$servernode : Запуск функции запуска пула приложения: Запуск пула на сервере: $servernode";
	 $global:subject = " [START MODULE] Автоматическое обновление: Запуск пула на сервере $servernode стартовала";
	 send_email;

 logstamp; Write-Host " $servernode : Запуск пулов приложений на сервере $servernode";
 try{
		Invoke-command -Session $session -Scriptblock {param ($application);Start-WebItem IIS:\AppPools\$application} -ArgumentList $application;
     }
 catch{
        logstamp; Write-Host " $servernode : Запуск пулов приложений на сервере $servernode провалился. Отправка почты." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
	    $global:body = "Запуск пула на сервере $servernode завершен с ошибками.";
		$global:subject = " [FAIL MODULE] Автоматическое обновление: Запуск пула на сервере $servernode не выполнен!";
		send_email;
		} 
 finally{
        logstamp; Write-Host " $servernode : Запуск пулов приложений на сервере $servernode завершен." -ForegroundColor 'Green';
 }		

 
		$global:body = "Запуск пулов приложений на сервере $servernode завершен успешно";
		$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Запуск пулов приложений на сервере $servernode завершен";
	    send_email;
		
 Sleep $sleep
 logstamp; Write-Host " $servernode : Функция запуска пулов завершена" -ForegroundColor 'Gray';
}
Function AddServernodeToNLB {
logstamp; Write-Host " $servernode : Запуск функции введения сервера $servernode в боевой режим кластера распределения нагрузки" -ForegroundColor 'Gray';
$session = $args[0];

	 $global:body = "$servernode : Запуск функции введения сервера $servernode в боевой режим кластера распределения нагрузки";
	 $global:subject = " [START MODULE] Автоматическое обновление: Перевод сервера $servernode в боевой режим";
	 send_email;

  logstamp; Write-Host " $servernode : Ввод сервера $servernode ";
  try{
		Invoke-Command -Session $session -ScriptBlock {Start-NlbClusterNode $servernode};
      }
  catch{
		logstamp; Write-Host " Ввод сервера $servernode в кластер распределения нагрузки не удался" -ForegroundColor 'Red';
		logstamp; Write-Host " Критическая ошибка: Автообновление сервера $servernode не завершено." -ForegroundColor 'Red';
		
		$global:body = "Критическая ошибка: Автообновление сервера $servernode не завершено. Сервер $servernode не введен в кластер с приложением $application версии $PathVER";
		$global:subject = " [CRITICAL FAIL MODULE] Автоматическое обновление: Критическая ошибка сервера $servernode";
		send_email;
		
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
		sleep 1
		
		#XwaitNG P;
		}
  finally{
		logstamp; Write-Host " $servernode : Ввод сервера $servernode в кластер распределения нагрузки прошел успешно" -ForegroundColor 'Green';
		logstamp; Write-Host " $servernode : Завершено. Автоматическое обновление приложения на сервере $servernode окончено." -ForegroundColor 'Green';
		$global:body = "Завершено. Автоматическое обновление приложения на сервере $servernode окончено. Сервер $servernode введен в строй с приложением $application версии $PathVER";
		$global:subject = " [COMPLETE MODULE] Автоматическое обновление: Сервер $servernode введен в боевой режим";
		sleep 1
		send_email;
		}  
   sleep 1
   logstamp; Write-Host " $servernode : Функция перевода сервера в боевой режим закончена" -ForegroundColor 'Gray';
}
Function CheckWaitOperator {
#Функция проверки на ошибки
logstamp; Write-Host " $servernode : Auto Choice: Checking last errors" -ForegroundColor 'Yellow';
#Получение значения для проверки.
$continue = $wait4
#Проверка есть ли ошибки
  If ($continue -eq "1") 
     #Есть ошибка, пишем об этом в консоль
     {logstamp; Write-Host " $servernode : Процесс имел критические ошибки" -ForegroundColor 'Red';
	 $global:body = "Автоматическое обновление приложения на сервере $servernode провалено. Процесс содержал критические ошибки, поток ставится на бесконечное ожидание.";
	 $global:subject = " [CRITICAL FAIL MODULE] Автоматическое обновление: Процесс имел критические ошибки - Сервер $servernode ";
	 #Отправка письма
	 send_email;
	 Sleep
	 exit;
	 }
	#Нет ошибок, пишем об этом в консоль
	else{logstamp; Write-Host " $servernode : Auto Choice: next process" -ForegroundColor 'Green';}
    #Окончание функции
}
Function VersionCheckFunction {
 if ($version_check_result -eq "FAIL")
    {
     logstamp; Write-Host " $servernode : Тестирование сайта с сервера $servernode путь к приложению $url провалено. Номер версии приложения не совпадает!" -ForegroundColor 'Red';
     $global:body = "Тестирование сайта с сервера $servernode путь к приложению $url провалено. Номер версии приложения не совпадает!";
	 $global:subject = " [CRITICAL FAIL MODULE] Автоматическое обновление: Тестирование сайта на сервере $servernode провалено!";
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
     logstamp; Write-Host " $servernode : Тестирование сайта с сервера $servernode путь к приложению $url прошло успешно. Номер версии приложения совпадает" -ForegroundColor 'Green';
     $global:body = "Тестирование сайта с сервера $servernode путь к приложению $url прошло успешно. Номер версии приложения совпадает. Версия $PathVER";
	 $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Тестирование сайта на сервере $servernode успешно!";
     send_email;
    }
 
}
Function RequestCheckFunction {
if ($request_status_code_result.Value -eq "OK")
 {
  $global:body = "Тестирование сервера: $servernode по пути $url успешно! Остановка процесса автоматического обновления до версии $PathVER";
  $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Тестирование сервера $servernode успешно!";
  send_email;
 }
 else
 {
#echo "fail"
Write-Host " $servernode : Тестирование сервера: $servernode по пути $url провалено!" -ForegroundColor 'Red';
#Write-Host " $servernode : Остановка процесса." -ForegroundColor 'Red';
$global:body = "Тестирование сервера: $servernode по пути $url провалено! Остановка процесса автоматического обновления до версии $PathVER";
$global:subject = " [CRITICAL FAIL MODULE] Автоматическое обновление: Тестирование сервера $servernode провалено!";
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
 $global:body = "Завершено: Автоматическое обновление сервера $servernode. Пожалуйста проверьте и решите, что делать дальше. Кластер балансировки нагрузки ожидает ввода сервера $servernode с приложением $application версии $PathVER";
 $global:subject = " [ATTENTION] Автоматическое обновление: Cервер $servernode ожидает ввода в кластер!";
 send_email;
}

Function StartNotification {
logstamp; Write-Host " $servernode : Запуск: Автоматическое обновление сервера $servernode приложением версии $PathVER" -ForegroundColor 'Yellow';
  $global:body = "Запуск: Автоматическое обновление сервера $servernode приложением версии $PathVER";
  $global:subject = " [ATTENTION] Автоматическое обновление: На сервере $servernode запущено!";
  sleep 5
  send_email;
  sleep 1
}

Function NotificationNG {
  logstamp; Write-Host " $messageNG $servernode" -ForegroundColor 'Yellow';
  $global:subject = $subjectNG
  $global:body = "$servernode";
  SendEmailNG;
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
                                                               $global:body = "Checking site: Test $servernode $url Succeeded. Version Validation Math = OK . $PathVER";
                                                               Write-Host " Test: $servernode $url Succeeded. Version Validation Math = OK" -ForegroundColor 'Green';
                                                               $VersionValidateResult = "OK"
													           [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null;
															   return $VersionValidateResult
                                                                }
                                                            Else
                                                            {
                                                                Write-Host " Test: $servernode $url Fail. Version Validation Math = FAIL" -ForegroundColor 'Red';
                                                                $VersionValidateResult = "FAIL"
                                                                $global:body = "Checking site: Test $servernode $url Failed! Please Stop process Auto Deploy. Version Validation Math = FAIL $PathVER";
                                                                [System.Net.ServicePointManager]::ServerCertificateValidationCallback = $null;
																return $VersionValidateResult
																send_email;
                                                            }													
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
 
Function CreateLogFolders {
$ScriptPathLogFolder = $args[0];

 if(!(Test-Path -Path $ScriptPathLogFolder)){
    New-Item -ItemType directory -Path $ScriptPathLogFolder
}
}

 ############################ ----- ############################

 Split-Path -path (pwd)
 cd $RunnerExePath
 Split-Path -path (pwd)
 
############################ ----- ############################
$GlobalFunctions = "Adin_modules/GlobalFunctions.psm1"
Import-Module $RunnerExePath/$GlobalFunctions #-Verbose
logstamp; Write-Host " Loaded GlobalFunctions $GlobalFunctions" -ForegroundColor 'Green';
############################ ----- ############################

#logstamp; Write-Host "!!! $servernode !!!" -ForegroundColor 'Red';

############################ ----- ############################
$GlobalParallelDeploySettings = "Adin_modules/GlobalParallelDeploySettings.ps1"
Import-Module $RunnerExePath\$GlobalParallelDeploySettings -ArgumentList $superenv
# -ArgumentList $echoPathVersionTyped, $env, $RunnerExePath
logstamp; Write-Host " Loaded GlobalParallelDeploySettings $GlobalParallelDeploySettings" -ForegroundColor 'Green';
############################ ----- ############################

if ($superenv -eq "TEST"){
############################ ----- ############################
$ReplaceFuctions = "Adin_modules/Replace/"+$superenv+"ReplaceFunctions.psm1"
Import-Module $RunnerExePath/$ReplaceFuctions #-Verbose
#logstamp; Write-Host " Loaded ReplaceFuctions $ReplaceFuctions" -ForegroundColor 'Green';
############################ ----- ############################
}
 
  StartNotification;  
 
  Makefolders_and_copy $servernode;
 
  $session=New-PSsession -Computername $servernode
  
  RemoteImportModules $session;

  DrainStopTheNode $session;

  StopIISpool $session;

  if($DisableBackup -eq "true"){
  logstamp; Write-Host " BackUP: Отключен" -ForegroundColor 'Yellow';
  }
  else{
  logstamp; Write-Host " BackUP: Включен" -ForegroundColor 'Yellow';
  BackUpApplication $session;
  }

  DeployIISapp $session;
  
if ($superenv -eq "TEST"){
  ChangeSecureServicesXML -servernode $servernode -RelConfigurationDIRServices $RelConfigurationDIRServices; 
  ChangeSecureGatewaysXML -servernode $servernode -RelConfigurationDIRGateways $RelConfigurationDIRGateways; 
}

  StartIISpool $session;

  $url = "https://application.example.com/login";

  $request_status_code_result = Invoke-command -Session $session -Scriptblock ${function:request_status_code}
 
  RequestCheckFunction;
 
  $ResponseGetStreamResultData = Invoke-command -Session $session -Scriptblock ${function:application_version_check}
  
  $version_check_result = version_check;
  VersionCheckFunction;
 
  AfterCheckNotification;
 
  CheckWaitOperator;
  
  AddServernodeToNLB $session;
  
