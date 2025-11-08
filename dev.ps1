# dev.ps1
# Skript zur Verwaltung von Flutter-Projekten auf Windows
# Verwendung:
#   .\dev.ps1 chrome       → Startet Flutter-Web in Chrome
#   .\dev.ps1 android      → Startet Emulator Pixel_4 und Flutter-App
#   .\dev.ps1 pubget       → Installiert alle Pakete
#   .\dev.ps1 clean        → Bereinigt das Projekt
#   .\dev.ps1 build-apk    → Baut APK für Release
#   .\dev.ps1 build-web    → Baut Web-Version für Produktion

param(
    [string]$command
)

# Name des Android-Emulators
$emulatorName = "Pixel_4"

switch ($command) {
    "pubget" {
        Write-Host "Installiere alle Pakete..."
        flutter pub get
    }

    "clean" {
        Write-Host "Bereinige das Projekt..."
        flutter clean
    }

    "chrome" {
        Write-Host "Starte Flutter-Web in Chrome..."
        flutter run -d chrome
    }

    "android" {
        # Путь к эмулятору
        $emulatorPath = "C:\Users\manik\AppData\Local\Android\Sdk\emulator\emulator.exe"

        # Список доступных Flutter-устройств
        $devices = flutter devices --machine | ConvertFrom-Json

        # Проверяем, есть ли уже запущенный Pixel_4
        $pixel4Running = $false
        foreach ($d in $devices) {
            if ($d.name -eq $emulatorName) {
                $pixel4Running = $true
                break
            }
        }

        if (-not $pixel4Running) {
            Write-Host "Starte Emulator $emulatorName..."
            Start-Process $emulatorPath "-avd $emulatorName -scale 0.75"
            Write-Host "Warte 30 Sekunden, bis der Emulator vollstaendig gestartet ist..."
            Start-Sleep -Seconds 30
        } else {
            Write-Host "Emulator $emulatorName läuft bereits."
        }

        # Ждем, пока Flutter распознает эмулятор
        do {
            Start-Sleep -Seconds 5
            $devices = flutter devices --machine | ConvertFrom-Json
            $pixel4Running = $false
            foreach ($d in $devices) {
                if ($d.name -eq $emulatorName) {
                    $pixel4Running = $true
                    $deviceId = $d.id
                    break
                }
            }
        } until ($pixel4Running)

        Write-Host "Starte Flutter-Anwendung auf Emulator $emulatorName..."
        flutter run -d $deviceId
    }

    "build-apk" {
        Write-Host "Bau APK für Release..."
        flutter build apk --release
    }

    "build-web" {
        Write-Host "Bau Web-Version für Produktion..."
        flutter build web
    }

    default {
        Write-Host "Verfügbare Befehle: pubget, clean, chrome, android, build-apk, build-web"
    }
}
