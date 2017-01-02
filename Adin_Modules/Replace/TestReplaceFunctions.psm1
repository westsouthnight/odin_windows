Function ChangeSecureServicesXML {
[CmdletBinding()]  
Param
 (
  [parameter(Mandatory=$True)][String]$servernode,
  [parameter(Mandatory=$True)][String]$RelConfigurationDIRServices
 )
 
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

 
#########################################################
$FunctionNG = "ChangeSecureServicesXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в Service.xml приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений МТТ в Service.xml на сервере $servernode" -ForegroundColor 'Gray';
 
 $ServicesXMLfullPath = "\\$servernode\$RelConfigurationDIRServices"
 logstamp; Write-Host " Путь до фаила $ServicesXMLfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$ServicesXMLfullPath")
 logstamp; Write-Host " Загрузка XML $ServicesXMLfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $ServicesXMLfullPath" -ForegroundColor 'Gray';
 
  #$xml2working = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters")
  #$LoginMgMn = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginMgMn") | % { $_.Node.'#text' = 'test' $_.Node.SomeAttribute = 'value'}
 
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginMgMn") | % {$_.'#text' = 'EXAMPLE_TXT'}
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordMgMn[@type='encrypted']") | % {$_.'type' = 'decrypted'}
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordMgMn") | % {$_.'#text' = 'EXAMPLE_TXT'}
  
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginSubscriberNumber") | % {$_.'#text' = 'EXAMPLE_TXT'}
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordSubscriberNumber[@type='encrypted']") | % {$_.'type' = 'decrypted'}
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordSubscriberNumber") | % {$_.'#text' = 'EXAMPLE_TXT'}
  
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginShpd") | % {$_.'#text' = 'EXAMPLE_TXT'}
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordShpd[@type='encrypted']") | % {$_.'type' = 'decrypted'}
  $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordShpd") | % {$_.'#text' = 'EXAMPLE_TXT'}
  
  logstamp; Write-Host " Сохранение измененного XML $ServicesXMLfullPath" -ForegroundColor 'Green';
  $xml.Save($ServicesXMLfullPath)
  
  logstamp; Write-Host " Проверка значений XML $ServicesXMLfullPath" -ForegroundColor 'Green';
  
  $LoginSubscriberNumber = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginSubscriberNumber") | % {$_.'#text'}
  $PasswordSubscriberNumberType = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordSubscriberNumber") | % {$_.'type'}
  $PasswordSubscriberNumber = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordSubscriberNumber") | % {$_.'#text'}
  
  $LoginMgMn = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginMgMn") | % {$_.'#text'}
  $PasswordMgMnType = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordMgMn") | % {$_.'type'}
  $PasswordMgMn = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordMgMn") | % {$_.'#text'}
  
  $LoginShpd = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginShpd") | % {$_.'#text'}
  $PasswordShpdType = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordShpd") | % {$_.'type'}
  $PasswordShpd = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/PasswordShpd") | % {$_.'#text'}
  
  logstamp; Write-Host " Значение LoginShpd $LoginShpd" -ForegroundColor 'Magenta';
  logstamp; Write-Host " Значение PasswordShpdType $PasswordShpdType" -ForegroundColor 'Magenta';
  logstamp; Write-Host " Значение PasswordShpd $PasswordShpd" -ForegroundColor 'Magenta';
  
  logstamp; Write-Host " Значение LoginMgMn $LoginMgMn" -ForegroundColor 'Magenta';
  logstamp; Write-Host " Значение PasswordMgMnType $PasswordMgMnType" -ForegroundColor 'Magenta';
  logstamp; Write-Host " Значение PasswordMgMn $PasswordMgMn" -ForegroundColor 'Magenta';
  
  logstamp; Write-Host " Значение LoginSubscriberNumber $LoginSubscriberNumber" -ForegroundColor 'Magenta';
  logstamp; Write-Host " Значение PasswordSubscriberNumberType $PasswordSubscriberNumberType" -ForegroundColor 'Magenta';
  logstamp; Write-Host " Значение PasswordSubscriberNumber $PasswordSubscriberNumber" -ForegroundColor 'Magenta';
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в Service.xml приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в Service.xml приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG Замена значений в Service.xml приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в Service.xml приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в Service.xml приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в Service.xml приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
 
