# BauchGlück
 "**BauchGlück** ist eine speziell entwickelte App für Menschen nach einer **Magenbypass-Operation**. Sie vereint Ernährung, Medikation und Wohlbefinden in einer intuitiven Plattform und unterstützt Nutzer dabei, ihren Alltag zu organisieren und ihre Gesundheit im Blick zu behalten."

Die App bietet hilfreiche Tools wie Countdown-Timer zur Erinnerung an Ess- und Trinkzeiten, dokumentiert die Wasseraufnahme und den Gewichtsverlauf, verwaltet Medikamente und erinnert an die Einnahme. Zudem ermöglicht sie die einfache Planung von Mahlzeiten. Eine integrierte Community-Funktion fördert den Austausch von Rezepten unter den Nutzern.

## UX/UI
> [Figma Case Study](https://www.figma.com/design/FMorQUMx5iu7ysW2AuTS1x/Project-MagenApp?node-id=40-29&t=7M0qex8nEc9LTMWf-1)

> [Figma UX/UI Design](https://www.figma.com/design/FMorQUMx5iu7ysW2AuTS1x/Project-MagenApp?node-id=40-29&t=7M0qex8nEc9LTMWf-1)

> [Figma Pitch Presentation](./images/presentation_bauch_glueck_compressed.pdf)

## Einrichtung

### GoogleService-Info.plist hinzufügen
Um Firebase in der iOS-App zu integrieren, muss die **GoogleService-Info.plist** Datei in das Projekt hinzugefügt werden. Diese Datei enthält die Konfigurationsdetails für die Firebase-Dienste.

1. Lade die **GoogleService-Info.plist** Datei aus der Firebase-Konsole herunter.
2. Ziehe die Datei in dein Xcode-Projekt und stelle sicher, dass sie für alle Build-Ziele ausgewählt ist.

### Backend-Konfiguration
In der **Info.plist** Datei werden die Backend-URLs und Schlüssel für verschiedene Umgebungen definiert:
- **GoogleService-Info.plist** hinzufügen.
- **Info.plist** spezifische Backend-Konfiguration und weitere Schlüssel zu deiner EnvironmentVariables anpassen.

```xml
<key>BACKEND_BASEURLS</key>
<dict>
    <key><ENUM_CASE_1></key>
    <string>[Domain]</string>
    <key>ENUM_CASE_2</key>
    <string>[Domain]</string>
    <key>ENUM_CASE_3</key>
    <string>[Domain]</string>
</dict>
<key>BACKEND_KEYS</key>
<dict>
    <key>ENUM_CASE_1</key>
    <string>[Dein Schlüssel hier]</string>
    <key>ENUM_CASE_2</key>
    <string>[Dein Schlüssel hier]</string>
    <key>ENUM_CASE_3</key>
    <string>[Dein Schlüssel hier]</string>
</dict> 
<key>UIAppFonts</key>
<array>
    <string>[FONT].ttf</string>
    <string>[FONT].ttf</string>
</array>
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>[Domain]</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSExceptionMinimumTLSVersion</key>
            <string>TLSv1.3</string>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>[FIREBASE REDIRECT URL]</string>
        </array>
    </dict>
</array>
```

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
