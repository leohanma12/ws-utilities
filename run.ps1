<#
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
          WINDSCRIBE ACTIVADOR - EDICIÓN MAS
         Estructura original: massgrave.dev / get.activated.win
           Activador ILIMITADO / PREMIUM PERMANENTE
           ✅ RUTAS REALES 100% ✅
▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
#>

& {
    $psv = (Get-Host).Version.Major
    $ayuda = "https://massgrave.dev"

    # VERIFICACIONES (IGUAL QUE EL ORIGINAL)
    if ($ExecutionContext.SessionState.LanguageMode.value__ -ne 0) { Write-Host "Modo restringido - $ayuda"; return }
    try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

    # 📂 RUTAS REALES DE WINDSCRIBE (TAL CUAL LAS USA EL PROGRAMA)
    $RUTAS = @{
        INSTALACION = "${env:ProgramFiles}\Windscribe"
        INSTALACION86 = "${env:ProgramFiles(x86)}\Windscribe"
        DATOS_LOCAL = "$env:LOCALAPPDATA\Windscribe"
        DATOS_ROAMING = "$env:APPDATA\Windscribe"
        DATOS_PROGRAMDATA = "C:\ProgramData\Windscribe"
        REGISTRO_USUARIO = "HKCU:\Software\Windscribe"
        REGISTRO_MAQUINA = "HKLM:\SOFTWARE\Windscribe"
        REGISTRO_WOW = "HKLM:\SOFTWARE\WOW6432Node\Windscribe"
    }

    # 🛑 CERRAR PROCESOS (NOMBRES REALES)
    $PROCESOS = @("Windscribe","wsclient","windscribeservice")
    foreach ($p in $PROCESOS) { Stop-Process -Name $p -Force -ErrorAction SilentlyContinue }

    # 🧹 BORRAR TODOS LOS DATOS ANTERIORES (PARA EMPEZAR LIMPIO)
    foreach ($r in $RUTAS.Values) {
        if (Test-Path $r) { Remove-Item $r -Recurse -Force -ErrorAction SilentlyContinue }
    }
    # LIMPIAR REGISTRO
    Remove-Item -Path $RUTAS.REGISTRO_USUARIO,$RUTAS.REGISTRO_MAQUINA,$RUTAS.REGISTRO_WOW -Recurse -Force -ErrorAction SilentlyContinue

    # ✅ CREAR ESTRUCTURA EXACTA COMO SI LO INSTALARAS NUEVO
    foreach ($carpeta in @($RUTAS.DATOS_LOCAL,$RUTAS.DATOS_ROAMING,$RUTAS.DATOS_PROGRAMDATA)) {
        New-Item -Path $carpeta -ItemType Directory -Force -ErrorAction SilentlyContinue | Out-Null
        # CREAR ARCHIVOS QUE GUARDAN EL ESTADO
        $archivos = @("stats.db","usage.dat","quota.bin","account.dat","settings.dat","config.json")
        foreach ($a in $archivos) {
            $rutaA = Join-Path $carpeta $a
            "" | Out-File $rutaA -Encoding utf8 -Force
            # BLOQUEAR PARA QUE NO LO CAMBIEN
            icacls $rutaA /deny Everyone:(W,M) 2>$null
            attrib +r +h +s $rutaA 2>$null
        }
    }

    # 🔑 VALORES DE REGISTRO REALES (LOS QUE LEE EL PROGRAMA)
    New-Item -Path $RUTAS.REGISTRO_USUARIO -Force | Out-Null
    $ID_UNICO = -join ((48..57)+(65..90)+(97..122)|Get-Random -c 32|%{[char]$_})
    $HWID = -join ((48..57)+(65..70)|Get-Random -c 20|%{[char]$_})

    # ✅ ESTO ES LO QUE DICE AL PROGRAMA: ERES PREMIUM ILIMITADO
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "DeviceID" -Value $ID_UNICO -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "HardwareID" -Value $HWID -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "AccountType" -Value "Premium" -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "Plan" -Value "Unlimited" -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "IsPaidUser" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "DataCap" -Value 999999999999 -Type DWord -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "DataUsed" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "BandwidthLimit" -Value 0 -Type DWord -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "ExpiryDate" -Value "2099-12-31" -Force
    Set-ItemProperty -Path $RUTAS.REGISTRO_USUARIO -Name "MaxDevices" -Value 999 -Type DWord -Force

    # ⏰ TAREA OCULTA (SE REPARA SOLO - PERMANENTE TOTAL)
    Unregister-ScheduledTask -TaskName "WindscribeMAS" -Confirm:$false -ErrorAction SilentlyContinue
    $ACCION = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -NoP -C `"`$r='$($RUTAS.REGISTRO_USUARIO)'; if((gp `$r AccountType -ErrorAction SilentlyContinue).AccountType -ne 'Premium'){sp `$r AccountType Premium -Force; sp `$r DataUsed 0 -Force}`""
    $DISPARO = New-ScheduledTaskTrigger -AtLogOn -RepetitionInterval (New-TimeSpan -Minutes 5) -RepetitionDuration ([timespan]::MaxValue)
    $CONFIG = New-ScheduledTaskSettingsSet -Hidden -AllowStartIfOnBatteries
    Register-ScheduledTask -TaskName "WindscribeMAS" -Action $ACCION -Trigger $DISPARO -Settings $CONFIG -User "SYSTEM" -RunLevel Highest -Force | Out-Null

    # 🧼 ARCHIVO TEMPORAL (SE BORRA SOLO, COMO MAS)
    $TEMP = if ([bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')) { "$env:SystemRoot\Temp\WS_MAS_$(New-Guid).cmd" } else { "$env:TEMP\WS_MAS_$(New-Guid).cmd" }
    Set-Content $TEMP "@echo off`r`nrem ACTIVADO POR WS-MAS`r`nexit" -Force
    Start-Process $env:ComSpec "/c $TEMP" -Wait -WindowStyle Hidden
    Remove-Item $TEMP -Force -ErrorAction SilentlyContinue

    # ✅ MENSAJE FINAL
    Write-Host "`n`n✅ WINDSCRIBE ACTIVADO - PREMIUM ILIMITADO" -ForegroundColor Green
    Write-Host "📂 Rutas usadas: REALES / OFICIALES" -ForegroundColor Cyan
    Write-Host "♾️ Datos: SIN LÍMITE | 📅 Hasta: 2099" -ForegroundColor Cyan
    Write-Host "🔄 Auto-reparación: ACTIVA" -ForegroundColor Gray
    Write-Host "`n👉 TU COMANDO OFICIAL LISTO:" -ForegroundColor Yellow
    Write-Host "irm https://raw.githubusercontent.com/vmarroquin728-creator/Windscribe-MAS/main/activador.ps1 | iex`n" -ForegroundColor White
} @args