Function ChangeTimerJobsXML() {
 $JobsXMLfullPath = $args[0];
 $FunctionNG = "ChangeTimerJobsXML"
 #########################################################
 logstamp; Write-Host " Запуск функции замены и добавленеия значений в Jobs.xml приложения" -ForegroundColor 'Gray';
 #########################################################
 try{
 logstamp; Write-Host " Начало замены значений в JobsList.xml" -ForegroundColor 'Gray';
 logstamp; Write-Host " Путь до фаила JobsList.xml : $JobsXMLfullPath" -ForegroundColor 'Gray';
 #########################################################
 $xml2=New-Object XML
 $xml2.Load("$JobsXMLfullPath")
 logstamp; Write-Host " Загрузка XML $JobsXMLfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $JobsXMLfullPath" -ForegroundColor 'Gray';
 #########################################################
  #$xml2working = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters")
  #$LoginMgMn = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginMgMn") | % { $_.Node.'#text' = 'test' $_.Node.SomeAttribute = 'value'}
  logstamp; Write-Host " Загружаем объект с именем job.MttDailyRegisterJob в память как значение B" -ForegroundColor 'Gray';
  $xml2.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.MttDailyRegisterJob}") {$b = $_}}
  logstamp; Write-Host " Удаляем объект с именем job.RusSlavBankRegister" -ForegroundColor 'Gray';
  $xml2.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.RusSlavBankRegister}") {$w = $_ ; $w.ParentNode.RemoveChild($w) }} 
  #$xml2.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromTestGateway}") {$b = $_}}
  logstamp; Write-Host " Загружаем объект с именем первый объект среди значений в массиве, в память как значение О" -ForegroundColor 'Gray';
  $o = $xml2.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item").Item(0)
  logstamp; Write-Host " Клонируем значение О в значение C" -ForegroundColor 'Gray';
  $c = $o.Clone()
  logstamp; Write-Host " Меняем текст значения С" -ForegroundColor 'Gray';
  $c.InnerText = "`${job.SettleTransactionsFromTestGateway}"
  logstamp; Write-Host " Добавляем значение С к родителю О" -ForegroundColor 'Gray';
  $o.ParentNode.AppendChild($c)
  logstamp; Write-Host " Удаляем значение B из родителя B" -ForegroundColor 'Gray';
  $b.ParentNode.RemoveChild($b) 
  
  
  
  logstamp; Write-Host " Сохранение измененного XML $JobsXMLfullPath" -ForegroundColor 'Green';
  $xml2.Save($JobsXMLfullPath)
  #########################################################
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в Jobs.xml приложения прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в Jobs.xml приложения прошла не удачно!";
	    $subjectNG = "Function $FunctionNG Замена значений в Jobs.xml приложения прошла не удачно!"
		#########################################################
		logstamp; Write-Host " Замена значений в Jobs.xml приложения прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в Jobs.xml приложения завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Завершено" -ForegroundColor 'Gray';
}
 
