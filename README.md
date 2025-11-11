# Modul-Choose-App

**Gruppenname:** makeewa  
**Build-Ziel:** Web  
**Base-Href:** /makeewa/

## Beschreibung
Dieses Projekt ist eine Flutter-Webanwendung, die eine Modulauswahl für Studierende ermöglicht.  
Benutzer können sich über einen personalisierten Link anmelden, der ihre Daten über URL-Parameter enthält.

## Testanleitung (lokal)
1. Öffne im Terminal:
   ```bash
   cd build/web
   python -m http.server 8000

2. Öffne im Browser:
    http://localhost:8000/index.html?login=stu1&password=1234&name=Alexandra&email=alex@example.com

    oder auf dem Server unter /makeewa/:
        https://<serveradresse>/makeewa/index.html?login=stu1&password=1234&name=Alexandra&email=alex@example.com
        
    
