Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
 
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

import-module WPFRunspace
add-WpfAccelerators 

function Show-Console {
   $consolePtr = [Console.Window]::GetConsoleWindow()
  #5 show
 [Console.Window]::ShowWindow($consolePtr, 5)
}
 
function Hide-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
  #0 hide
 [Console.Window]::ShowWindow($consolePtr, 0)
}
$pwd = pwd
$Global:Ge = Split-Path $pwd -Parent

$Global:AvailibleVersions2 = Get-ChildItem $Global:ge | select-object $_.Name | select-string -pattern "\d{1}[.]\d{2}[.]\d{1}[.]\d{5}"
$Global:AvailibleVersions2 = Get-ChildItem $Global:ge | select-object $_.Name | select-string -pattern "\d{1}[.]\d{1}[.]\d{1}"
$Global:AvailibleVersions = $Global:AvailibleVersions2 | Sort-Object -descending
$Global:AvailibleServices = Get-ChildItem $Global:ge | select-object $_.Name | select-string -pattern "\d{1}[.]\d{2}[.]\d{1}[.]\d{5}"
$Global:AvailibleForms = Get-ChildItem $Global:ge | select-object $_.Name | select-string -pattern "\d{1}[.]\d{2}[.]\d{1}[.]\d{5}"
Hide-Console;
$Global:x = [Hashtable]::Synchronized(@{})
$Global:x.Host = $Host
$rs = [RunspaceFactory]::CreateRunspace()
$rs.ApartmentState,$rs.ThreadOptions = "STA","ReUseThread"
$rs.Open()
$rs.SessionStateProxy.SetVariable("x",$x)
$rs.SessionStateProxy.SetVariable('superpwd',$pwd)
$rs.SessionStateProxy.SetVariable('AvailibleVersions',$AvailibleVersions)
#$global:x.superpwd = $pwd.path
$SuperFormNG = [PowerShell]::Create().AddScript({

 Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
 $Global:x.w = [Windows.Markup.XamlReader]::Parse(@"
    <Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="example GUI UPDATER TOOL" Height="510" Width="1331.5" AllowsTransparency="False" ResizeMode="NoResize">
    <Grid>
    	<GroupBox Header="Выбор окружения" HorizontalAlignment="Left" Margin="19,0,0,88" VerticalAlignment="Bottom" Height="190" Width="137" RenderTransformOrigin="0.686,0.505"/>
		<RadioButton Name="RBx1" Content="LIVE" HorizontalAlignment="Left" Margin="28,238,0,0" VerticalAlignment="Top" />
        <RadioButton Name="RBx2" Content="STAGE" HorizontalAlignment="Left" Margin="28,281,0,0" VerticalAlignment="Top" />
        <RadioButton Name="RBx3" Content="DEV" HorizontalAlignment="Left" Margin="28,324,0,0" VerticalAlignment="Top" />
        <RadioButton Name="RBx4" Content="TEST" HorizontalAlignment="Left" Margin="28,365,0,0" VerticalAlignment="Top" />
		<ListBox Name="LBx2" HorizontalAlignment="Left" Height="387" Margin="695,67,0,0" VerticalAlignment="Top" Width="600" />
		<Image Name="Image" HorizontalAlignment="Left" Height="100" Margin="37,31,0,0" VerticalAlignment="Top" Width="100" Source="$superpwd\Adin_Modules\Images\mini-logo.png" StretchDirection="Both"/>
		<Button Name="BNx1" Content="Запуск" HorizontalAlignment="Left" Margin="151,433,0,0" VerticalAlignment="Top" Width="92" Height="30"/>
        <Button Name="BNx2" Content="Отмена" HorizontalAlignment="Left" Margin="257,433,0,0" VerticalAlignment="Top" Width="92" Height="30"/>
		<CheckBox Name="SCx1" Content="Обновление таймеров" HorizontalAlignment="Left" Margin="438,281,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="SCx3" Content="Обновление приложения IIS" HorizontalAlignment="Left" Margin="438,256,0,0" VerticalAlignment="Top"/>
        <CheckBox Name="SCx2" Content="Отключить создание резервных копий" HorizontalAlignment="Left" Margin="438,398,0,0" VerticalAlignment="Top" />
		<ListBox Name="LBx1" HorizontalAlignment="Left" Height="175" Margin="205,67,0,0" VerticalAlignment="Top" Width="437"/>
		<TextBlock HorizontalAlignment="Left" Margin="327,31,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="237"><Run Text="Пожалуйста выберите версию "/><Run Language="ru-ru" Text="пакета"/><Run Text=":"/></TextBlock>
        <TextBlock Name="TBx1" HorizontalAlignment="Left" Margin="10,148,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="170"><Run Text="example GUI UPDATER TOOL"/><LineBreak/><Run Text="ADIN Version 3."/><Run Language="ru-ru" Text="7"/></TextBlock>
		<Button Name="BNx3" Content="Скрыть вывод" HorizontalAlignment="Left" Margin="364,433,0,0" VerticalAlignment="Top" Width="92" Height="30" />
        <Button Name="BNx4" Content="Включить вывод" HorizontalAlignment="Left" Margin="472,433,0,0" VerticalAlignment="Top" Width="92" Height="30" />
		<TextBlock Name="TBx2" HorizontalAlignment="Left" Margin="929,31,0,0" TextWrapping="Wrap" VerticalAlignment="Top"><Run Language="ru-ru" Text="Журнал происходящих событий"/></TextBlock>
		<CheckBox Name="SCx4" Content="Быстрый вывод серверов NLB" HorizontalAlignment="Left" Margin="438,329,0,0" VerticalAlignment="Top" />
		<CheckBox Name="SCx5" Content="Выполнение запросов SQL" HorizontalAlignment="Left" Margin="438,375,0,0" VerticalAlignment="Top" />
		<ComboBox Name="CBx1" HorizontalAlignment="Left" Margin="205,278,0,0" VerticalAlignment="Top" Width="195">
			<ComboBoxItem Name="CBSYNCx1" Content="Live => Dev"/>
			<ComboBoxItem Name="CBSYNCx2" Content="Stage => Dev"/>
			<ComboBoxItem Name="CBSYNCx3" Content="Dev => Stage"/>
		</ComboBox>
        <TextBlock HorizontalAlignment="Left" Margin="205,260,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="161"><Run Language="ru-ru" Text="В"/><Run Text="ыберите ноду синхронизации:"/></TextBlock>
		<CheckBox Name="SCx6" Content="Обновление сервисов" HorizontalAlignment="Left" Margin="438,304,0,0" VerticalAlignment="Top"/>
		<ComboBox Name="CBx2" HorizontalAlignment="Left" Margin="205,325,0,0" VerticalAlignment="Top" Width="195">
			<ComboBoxItem Content="Default Current"/>
			<ComboBoxItem Content="Live => Dev"/>
			<ComboBoxItem Content="Stage => Dev"/>
			<ComboBoxItem Content="Env Recovery"/>
		</ComboBox>
        <TextBlock HorizontalAlignment="Left" Margin="205,307,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="145"><Run Language="ru-ru" Text="В"/><Run Text="ыберите тип фаила Hosts"/><Run Text=":"/></TextBlock>
        <CheckBox Name="SCx7" Content="Отключение проверки версии" HorizontalAlignment="Left" Margin="438,352,0,0" VerticalAlignment="Top"/>
        <ComboBox Name="CBx3" HorizontalAlignment="Left" Margin="205,373,0,0" VerticalAlignment="Top" Width="195">
			<ComboBoxItem Content="Started"/>
			<ComboBoxItem Content="Stopped"/>
		</ComboBox>
        <TextBlock HorizontalAlignment="Left" Margin="205,355,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="180"><Run Text="MemCached "/><Run Language="ru-ru" Text="в конце процесса"/><Run Text=":"/></TextBlock>
    </Grid>
</Window>
"@)

$Global:x.GroupBox = $Global:x.w.FindName('GroupBox')
$Global:x.RadioButton = $Global:x.w.FindName('RBx1')
$Global:x.RadioButton1 = $Global:x.w.FindName('RBx2')
$Global:x.RadioButton2 = $Global:x.w.FindName('RBx3')
$Global:x.RadioButton3 = $Global:x.w.FindName('RBx4')
$Global:x.ListBox1 = $Global:x.w.FindName('LBx2')

$Global:x.Image = $Global:x.w.FindName("Image")

$Global:x.OK = $Global:x.w.FindName('BNx1')
$Global:x.Cancel = $Global:x.w.FindName('BNx2')
$Global:x.BNx3 = $Global:x.w.FindName('BNx3')
$Global:x.BNx4 = $Global:x.w.FindName('BNx4')
#SYNCSD
#SYNCLD
#SYNCLS
#$x.w.Grid.Add_Loaded({
#    $x.Grid.Orientation = "JournalViewOn"
#})

$Global:x.CheckBox1 = $Global:x.w.FindName('SCx1')
$Global:x.CheckBox2 = $Global:x.w.FindName('SCx2')
$Global:x.CheckBox3 = $Global:x.w.FindName('SCx3')
$Global:x.CheckBox4 = $Global:x.w.FindName('SCx4')
$Global:x.CheckBox5 = $Global:x.w.FindName('SCx5')
$Global:x.CheckBox6 = $Global:x.w.FindName('SCx6')
$Global:x.CheckBox7 = $Global:x.w.FindName('SCx7')
$Global:x.ListBox2 = $Global:x.w.FindName('LBx1')

$Global:x.ComboBox1 = $Global:x.w.FindName('CBx1')
$Global:x.ComboBox2 = $Global:x.w.FindName('CBx2')
$Global:x.ComboBox3 = $Global:x.w.FindName('CBx3')

$Global:x.ComboBoxItem1 = $Global:x.w.FindName('CBSYNCx1')
$Global:x.ComboBoxItem2 = $Global:x.w.FindName('CBSYNCx2')
$Global:x.ComboBoxItem3 = $Global:x.w.FindName('CBSYNCx3')


Foreach ($i in $Global:AvailibleVersions)

{
[void] $Global:x.ListBox2.Items.Add("$i")
}

Function Show-Console {
   $consolePtr = [Console.Window]::GetConsoleWindow()
  #5 show
 [Console.Window]::ShowWindow($consolePtr, 5)
}
 
Function Hide-Console {
    $consolePtr = [Console.Window]::GetConsoleWindow()
  #0 hide
 [Console.Window]::ShowWindow($consolePtr, 0)
}

Function OnClickJobNG {

#$objForm.controls.refresh();
$Global:x.OK.IsEnabled = $false
$x=$Global:x.ListBox2.SelectedItem;
#[System.Windows.Forms.MessageBox]::Show("$x" , "Status")
#startTimer;
if ($x) {
		[System.Windows.Forms.MessageBox]::Show("Выбранная версия $x" , "Status")
		
		#Get-Variable * | Export-Clixml $pwd\OnClickJobNG.xml
		#[System.Windows.Forms.MessageBox]::Show("Superjob $superjob" , "Status")
		if (!$Global:count) {
						[System.Windows.Forms.MessageBox]::Show("Вы не выбрали продукты для обновления" , "Status")
						$Global:x.OK.IsEnabled = $true
						$Global:x.w.controls.refresh()
					} else {
							[System.Windows.Forms.MessageBox]::Show("Выбрано продуктов для обновления: $count" , "Status")
							
							if (!$env) {
										[System.Windows.Forms.MessageBox]::Show("Вы не выбрали окружение" , "Status")
										$Global:x.OK.IsEnabled = $true
										$Global:x.w.controls.refresh()
							}
							else
							{
								#if ($TimerUpdateState) 
								#{
									#if($SecureUpdateState){
											#$global:SecureUpdateState = "True"
											#$global:TimerUpdateState = "True"
											
											#MainExec -env $env -echoPathVersionTyped $x -TimerUpdateState $TimerUpdateState -SecureUpdateState $SecureUpdateState
											$Global:x.OK.IsEnabled = $false
											$Global:x.w.controls.refresh()											
									#}
									#else
									#{
									#$global:SecureUpdateState = "false"
									#$global:TimerUpdateState = "True"
									#$Global:x.OK.IsEnabled = $false
									#$Global:x.w.controls.refresh()
									#MainExec -env $env -echoPathVersionTyped $x -TimerUpdateState $TimerUpdateState -SecureUpdateState $SecureUpdateState
									#}
								#}
								#else
								#{
									#$global:TimerUpdateState = "false"
									#$global:SecureUpdateState = "True"
									#$Global:x.OK.IsEnabled = $false
									#$Global:x.w.controls.refresh()
									#MainExec -env $env -echoPathVersionTyped $x -TimerUpdateState $TimerUpdateState -SecureUpdateState $SecureUpdateState | ForEach-Object {if($_){[void] $listBox1.Items.Add( $_ );$objForm.controls.refresh()};}
								#}
							#$Global:x.OK.IsEnabled = $true
							#$x.w.controls.refresh()
							}
						}

		} 
	else {
		[System.Windows.Forms.MessageBox]::Show("Не выбранна версия, попробуйте снова" , "Status")
		#objFormClose;
		#logstamp; Write-Host " Current Env $env" -ForegroundColor 'Red';
		#logstamp; Write-Host " Current echoPathVersionTyped $x" -ForegroundColor 'Red';
		#logstamp; Write-Host " Current TimerUpdateState $TimerUpdateState" -ForegroundColor 'Red';
		#logstamp; Write-Host " Current SecureUpdateState $SecureUpdateState" -ForegroundColor 'Red';
		#$objForm.DialogResult = "Ignore"
		$Global:x.OK.IsEnabled = $true
		$Global:x.w.controls.refresh()
		
		}
#stopTimer;
#$objForm.Close()

 $global:echoPathVersion = $x
 $global:environment = $env
 


 return $TimerUpdateState, $SecureUpdateState, $environment, $echoPathVersion, $SERVICEUPDATE
}




$Global:x.BNx3.add_Click({Hide-Console;})
$Global:x.BNx4.add_Click({Show-Console;})
$Global:x.OK.Add_Click({
OnClickJobNG;
$Global:superjob = "Start";

$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked2", $Global:env, $Global:env, "env")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked3", $Global:echoPathVersion, $Global:echoPathVersion, "echoPathVersion")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked4", $Global:TimerUpdateState, $Global:TimerUpdateState, "TimerUpdateState")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked5", $Global:SecureUpdateState, $Global:SecureUpdateState, "SecureUpdateState")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked1", $Global:superjob, $Global:superjob, "superjob")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked6", $Global:DisableBackup, $Global:DisableBackup, "DisableBackup")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked7", $Global:DRAINFASTNLB, $Global:DRAINFASTNLB, "DRAINFASTNLB")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked8", $Global:RERUNSQL, $Global:RERUNSQL, "RERUNSQL")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked9", $Global:SERVICEUPDATE, $Global:SERVICEUPDATE, "SERVICEUPDATE")
$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked10", $Global:APPVERSIONCHECK, $Global:APPVERSIONCHECK, "APPVERSIONCHECK")
#$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked7", $Global:superjob, $Global:superjob, "superjob")
#$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked6", $Global:superjob, $Global:superjob, "superjob")
#$Global:x.Host.Runspace.Events.GenerateEvent( "OkClicked6", $Global:superjob, $Global:superjob, "superjob")
})
$Global:x.Cancel.Add_Click({$Global:x.w.DialogResult = "OK"})