Function ChangeSecureWebConfigXML {
#########################################################
$FunctionNG = "ChangeSecureWebConfigXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в web.config приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений web.config на сервере $servernode" -ForegroundColor 'Gray';
 
 $secureWebConfigfullPath = "\\$servernode\$secureWebConfig"
 logstamp; Write-Host " Путь до фаила $secureWebConfigfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$secureWebConfigfullPath")
 logstamp; Write-Host " Загрузка XML $secureWebConfigfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $secureWebConfigfullPath" -ForegroundColor 'Gray';
 
 #STEP1
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1']") 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2']")
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1']") | % {$_.'host' = 'nh_memcached_1.example.loc'}
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2']") | % {$_.'host' = 'nh_memcached_2.example.loc'}
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1.example.loc']") 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2.example.loc']")
 
 #STEP2
 
 $xml.SelectNodes("/configuration/activerecord/config/add[@key='connection.connection_string']") | % {$_.'value' = 'server=EXAMPLE_TXT-SQL;database=example;trusted_connection=true;Max Pool Size=1000;Pooling=true;Timeout=110'}
 
 #STEP3
 
 $xml.SelectNodes("/configuration/system.net/mailSettings/smtp") | % {$_.'from' = 'support@EXAMPLE_TXTsystem.com'}
 $xml.SelectNodes("/configuration/system.net/mailSettings/smtp/network") | % {$_.'host' = 'mailer.example.loc'}
 
 #STEP4
 
 $xml.SelectNodes("/configuration/SystemSettings/setting[@name='solrUrlBase']") | % {$_.'value' = 'https://nosql.example.loc:8983/solr'}
 
 #STEP5
 $step5 = $xml.SelectNodes("/configuration/location[@path='.']/system.webServer")
 
 $newRole = $xml.CreateElement("urlCompression")
 $newRole.SetAttribute(“doStaticCompression”,”false”);
 $newRole.SetAttribute(“doDynamicCompression”,”false”);
 $step5.ParentNode.AppendChild($newRole)
 
 #STEP6 CHANGE MSMQ ENDPOINTS
 
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Dispatch']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Dispatch'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Write'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Write'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXTProcessor/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXTProcessor/ServiceGateway.svc/Write'}
 
 
 #$xml.SelectNodes("/configuration/location[@path='.']/system.webServer") | % {$_.'urlCompression' = 'doStaticCompression="false" doDynamicCompression="false"'}
 #<urlCompression doStaticCompression="false" doDynamicCompression="false" />


  logstamp; Write-Host " Сохранение измененного XML $secureWebConfigfullPath" -ForegroundColor 'Green';
  $xml.Save($secureWebConfigfullPath)
  
  logstamp; Write-Host " Проверка значений XML $secureWebConfigfullPath" -ForegroundColor 'Green';
  
 
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в web.config  приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в web.config  приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в web.config  приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в web.config приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в web.config приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в web.config приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
Function ChangeSecureAppSettingsXML {
#########################################################
$FunctionNG = "ChangeSecureAppSettingsXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в AppSettings приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений AppSettings на сервере $servernode" -ForegroundColor 'Gray';
 
 $secureAppSettingsfullPath = "\\$servernode\$secureAppSettings"
 logstamp; Write-Host " Путь до фаила $secureAppSettingsfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$secureAppSettingsfullPath")
 logstamp; Write-Host " Загрузка XML $secureAppSettingsfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $secureAppSettingsfullPath" -ForegroundColor 'Gray';
 
 $xml.SelectNodes("/appSettings/add[@key='example.merchant-support-email-from']") | % {$_.'value' = 'feedback@EXAMPLE_TXTsystem.com'}
 $xml.SelectNodes("/appSettings/add[@key='example.merchant-support-email-to']") | % {$_.'value' = 'support@EXAMPLE_TXTsystem.com'}
 
  logstamp; Write-Host " Сохранение измененного XML $secureAppSettingsfullPath" -ForegroundColor 'Green';
  $xml.Save($secureAppSettingsfullPath)
  
  
  
  ###### ABLE TO WRITE CHECK #####
  
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в AppSettings приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в AppSettings приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в AppSettings приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в AppSettings приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в AppSettings приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в AppSettings приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }

Function ChangeservicetimerconfigXML {
#########################################################
$FunctionNG = "ChangeservicetimerconfigXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в servicetimerconfig приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений servicetimerconfig на сервере $servernode" -ForegroundColor 'Gray';
 
 $servicetimerconfigfullPath = "\\$servernode\$servicetimerconfig"
 logstamp; Write-Host " Путь до фаила $servicetimerconfigfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$servicetimerconfigfullPath")
 logstamp; Write-Host " Загрузка XML $servicetimerconfigfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $servicetimerconfigfullPath" -ForegroundColor 'Gray';
 
  #STEP1 MEMCACHE CHANGE
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1']") 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2']")
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1']") | % {$_.'host' = 'nh_memcached_1.example.loc'}
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2']") | % {$_.'host' = 'nh_memcached_2.example.loc'}
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1.example.loc']") 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2.example.loc']")
 
  #STEP2 SQL ENDPOINT CHANGE
 
 $xml.SelectNodes("/configuration/activerecord/config/add[@key='connection.connection_string']") | % {$_.'value' = 'server=EXAMPLE_TXT-SQL;database=example;trusted_connection=true;Max Pool Size=1000;Pooling=true;Timeout=110'}
 
  #STEP3 ADD ATRIBUTE LOG4NET
  
 $STEP3 = $xml.SelectNodes("/configuration/log4net")
 
 $lockingModel = $xml.CreateElement("lockingModel")
 $lockingModel.SetAttribute(“type”,”log4net.Appender.FileAppender+MinimalLock”);
 
 $STEP3.AppendChild($lockingModel)
  
  
  #STEP4
  
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/to") | % {$_.'value' = 'error@EXAMPLE_TXTsystem.com'}
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/from") | % {$_.'value' = 'support@EXAMPLE_TXTsystem.com'}
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/smtpHost") | % {$_.'value' = 'mailer.example.loc'}
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/subject") | % {$_.'value' = 'EXAMPLE_TXT.AMO.Service.Timer Error'}
    
   $xml.SelectNodes("/configuration/log4net/appender[@name='mongo']/host") | % {$_.'#text' = 'nosql.example.loc'}
   
   #STEP5
   $xml.SelectNodes("/configuration/system.net/mailSettings/smtp") | % {$_.'from' = 'support@EXAMPLE_TXTsystem.com'}
   $xml.SelectNodes("/configuration/system.net/mailSettings/smtp/network") | % {$_.'host' = 'mailer.example.loc'}
   
   #STEP6
   
   $xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Dispatch']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Dispatch'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Write'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Write'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXTProcessor/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXTProcessor/ServiceGateway.svc/Write'}
 
  
  
  logstamp; Write-Host " Сохранение измененного XML $servicetimerconfigfullPath" -ForegroundColor 'Green';
  $xml.Save($servicetimerconfigfullPath)
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в servicetimerconfig приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в servicetimerconfig приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в servicetimerconfig приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в servicetimerconfig приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в servicetimerconfig приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в servicetimerconfig приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
Function ChangeservicetimernlogconfigXML {
#########################################################
$FunctionNG = "ChangeservicetimernlogconfigXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в servicetimernlogconfig приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений servicetimernlogconfig на сервере $servernode" -ForegroundColor 'Gray';
 
 $servicetimernlogconfigfullPath = "\\$servernode\$servicetimernlogconfig"
 logstamp; Write-Host " Путь до фаила $servicetimernlogconfigfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$servicetimernlogconfigfullPath")
 logstamp; Write-Host " Загрузка XML $servicetimernlogconfigfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $servicetimernlogconfigfullPath" -ForegroundColor 'Gray';
 
 $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
 $ns.AddNamespace("ns", "http://www.nlog-project.org/schemas/NLog.xsd")
 $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")
 $xml.SelectNodes("//ns:nlog/ns:targets/ns:target", $ns) | % {$_.'host' = 'nosql.example.loc'}
  
  logstamp; Write-Host " Сохранение измененного XML $servicetimernlogconfigfullPath" -ForegroundColor 'Green';
  $xml.Save($servicetimernlogconfigfullPath)
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в servicetimernlogconfig приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в servicetimernlogconfig приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в servicetimernlogconfig приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в servicetimernlogconfig приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в servicetimernlogconfig приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в servicetimernlogconfig приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }

Function ChangeservicetimerjoblistXML {
#########################################################
$FunctionNG = "ChangeservicetimerjoblistXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в servicetimerjoblist приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений servicetimerjoblist на сервере $servernode" -ForegroundColor 'Gray';
 
 $servicetimerjoblistfullPath = "\\$servernode\$servicetimerjoblist"
 logstamp; Write-Host " Путь до фаила $servicetimerjoblistfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$servicetimerjoblistfullPath")
 logstamp; Write-Host " Загрузка XML $servicetimerjoblistfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $servicetimerjoblistfullPath" -ForegroundColor 'Gray';
 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.Tcb.EXAMPLE_TXTExport}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.QiwiBillStatus}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.VoidSampaxPreauthorizations}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.NccMonthlyRegisterJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.NccScpDailyRegisterJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.NccEmailDailyRegisterJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.UcsClearingJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.VtbClearingJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.VtbInterchangeJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.BashTelEmailDailyRegisterJobFirst}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.BashTelEmailDailyRegisterJobSecond}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.UcsInterchangeJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromCft}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.ThreeDSCacheUpdate}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
						
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.YandexMoneyRegisterJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.YandexMoneySearchUnconfirmedBillsJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.EXAMPLE_TXTStartForKitFinance}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.PrivatBankDailyRegistry}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromAvia2}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.ErvProcessTransactionsJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.CreditRequestsCheckJob") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromTCBIPT") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
  
  logstamp; Write-Host " Сохранение измененного XML $servicetimerjoblistfullPath" -ForegroundColor 'Green';
  $xml.Save($servicetimerjoblistfullPath)
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в servicetimerjoblist приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в servicetimerjoblist приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в servicetimerjoblist приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в servicetimerjoblist приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в servicetimerjoblist приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в servicetimerjoblist приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
Function ChangeservicetimerappsettingsXML {
#########################################################
$FunctionNG = "ChangeservicetimerappsettingsXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в servicetimerappsettings приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений servicetimerappsettings на сервере $servernode" -ForegroundColor 'Gray';
 
 $servicetimerappsettingsfullPath = "\\$servernode\$servicetimerappsettings"
 logstamp; Write-Host " Путь до фаила $servicetimerappsettingsfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$servicetimerappsettingsfullPath")
 logstamp; Write-Host " Загрузка XML $servicetimerappsettingsfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $servicetimerappsettingsfullPath" -ForegroundColor 'Gray';
 
 $xml.SelectNodes("/appSettings/add[@key='example.merchant-support-email-from']") | % {$_.'value' = 'feedback@EXAMPLE_TXTsystem.com'}
 $xml.SelectNodes("/appSettings/add[@key='example.merchant-support-email-to']") | % {$_.'value' = 'support@EXAMPLE_TXTsystem.com'}
  
  logstamp; Write-Host " Сохранение измененного XML $servicetimerappsettingsfullPath" -ForegroundColor 'Green';
  $xml.Save($servicetimerappsettingsfullPath)
 
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в servicetimerappsettings приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в servicetimerappsettings приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в servicetimerappsettings приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в servicetimerappsettings приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в servicetimerappsettings приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в servicetimerappsettings приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
 
Function ChangeAPPtimerconfigXML {
#########################################################
$FunctionNG = "ChangeAPPtimerconfigXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в APPtimerconfig приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений APPtimerconfig на сервере $servernode" -ForegroundColor 'Gray';
 
 $apptimerconfigfullPath = "\\$servernode\$apptimerconfig"
 logstamp; Write-Host " Путь до фаила $apptimerconfigfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$apptimerconfigfullPath")
 logstamp; Write-Host " Загрузка XML $apptimerconfigfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $apptimerconfigfullPath" -ForegroundColor 'Gray';
 
  #$xml2working = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters")
  #$LoginMgMn = $xml.SelectNodes("/castle/components/component[@id='mtt.settings']/parameters/LoginMgMn") | % { $_.Node.'#text' = 'test' $_.Node.SomeAttribute = 'value'}
 
  #STEP1 MEMCACHE CHANGE
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1']") 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2']")
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1']") | % {$_.'host' = 'nh_memcached_1.example.loc'}
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2']") | % {$_.'host' = 'nh_memcached_2.example.loc'}
 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_1.example.loc']") 
 $xml.SelectNodes("/configuration/memcache/memcached[@host='nh_memcached_2.example.loc']")
 
  #STEP2 SQL ENDPOINT CHANGE
 
 $xml.SelectNodes("/configuration/activerecord/config/add[@key='connection.connection_string']") | % {$_.'value' = 'server=EXAMPLE_TXT-SQL;database=example;trusted_connection=true;Max Pool Size=1000;Pooling=true;Timeout=110'}
 
  #STEP3 ADD ATRIBUTE LOG4NET
  
 $STEP3 = $xml.SelectNodes("/configuration/log4net")
 
 $lockingModel = $xml.CreateElement("lockingModel")
 $lockingModel.SetAttribute(“type”,”log4net.Appender.FileAppender+MinimalLock”);
 
 $STEP3.AppendChild($lockingModel)
  
  
  #STEP4
  
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/to") | % {$_.'value' = 'error@EXAMPLE_TXTsystem.com'}
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/from") | % {$_.'value' = 'support@EXAMPLE_TXTsystem.com'}
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/smtpHost") | % {$_.'value' = 'mailer.example.loc'}
   $xml.SelectNodes("/configuration/log4net/appender[@name='mail']/subject") | % {$_.'value' = 'EXAMPLE_TXT.AMO.APP.Timer Error'}
   $xml.SelectNodes("/configuration/log4net/appender[@name='mongo']/host") | % {$_.'#text' = 'nosql.example.loc'}
   
   #STEP5
   $xml.SelectNodes("/configuration/system.net/mailSettings/smtp") | % {$_.'from' = 'support@EXAMPLE_TXTsystem.com'}
   $xml.SelectNodes("/configuration/system.net/mailSettings/smtp/network") | % {$_.'host' = 'mailer.example.loc'}
   
   #STEP6
   
   $xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Dispatch']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Dispatch'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Write'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXT/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXT/ServiceGateway.svc/Write'}
