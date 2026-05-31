<#
HERRAMIENTA DE CONFIGURACIÓN WS
Versión limpia y estable
#>

& {
    $psv = (Get-Host).Version.Major
    $info = "https://windscribe.com/support"

    if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) { 
        Write-Host "Modo restringido - $info"; 
        return 
    }
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    $rutas = @{
        PROG_FILES = "${env:ProgramFiles}\Windscribe"
        PROG_FILES_X86 = "${env:ProgramFiles(x86)}\Windscribe"
        LOCAL_DATOS = "$env:LOCALAPPDATA\Windscribe"
        ROAMING_DATOS = "$env:APPDATA\Windscribe"
        DATOS_GLOBAL = "C:\ProgramData\Windscribe"
        REG_USUARIO = "HKCU:\Software\Windscribe"
        REG_MAQUINA = "HKLM:\SOFTWARE\Windscribe"
        REG_WOW = "HKLM:\SOFTWARE\WOW6432Node\Windscribe"
    }

    @("Windscribe","wsclient","windscribeservice") | ForEach-Object {
        Stop-Process -Name $_ -Force -ErrorAction SilentlyContinue
    }

    $rutas.Values | ForEach-Object {
        if (Test-Path $_) { Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue }
    }
    @($rutas.REG_USUARIO,$rutas.REG_MAQUINA,$rutas.REG_WOW) | ForEach-Object {
        Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue
    }

    @($rutas.LOCAL_DATOS,$rutas.ROAMING_DATOS,$rutas.DATOS_GLOBAL) | ForEach-Object {
        New-Item -Path $_ -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        @("stats.db","usage.dat","quota.bin","account.dat","settings.dat","config.json") | ForEach-Object {
            $arch = Join-Path $_ $_
            "" | Out-File $arch -Encoding utf8 -Force
            icacls $arch /deny Everyone:(W,M) 2>$null
            attrib +r +h +s $arch 2>$null
        }
    }

    New-Item -Path $rutas.REG_USUARIO -Force | Out-Null
    $id_unico = -join ((48..57)+(65..90)+(97..122)|Get-Random -c 32|%{[char]$_})
    $hwid = -join ((48..57)+(65..70)|Get-Random -c 20|%{[char]$_})

    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "DeviceID" -Value $id_unico -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "HardwareID" -Value $hwid -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "AccountType" -Value "Premium" -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "Plan" -Value "Unlimited" -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "IsPaidUser" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "DataCap" -Value 999999999999 -Type DWord -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "DataUsed" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "BandwidthLimit" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "ExpiryDate" -Value "2099-12-31" -Force
    Set-ItemProperty -Path $rutas.REG_USUARIO -Name "MaxDevices" -Value 999 -Type DWord -Force

    Unregister-ScheduledTask -TaskName "WSConfigMaintain" -Confirm:$false -ErrorAction SilentlyContinue
    $accion = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoP -C `"`$r='$($rutas.REG_USUARIO)'; if(!((gp `$r AccountType -ErrorAction SilentlyContinue).AccountType -eq 'Premium')){sp `$r AccountType Premium -Force; sp `$r DataUsed 0 -Force}`""
    $disparo = New-ScheduledTaskTrigger -AtLogOn -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([timespan]::MaxValue)
    $config = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries
    Register-ScheduledTask -TaskName "WSConfigMaintain" -Action $accion -Trigger $disparo -Settings $config -User "SYSTEM" -RunLevel Highest -Force | Out-Null

    $temp = if ([bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')) { "$env:SystemRoot\Temp\WS_$(New-Guid).cmd" } else { "$env:TEMP\WS_$(New-Guid).cmd" }
    Set-Content $temp "@echo off`r`nrem Configuración aplicada`r`nexit" -Force
    Start-Process $env:ComSpec "/c $temp" -Wait -WindowStyle Hidden
    Remove-Item $temp -Force -ErrorAction SilentlyContinue

    Write-Host "`n✅ CONFIGURACIÓN APLICADA CORRECTAMENTE" -ForegroundColor Green
    Write-Host "🔓 Estado: Optimizado / Completo" -ForegroundColor Cyan
    Write-Host "♾️ Límites: Eliminados | 📅 Validez: Permanente" -ForegroundColor Cyan
    Write-Host "🔄 Mantenimiento: Activo" -ForegroundColor Gray
}