$x.listBox2.add_SelectionChanged({ $q = $Global:x.ListBox2.SelectedItem;$Global:x.ListBox1.Items.Add("Выбрана версия приложения IIS : $q ")}) 

$x.CheckBox3.Add_Checked({$Global:SecureUpdateState="true"; $Global:count++; $Global:x.ListBox1.Items.Add("Обновлять приложение IIS $SecureUpdateState : Количество приложений $count")})
$x.CheckBox3.Add_UnChecked({$Global:SecureUpdateState="false"; $Global:count--; $Global:x.ListBox1.Items.Add("Не Обновлять приложение. Количество приложений $count")})
$x.CheckBox3.Add_Loaded({$Global:SecureUpdateState="false"; $Global:x.ListBox1.Items.Add("Внимание! По умолчанию обновление приложения IIS отключено!")})
$x.CheckBox2.Add_Checked({$Global:DisableBackup="true"; $Global:x.ListBox1.Items.Add("Создание резервных копий отключено!")})
$x.CheckBox2.Add_UnChecked({$Global:DisableBackup="false"; $Global:x.ListBox1.Items.Add("Создание резервных копий включено!")})

$x.CheckBox2.Add_Loaded({$Global:DisableBackup="false"; $Global:x.ListBox1.Items.Add("Внимание! По умолчанию создание резервных копий включено!")})

