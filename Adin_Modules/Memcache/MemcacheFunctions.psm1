#########################################################
# Memcache Functions
#########################################################

Function global:StartMemcache() {
logstamp; Write-Host " ������ �������: ������ ������� Memcached" -ForegroundColor 'Magenta';	
foreach ($Aworker in $Memcacheservers.values) {
										try{
										logstamp; Write-Host " ������� ������� ������� $Memcacheservice �� ������� $Aworker" -ForegroundColor 'Green';	
										start-service -inputobject $(get-service -ComputerName $Aworker -Name $Memcacheservice)
											}
										catch{
											logstamp; Write-Host " ��������! ������� ��������� � ��������! ������ $Memcacheservice �� ������� $Aworker �� �������!" -ForegroundColor 'Red';	
											$err = $_.Exception;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											while( $err.InnerException ) {
											$err = $err.InnerException;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											}
											$body = "��������! ������� ��������� � ��������! ������ $Memcacheservice �� ������� $Aworker �� �������!";
											send_email;
											}
										finally{
										logstamp; Write-Host " ������� ������� ������� ���������" -ForegroundColor 'Green';	
											}
										}
}

Function global:StopMemcache() {
logstamp; Write-Host " ������ �������: ��������� ������� Memcached" -ForegroundColor 'Magenta';
foreach ($Aworker in $Memcacheservers.values) {
										try{
										logstamp; Write-Host " ������� ��������� ������� $Memcacheservice �� ������� $Aworker" -ForegroundColor 'Green';
										stop-service -inputobject $(get-service -ComputerName $Aworker -Name $Memcacheservice)
										}
										catch{
										logstamp; Write-Host " ��������! ������� ��������� � ��������! ������ $Memcacheservice �� ������� $Aworker �� ����������!!" -ForegroundColor 'Red';
											$err = $_.Exception;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											while( $err.InnerException ) {
											$err = $err.InnerException;
											logstamp; Write-Host "$err.Message" -ForegroundColor 'Yellow';
											}
										$body = "��������! ������� ��������� � ��������! ������ $Memcacheservice �� ������� $Aworker �� ����������!!";
											send_email;
										}
										finally{
										logstamp; Write-Host " ������� ��������� ������� ���������" -ForegroundColor 'Green';	
										}
										}
}
