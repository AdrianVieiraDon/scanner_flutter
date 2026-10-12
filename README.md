# Escáner QR / Código de barras con Flutter

App de ejemplo para el video tutorial de **Programación Móvil (SS603)**.
Escanea códigos QR y de barras con la cámara del dispositivo y muestra cómo
se configuran los permisos de cámara en **Android, iOS y Web**, incluido el
caso en que el usuario **niega** el permiso.

**Autor:** Julio Adrian Vieira Donado
**Video:** _(pega aquí el enlace de YouTube no listado)_

## Paquete usado

[`mobile_scanner`](https://pub.dev/packages/mobile_scanner) ^7.4.2

| Plataforma | Motor de lectura |
|---|---|
| Android | CameraX + Google ML Kit |
| iOS | AVFoundation + Apple Vision |
| Web | BarcodeDetector del navegador o ZXing (WASM) |

## Permisos

### Android — `android/app/src/main/AndroidManifest.xml`
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="false" />
```
El permiso `CAMERA` es "peligroso": además del manifiesto se pide en tiempo de
ejecución. `mobile_scanner` lo solicita al iniciar la cámara.

### iOS — `ios/Runner/Info.plist`
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos la cámara para escanear códigos QR y de barras.</string>
```
Sin esta clave la app se cierra al intentar abrir la cámara.

### Web
Usa `getUserMedia` del navegador. Solo funciona en **HTTPS** o `localhost`.
El navegador muestra su propio diálogo de permiso.

### Permiso negado
Si el usuario niega el permiso, `MobileScanner` llama a `errorBuilder` con
`MobileScannerErrorCode.permissionDenied` y la app muestra un mensaje con
instrucciones y un botón **Reintentar**.

## Cómo ejecutar
```bash
flutter pub get
flutter run            # dispositivo Android/iOS conectado
flutter run -d chrome  # versión web (localhost)
```

## Estructura
```
lib/main.dart
 ├─ QrApp        → MaterialApp
 ├─ HomePage     → botón "Escanear" y último resultado
 ├─ ScannerPage  → cámara + detección (onDetect)
 └─ _VistaError  → manejo de permiso negado
```
