#########################################################
#Auto Deploy IIS 7 on NLB ALL ;
#Program:	ADIN 3.6.5-all;
#Author:	Rostislav Grigoriev;
#Date:		20/05/2015;
#Company:	example System LLC;
#Support:	r.grigoryev@example.ru;
#Version:   3.6.5-all; en
#
#########################################################
# Switched script
#########################################################
$console = $host.UI.RawUI
$buffer = $console.BufferSize
$buffer.Width = 200
$buffer.Height = 2500
$console.BufferSize = $buffer

#########################################################
#Загрузка модуля нормального логирования
#########################################################

Import-Module PowerShellLogging 
import-module WPFRunspace
#########################################################
# Dynamic Loading modules # Загрузка модулей
#########################################################

Import-Module ".\Adin_modules\GlobalFunctions.psm1"
Import-Module ".\Adin_modules\SQL\SQLsetup.psm1"
Import-Module ".\Adin_modules\Memcache\MemcacheFunctions.psm1"
Import-Module ".\Adin_modules\Cluster\ClusterFunctions.psm1"
Import-Module ".\Adin_modules\TimersFunctions.psm1"
Import-Module ".\Adin_modules\Invoke-MsBuild.psm1"
."./Adin_modules/WorkedForm.Ps1"

[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
 Add-Type -Assembly PresentationFramework            
 Add-Type -Assembly PresentationCore         

$SuperFormNG.Runspace = $rs

$handle = $SuperFormNG.BeginInvoke() 

While (!($global:superjob -eq "Start")) {Start-Sleep -Seconds 1; Write-Host " Await job"}

Write-Host "Command to $superjob"
$global:superjob = "Inprogress";
Write-Host "Current state superjob $superjob"
Write-Host "Current state DisableBackup $DisableBackup"
Write-Host "Current state SYNC $SYNC"
Write-Host "Current state RERUNSQL $RERUNSQL"
Write-Host "Current state SERVICEUPDATE $SERVICEUPDATE"
Write-Host "Current state TimerUpdateState $TimerUpdateState"
Write-Host "Current state SecureUpdateState $SecureUpdateState"
$global:RunnerExePath = $pwd.Path;

powershell.exe $RunnerExePath\Adin_Modules\GetTypeOfUpdateFormNG.ps1 -env $env -echoPathVersionTyped $echoPathVersion -TimerUpdateState $TimerUpdateState -SecureUpdateState $SecureUpdateState -DisableBackup $DisableBackup -RERUNSQL $RERUNSQL -SERVICEUPDATE $SERVICEUPDATE | ForEach-Object {
if($_){
#Write-Host "Current $_ ";
$lu = $_
#$x.Listbox1.Dispatcher.invoke([action]{$x.ListBox1.Items.Add("$lu")},"Send")
$x.Listbox1.Dispatcher.invoke([action]{$x.ListBox1.Items.Add("$lu")},"Input")
#$x.Listbox1.SelectedIndex = $x.Listbox1.Items.Count - 1;
#$x.Listbox1.SelectedIndex = -1;
$x.ListBox1.Items.MoveCurrentToLast();
$x.ListBox1.ScrollIntoView($x.ListBox1.Items.CurrentItem);

}}