$x.CheckBox1.Add_Checked({$Global:TimerUpdateState="true"; $Global:count++; $Global:x.ListBox1.Items.Add("Обновлять таймеры $TimerUpdateState : Количество приложений $count")})
$x.CheckBox1.Add_UnChecked({$Global:TimerUpdateState="false"; $Global:count--; $Global:x.ListBox1.Items.Add("Не Обновлять таймеры. Количество приложений $count")})
$x.CheckBox1.Add_Loaded({$Global:TimerUpdateState="false"; $Global:x.ListBox1.Items.Add("Внимание! По умолчанию обновление таймеров отключено!")})
$x.CheckBox4.Add_Checked({$Global:DRAINFASTNLB="true"; $Global:x.ListBox1.Items.Add("Внимание! Быстрый вывод серверов NLB включен!")})
$x.CheckBox4.Add_UnChecked({$Global:DRAINFASTNLB="false"; $Global:x.ListBox1.Items.Add("Быстрый вывод серверов NLB отключен!")})
$x.CheckBox4.Add_Loaded({$Global:DRAINFASTNLB="false"; $Global:x.ListBox1.Items.Add("Внимание! По умолчанию быстрый вывод серверов NLB отключен!")})

$x.CheckBox5.Add_Checked({$Global:RERUNSQL="true"; $Global:x.ListBox1.Items.Add("Внимание! Выполнение запросов SQL включено!")})
$x.CheckBox5.Add_UnChecked({$Global:RERUNSQL="false"; $Global:x.ListBox1.Items.Add("Выполнение запросов SQL отключено!")})
$x.CheckBox5.Add_Loaded({$Global:RERUNSQL="false"; $Global:x.ListBox1.Items.Add("Внимание! По умолчанию выполнение запросов SQL отключено")})