$xml.SelectNodes("/configuration/system.serviceModel/client/endpoint[@address='net.msmq://msmq/EXAMPLE_TXTProcessor/ServiceGateway.svc/Write']") | % {$_.'address' = 'net.msmq://ipt-EXAMPLE_TXT-mq/EXAMPLE_TXTProcessor/ServiceGateway.svc/Write'}
 
  
  logstamp; Write-Host " Сохранение измененного XML $apptimerconfigfullPath" -ForegroundColor 'Green';
  $xml.Save($apptimerconfigfullPath)
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в APPtimerconfig приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в APPtimerconfig приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в APPtimerconfig приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в APPtimerconfig приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в APPtimerconfig приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в APPtimerconfig приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
Function ChangeAPPtimernlogconfigXML {
#########################################################
$FunctionNG = "ChangeAPPtimernlogconfigXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в APPtimernlogconfig приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений APPtimernlogconfig на сервере $servernode" -ForegroundColor 'Gray';
 
 $apptimernlogconfigfullPath = "\\$servernode\$apptimernlogconfig"
 logstamp; Write-Host " Путь до фаила $apptimernlogconfigfullPath" -ForegroundColor 'Gray';
  
  
  
  
 $xml=New-Object XML
 $xml.Load("$apptimernlogconfigfullPath")
 logstamp; Write-Host " Загрузка XML $apptimernlogconfigfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $apptimernlogconfigfullPath" -ForegroundColor 'Gray';
 
 $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
 $ns.AddNamespace("ns", "http://www.nlog-project.org/schemas/NLog.xsd")
 $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")
 $xml.SelectNodes("//ns:nlog/ns:targets/ns:target", $ns) | % {$_.'host' = 'nosql.example.loc'}
 logstamp; Write-Host " Сохранение измененного XML $apptimernlogconfigfullPath" -ForegroundColor 'Green';
  $xml.Save($apptimernlogconfigfullPath)
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в APPtimernlogconfig приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в APPtimernlogconfig приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в APPtimernlogconfig приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в APPtimernlogconfig приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в APPtimernlogconfig приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в APPtimernlogconfig приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
Function ChangeAPPtimerjoblistXML {
#########################################################
$FunctionNG = "ChangeAPPtimerjoblistXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в APPtimerjoblist приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений APPtimerjoblist на сервере $servernode" -ForegroundColor 'Gray';
 
 $APPtimerjoblistfullPath = "\\$servernode\$apptimerjoblist"
 logstamp; Write-Host " Путь до фаила $APPtimerjoblistfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$APPtimerjoblistfullPath")
 logstamp; Write-Host " Загрузка XML $APPtimerjoblistfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $APPtimerjoblistfullPath" -ForegroundColor 'Gray';
 
 #DELETING SECTION
 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.EXAMPLE_TXTMasterStatus}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.Settle.AmadeusWebServices}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromAzeriCard}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromTCB}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.Settle.GdsGalileo}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.Settle.GdsAmadeus}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.Settle.GdsSabre}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromBankOfMoscow}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTcbEXAMPLE_TXTStartTransactions}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.NotifyExpiredCertificatesJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.UpdateFileForExternalMonitoring}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.UpdateExpectedPresentmentCommissionJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromPrivatBank}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromEXAMPLE_TXTStartBankOfMoscow}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }}
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromRaiffeisenBank}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
						
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.AzeriEXAMPLE_TXToutsSetEXAMPLE_TXTStatusJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.AzeriEXAMPLE_TXToutsSetNoResponseStatusJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.AzeriEXAMPLE_TXToutsCreateFileJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.AzeriEXAMPLE_TXToutsProcessFileStatusJob}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.AuthentificationNotCompleted}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromBankOfMoscowIPT}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item") | foreach-object { if ($_."#text" -eq "`${job.SettleTransactionsFromKazKom}") {$b = $_ ; $b.ParentNode.RemoveChild($b) }} 
 
 #ADDING SECTION
 
  $select4clone = $xml.SelectNodes("/castle/components/component[@id='job.JobsList']/parameters/jobs/array/item").Item(0)
  logstamp; Write-Host " Клонируем значения" -ForegroundColor 'Gray';
  $c = $select4clone.Clone()
  $d = $select4clone.Clone()
  logstamp; Write-Host " Меняем текст значений" -ForegroundColor 'Gray';
  $c.InnerText = "`${job.SettleTransactionsFromOptimalEXAMPLE_TXTments}"
  $d.InnerText = "`${job.SettleTransactionsFromOptimalEXAMPLE_TXTmentsTest}"
  logstamp; Write-Host " Добавляем значения к родителю" -ForegroundColor 'Gray';
  $select4clone.ParentNode.AppendChild($c)
  $select4clone.ParentNode.AppendChild($d)
  
  #SAVE SECTION
  
  logstamp; Write-Host " Сохранение измененного XML $APPtimerjoblistfullPath" -ForegroundColor 'Green';
  $xml.Save($APPtimerjoblistfullPath)
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в APPtimerjoblist приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в APPtimerjoblist приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в APPtimerjoblist приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в APPtimerjoblist приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в APPtimerjoblist приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в APPtimerjoblist приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
Function ChangeAPPtimerappsettingsXML {
#########################################################
$FunctionNG = "ChangeAPPtimerappsettingsXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в APPtimerappsettings приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений APPtimerappsettings на сервере $servernode" -ForegroundColor 'Gray';
 
 $apptimerappsettingsfullPath = "\\$servernode\$apptimerappsettings"
 logstamp; Write-Host " Путь до фаила $apptimerappsettingsfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$apptimerappsettingsfullPath")
 logstamp; Write-Host " Загрузка XML $apptimerappsettingsfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $apptimerappsettingsfullPath" -ForegroundColor 'Gray';
 
 $xml.SelectNodes("/appSettings/add[@key='example.merchant-support-email-from']") | % {$_.'value' = 'feedback@EXAMPLE_TXTsystem.com'}
 $xml.SelectNodes("/appSettings/add[@key='example.merchant-support-email-to']") | % {$_.'value' = 'support@EXAMPLE_TXTsystem.com'}
 
  
  logstamp; Write-Host " Сохранение измененного XML $apptimerappsettingsfullPath" -ForegroundColor 'Green';
  $xml.Save($apptimerappsettingsfullPath)
 
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в APPtimerappsettings приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в APPtimerappsettings приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG ЗЗамена значений в APPtimerappsettings приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в APPtimerappsettings приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    #XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в APPtimerappsettings приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в APPtimerappsettings приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }
 
