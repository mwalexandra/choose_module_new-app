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
        Write-Host "Starte Android-Emulator '$emulatorName'..."
        Start-Process "flutter" -ArgumentList "emulators", "--launch", "$emulatorName"
        Start-Sleep -Seconds 15
        Write-Host "Starte Flutter-App auf dem Emulator..."
        flutter run -d emulator-5554
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
