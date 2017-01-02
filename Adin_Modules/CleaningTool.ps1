
function global:Remove-ItemRecursiveBruteForce            
{            
    param(            
        [Parameter(Position = 0, Mandatory=$true, ValueFromPipeline=$false)]            
        [string]$folder,            
        [Parameter(Position = 1, Mandatory=$False, ValueFromPipeline=$false)]            
        $maxiterations = 20            
    )            
            
    $iteration = 0            
    while (  $iteration++ -lt   $maxiterations)            
    {            
        if (Test-Path $folder)            
        {            
           #Get-ChildItem $folder | remove-item -ErrorAction SilentlyContinue -Force -Confirm:$false -Recurse        
		   
		   Get-ChildItem -Path $folder -Recurse -force |
  Where-Object { -not ($_.psiscontainer) } |
   Remove-Item –Force

Remove-Item -Recurse -Force $folder
        }            
        else            
        {            
             Write-Host "$folder deleted in $iteration iterations"            
            break            
        }            
    }            
    if (Test-Path $folder)            
    {            
         Write-Host "$folder not empty after $iteration iterations"            
    }            
            
}       
function global:Create-ItemRecursive        
{            
    param(            
        [Parameter(Position = 0, Mandatory=$true, ValueFromPipeline=$false)]            
        [string]$folder,            
        [Parameter(Position = 1, Mandatory=$False, ValueFromPipeline=$false)]            
        $maxiterations = 20            
    )            
            
    $iteration = 0            
    while (  $iteration++ -lt   $maxiterations)            
    {            
        if (Test-Path $folder)            
        {            
            New-Item $folder -Type Directory   
        }            
        else            
        {            
             Write-Host "$folder created in $iteration iterations"            
            break            
        }            
    }            
    if (Test-Path $folder)            
    {            
         Write-Host "$folder not empty after $iteration iterations"            
    }            
            
}       
Function global:ClearUpTimerApplication {
$TimerPath = $args[0];
logstamp; Write-Host " Запуск функции очистки директории: Очистка приложения Timer $TimerValue запущена" -ForegroundColor 'Gray';
logstamp; Write-Host " Процесс очистки сервиса $TimerValue" -ForegroundColor 'Yellow';

$global:body = "Очистка директории: Приложения Timer $TimerValue запущена!";
$global:subject = " [START MODULE] Автоматическое обновление: Очистка директории запущена!";
send_email;

 try{
		#$suprimepath = $TimerPath + "*"
		#Get-ChildItem -Path $TimerPath -Include *.* -File -Recurse | remove-Item -recurse 
		#Get-ChildItem "$TimerPath\*" -Recurse -Force | Where-Object {!$_.PSIsContainer} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
		#logstamp; Write-Host " Путь к папке $TimerPath" -ForegroundColor 'Yellow';
		#$fso = New-Object -ComObject scripting.filesystemobject
		#$superclean = "$fso.DeleteFolder("$TimerPath",$true)"
		#Measure-Command {$superclean}
		#EmptyDirectory $TimerPath
		#Get-ChildItem -Path $TimerPath -Include *.* -File -Recurse | % { $_.IsReadOnly=$false };
		#Get-ChildItem -Path $TimerPath -Include *.* -File -Recurse | foreach ($_) {remove-item $_.FullName};
		#Get-ChildItem "$TimerPath" -Recurse | foreach {$_.Attributes = 'Normal'}
		#Get-ChildItem "$TimerPath" | remove-item -ErrorAction SilentlyContinue -Force -Confirm:$false -Recurse 
		Remove-ItemRecursiveBruteForce -Folder $TimerPath;
		Create-ItemRecursive -Folder $TimerPath;
		#Get-ChildItem "$TimerPath" -Recurse -Force | Where-Object {!$_.PSIsContainer} | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
		#Get-ChildItem "$TimerPath" | remove-item
		#Get-ChildItem "$TimerPath" -Recurse -Force | foreach ($_) {remove-item $_.FullName -Force -Recurse};
        #Remove-Item $TimerPath\* -Force -Recurse
		#remove-item "$TimerPath"*.* -Recurse -Force
		#Measure-Command {dir "$TimerPath" | foreach { [io.directory]::delete($_.fullname,$true) }}
		#Remove-Item "$suprimepath" -Recurse -Force
		#Get-ChildItem -Path $TimerPath -Include *.* -File -Recurse | foreach ($_) {remove-item $_.FullName}
		#Get-ChildItem -Path $TimerPath -Include *.* -File -Recurse | foreach ($_) {remove-item $_ Remove-Item -Recurse -Force}
		#Get-ChildItem -Path $TimerPath -Include *.* -File -Recurse | foreach { $_.Delete()}
	 }
 catch{
	 logstamp; Write-Host " Очистка директории: Приложения Timer $TimerValue провалена!. Отправляю почтовое сообщение. Процесс ожидает действий оператора." -ForegroundColor 'Red';
			$err = $_.Exception;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			while( $err.InnerException ) {
			$err = $err.InnerException;
			logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
			}
			
	 $global:body = "Очистка директории: Приложения Timer $TimerValue провалена!";
	 $global:subject = " [FAIL MODULE] Автоматическое обновление: Очистка директории провалена!";
	 send_email;
	 
	 logstamp; Write-Host " Очистка директории: Приложения Timer $TimerValue провалена!" -ForegroundColor 'Red'
	 logstamp; Write-Host " Пожалуйста нажмите любую клавижу для продолжения или введите Х для остановки процесса" -ForegroundColor 'Red'
	 $BackupTryToContinue = Read-Host
  If ($BackupTryToContinue -eq "X") 
     {logstamp; Write-Host " Ваш выбор: остановить процесс" -ForegroundColor 'Red';
	 logstamp; Write-Host " До завершения осталось 10 секунд" -ForegroundColor 'Red';
	 sleep 10;
	 exit;
	 }
	else{logstamp; Write-Host " Ваш выбор: продолжить процесс" -ForegroundColor 'Green';}
	}
 finally{
     logstamp; Write-Host " Очистка директории: Очистка приложения $TimerValue окончена. Пожалуйста проверьте вашу почту."  -ForegroundColor 'Green';
	     }
 logstamp; Write-Host " Ожидание: Ожидание после очистки $TimerValue" -ForegroundColor 'Gray';
 Sleep 5
 
 $global:body = "Очистка директории: Приложения Timer $TimerValue завершено!";
 $global:subject = " [COMPLETE MODULE] Автоматическое обновление: Очистка директории приложения $TimerValue завершена!";
 send_email;

 logstamp; Write-Host " Функция очистки директории сервиса завершила работу." -ForegroundColor 'Gray';
 }