$x.CheckBox6.Add_Checked({$Global:SERVICEUPDATE="true"; $Global:count++; $Global:x.ListBox1.Items.Add("Внимание! Обновление сервисов включено ! Количество приложений $count")})
$x.CheckBox6.Add_UnChecked({$Global:SERVICEUPDATE="false"; $Global:count--; $Global:x.ListBox1.Items.Add("Обновление сервисов отключено! Количество приложений $count")})
$x.CheckBox6.Add_Loaded({$Global:SERVICEUPDATE="false"; $Global:x.ListBox1.Items.Add("Внимание! По умолчанию обновление сервисов отключено!")})

$x.CheckBox7.Add_Checked({$Global:APPVERSIONCHECK="false"; $Global:x.ListBox1.Items.Add("Внимание! Проверка версии отключена!")})
$x.CheckBox7.Add_UnChecked({$Global:APPVERSIONCHECK="true"; $Global:x.ListBox1.Items.Add("Проверка версии включена!")})
$x.CheckBox7.Add_Loaded({$Global:APPVERSIONCHECK="true"; $Global:x.ListBox1.Items.Add("Внимание! По умолчанию проверка версии включена!")})



$x.ComboBox3.Add_Loaded({$Global:APPVERSIONCHECK="true"; $Global:x.ListBox1.Items.Add("ComboBox Test Text")})
$x.ComboBox3.Add_Loaded({$x.ComboBox3.SelectedItem=$x.ComboBoxItem1})




