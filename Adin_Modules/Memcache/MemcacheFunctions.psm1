#########################################################
# Memcache Functions
#########################################################

Function global:StartMemcache() {
logstamp; Write-Host " Запуск функции: Запуск сервиса Memcached" -ForegroundColor 'Magenta';	
foreach ($Aworker in $Memcacheservers.values) {
										try{
										logstamp; Write-Host " Попытка запуска сервиса $Memcacheservice на сервере $Aworker" -ForegroundColor 'Green';	
										start-service -inputobject $(get-service -ComputerName $Aworker -Name $Memcacheservice)
											}
										catch{
											logstamp; Write-Host " Внимание! Функция выполнена с ошибками! Сервис $Memcacheservice на сервере $Aworker не запущен!" -ForegroundColor 'Red';	
											$err = $_.Exception;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											while( $err.InnerException ) {
											$err = $err.InnerException;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											}
											$body = "Внимание! Функция выполнена с ошибками! Сервис $Memcacheservice на сервере $Aworker не запущен!";
											send_email;
											}
										finally{
										logstamp; Write-Host " Функция запуска сервиса завершена" -ForegroundColor 'Green';	
											}
										}
}

Function global:StopMemcache() {
logstamp; Write-Host " Запуск функции: Остановка сервиса Memcached" -ForegroundColor 'Magenta';
foreach ($Aworker in $Memcacheservers.values) {
										try{
										logstamp; Write-Host " Попытка остановки сервиса $Memcacheservice на сервере $Aworker" -ForegroundColor 'Green';
										stop-service -inputobject $(get-service -ComputerName $Aworker -Name $Memcacheservice)
										}
										catch{
										logstamp; Write-Host " Внимание! Функция выполнена с ошибками! Сервис $Memcacheservice на сервере $Aworker не остановлен!!" -ForegroundColor 'Red';
											$err = $_.Exception;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											while( $err.InnerException ) {
											$err = $err.InnerException;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											}
										$body = "Внимание! Функция выполнена с ошибками! Сервис $Memcacheservice на сервере $Aworker не остановлен!!";
											send_email;
										}
										finally{
										logstamp; Write-Host " Функция остановки сервиса завершена" -ForegroundColor 'Green';	
										}
										}
}