Function ChangeSecureGatewaysXML {
[CmdletBinding()]  
Param
 (
  [parameter(Mandatory=$True)][String]$servernode,
  [parameter(Mandatory=$True)][String]$RelConfigurationDIRGateways
 )
#########################################################
$FunctionNG = "ChangeSecureGatewaysXML"
#########################################################
logstamp; Write-Host " Запуск функции замены значений в Gateways.xml приложения на сервере $servernode" -ForegroundColor 'Gray';
 try{
 logstamp; Write-Host " Начало замены значений в Gateways.xml на сервере $servernode" -ForegroundColor 'Gray';
 
 $GatewaysXMLfullPath = "\\$servernode\$RelConfigurationDIRGateways"
 logstamp; Write-Host " Путь до фаила $GatewaysXMLfullPath" -ForegroundColor 'Gray';
  
 $xml=New-Object XML
 $xml.Load("$GatewaysXMLfullPath")
 logstamp; Write-Host " Загрузка XML $GatewaysXMLfullPath завершена" -ForegroundColor 'Gray';
 logstamp; Write-Host " Начало обработки XML $GatewaysXMLfullPath" -ForegroundColor 'Gray';
 
 #$xml.SelectNodes("/castle/components/component[@id='gateway.wirecard']/parameters/primaryCurrency")| % {$_.'#text' = 'USD'}
 #$xml.SelectNodes("/castle/components/component[@id='gateway.firstEXAMPLE_TXTments.test']/parameters/gatewayUrl") | % {$_.'#text' = 'https://govno.net/gw2test/gwprocessor2.php'}
 $xml.SelectNodes("/castle/components/component[@id='gateway.firstEXAMPLE_TXTments.test']/parameters/gatewayUrl") | % {$_.'#text' = 'https://www3.1stEXAMPLE_TXTments.net/gw2test/gwprocessor2.php'}
 $xml.SelectNodes("/castle/components/component[@id='gateway.kazkom.test']/parameters/GatewayUri") | % {$_.'#text' = 'https://testEXAMPLE_TXT.kkb.kz/EEXAMPLE_TXTService.svc'}
 $xml.SelectNodes("/castle/components/component[@id='gateway.raiffeisen.test']/parameters/AuthUrl") | % {$_.'#text' = 'https://e-commerce.raiffeisen.ru/vsmc3ds_test/gate/example/'}
 $xml.SelectNodes("/castle/components/component[@id='gateway.raiffeisen.test']/parameters/OperationsUrl") | % {$_.'#text' = 'https://e-commerce.raiffeisen.ru/portal_test/'}
 
 #$step17 = $xml.SelectNodes("/castle/components/component[@id='gateway.wirecard']/parameters/acceptableCurrencies/array") 
 #$GatewayModel = $xml.CreateElement("item")
 #$GatewayModel.InnerText = "USD"
 #$step17.AppendChild($GatewayModel)

  logstamp; Write-Host " Сохранение измененного XML $GatewaysXMLfullPath" -ForegroundColor 'Green';
  $xml.Save($GatewaysXMLfullPath)
  
     }
 catch{
		#########################################################
		$messageNG = " Function $FunctionNG : Замена значений в Gateways.xml приложения на сервере $servernode Прошла не удачно!"
	    $bodyNG = "Function $FunctionNG : Замена значений в Gateways.xml приложения на сервере $servernode Прошла не удачно!";
	    $subjectNG = "Function $FunctionNG Замена значений в Gateways.xml приложения на сервере $servernode Прошла не удачно!"
		#########################################################
		#########################################################
		logstamp; Write-Host " Замена значений в Gateways.xml приложения на сервере $servernode Прошла не удачно" -ForegroundColor 'Red';
		$err = $_.Exception;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		while( $err.InnerException ) {
		$err = $err.InnerException;
		logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
		#########################################################
	    logstamp; Write-Host "$messageNG" -ForegroundColor 'Red';
	    #########################################################
	    NotificationNG;
	    XwaitNG;
		}
	}
 finally{
 logstamp; Write-Host " Замена значений в Gateways.xml приложения на сервере $servernode Завершена" -ForegroundColor 'Green';
 }
 logstamp; Write-Host " Работа функции замены значений в Gateways.xml приложения на сервере $servernode окончена." -ForegroundColor 'Gray';
 }