$x.RadioButton.Add_Checked({

$global:env="LIVE";
$Global:x.ListBox1.Items.Add("Выбрано окружение $env");
#$Global:ListBoxCurrentCount = $Global:x.ListBox1.Items.Count;
#$Global:x.ListBox1.Items.Add("Количество элементов $ListBoxCurrentCount");
#$Global:x.ListBox1.SelectedIndex = $Global:x.ListBox1.Items.Count - 1;
#$Global:x.ListBox1.SelectedIndex = -1;
#$Global:x.ListBox1.SelectionStart = $Global:x.ListBox1.TextLength;
$Global:x.ListBox1.Items.MoveCurrentToLast();
$Global:x.ListBox1.ScrollIntoView($Global:x.ListBox1.Items.CurrentItem);
})
	
	
	
$x.RadioButton1.Add_Checked({$global:env="STAGE"; $Global:x.ListBox1.Items.Add("Выбрано окружение $env")})
$x.RadioButton2.Add_Checked({$global:env="DEV"; $Global:x.ListBox1.Items.Add("Выбрано окружение $env")})
$x.RadioButton3.Add_Checked({$global:env="TEST"; $Global:x.ListBox1.Items.Add("Выбрано окружение $env")})



$Global:x.w.ShowDialog()
 #return $TimerUpdateState, $SecureUpdateState, $environment, $echoPathVersion, $superjob
})

Register-EngineEvent -SourceIdentifier "OkClicked2" -messageData "$env" -Action  {
param (
$env
)
	$global:env = $env
}
Register-EngineEvent -SourceIdentifier "OkClicked7" -messageData "$DRAINFASTNLB" -Action  {
param (
$DRAINFASTNLB
)
	$global:DRAINFASTNLB = $DRAINFASTNLB
}
Register-EngineEvent -SourceIdentifier "OkClicked8" -messageData "$RERUNSQL" -Action  {
param (
$RERUNSQL
)
	$global:RERUNSQL = $RERUNSQL
}
Register-EngineEvent -SourceIdentifier "OkClicked9" -messageData "$SERVICEUPDATE" -Action  {
param (
$SERVICEUPDATE
)
	$global:SERVICEUPDATE = $SERVICEUPDATE
}
Register-EngineEvent -SourceIdentifier "OkClicked10" -messageData "$APPVERSIONCHECK" -Action  {
param (
$APPVERSIONCHECK
)
	$global:APPVERSIONCHECK = $APPVERSIONCHECK
}
Register-EngineEvent -SourceIdentifier "OkClicked6" -messageData "$DisableBackup" -Action  {
param (
$DisableBackup
)
	$global:DisableBackup = $DisableBackup
}
Register-EngineEvent -SourceIdentifier "OkClicked3" -messageData "$echoPathVersion" -Action  {
param (
$echoPathVersion
)
$global:echoPathVersion = $echoPathVersion
}
Register-EngineEvent -SourceIdentifier "OkClicked4" -messageData "$TimerUpdateState" -Action  {
param (
$TimerUpdateState
)
	$global:TimerUpdateState = $TimerUpdateState
}
Register-EngineEvent -SourceIdentifier "OkClicked5" -messageData "$SecureUpdateState" -Action  {
param (
$SecureUpdateState
)
	$global:SecureUpdateState = $SecureUpdateState
} 
Register-EngineEvent -SourceIdentifier "OkClicked1" -messageData "$superjob" -Action  {
param (
$superjob
)
	$global:superjob = $superjob
}
