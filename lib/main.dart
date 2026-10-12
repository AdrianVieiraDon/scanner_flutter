// =============================================================
//  Escáner QR / Código de barras con Flutter
//  Paquete: mobile_scanner (Android: CameraX + ML Kit,
//           iOS: AVFoundation/Vision, Web: BarcodeDetector/ZXing)
//  Autor: Julio Adrian Vieira Donado · Programación Móvil SS603
// =============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() => runApp(const QrApp());

/// Widget raíz de la aplicación.
class QrApp extends StatelessWidget {
  const QrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Escáner QR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

// -------------------------------------------------------------
//  Pantalla principal: botón para escanear y último resultado
// -------------------------------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _ultimoResultado; // Texto leído en el último escaneo

  /// Abre la pantalla del escáner y espera el texto leído.
  Future<void> _abrirEscaner() async {
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const ScannerPage()),
    );
    // Si el usuario volvió sin escanear, resultado es null.
    if (resultado != null) setState(() => _ultimoResultado = resultado);
  }

  /// Copia el resultado al portapapeles.
  void _copiar() {
    Clipboard.setData(ClipboardData(text: _ultimoResultado!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copiado al portapapeles')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final esUrl = _ultimoResultado?.startsWith('http') ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Escáner QR')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner, size: 110),
              const SizedBox(height: 24),
              if (_ultimoResultado == null)
                const Text('Aún no has escaneado nada.',
                    style: TextStyle(fontSize: 16))
              else
                Card(
                  child: ListTile(
                    leading: Icon(esUrl ? Icons.link : Icons.text_snippet),
                    title: Text(esUrl ? 'Enlace detectado' : 'Texto detectado'),
                    subtitle: SelectableText(_ultimoResultado!),
                    trailing: IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copiar,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _abrirEscaner,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Escanear código'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
//  Pantalla del escáner
//  mobile_scanner solicita el permiso de cámara al iniciar.
//  Si el usuario lo niega, se ejecuta errorBuilder.
// -------------------------------------------------------------
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  // El controlador maneja la cámara (iniciar, detener, formatos...).
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates, // no repetir el mismo código
  );

  bool _yaDetectado = false; // Evita cerrar la pantalla dos veces

  /// Se llama cada vez que la cámara detecta uno o más códigos.
  void _onDetect(BarcodeCapture captura) {
    if (_yaDetectado) return;
    final valor = captura.barcodes.firstOrNull?.rawValue;
    if (valor == null) return;

    _yaDetectado = true;
    Navigator.pop(context, valor); // Devuelve el texto a la pantalla principal
  }

  @override
  void dispose() {
    _controller.dispose(); // Libera la cámara al salir
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apunta al código')),
      body: MobileScanner(
        controller: _controller,
        onDetect: _onDetect,
        // Se muestra si hay un error, por ejemplo, permiso negado.
        errorBuilder: (context, error) => _VistaError(
          error: error,
          onReintentar: () => _controller.start(),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
//  Vista que se muestra cuando la cámara no se puede usar.
//  Aquí manejamos el caso de PERMISO NEGADO (requisito de la guía).
// -------------------------------------------------------------
class _VistaError extends StatelessWidget {
  const _VistaError({required this.error, required this.onReintentar});

  final MobileScannerException error;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    final permisoNegado =
        error.errorCode == MobileScannerErrorCode.permissionDenied;

    return Container(
      color: Colors.black,
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            permisoNegado ? Icons.no_photography : Icons.error_outline,
            color: Colors.white,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            permisoNegado
                ? 'Permiso de cámara denegado'
                : 'No se pudo iniciar la cámara',
            style: const TextStyle(color: Colors.white, fontSize: 20),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            permisoNegado
                ? 'Para escanear códigos necesitamos la cámara. '
                    'Si lo negaste de forma permanente, actívalo en '
                    'Ajustes > Aplicaciones > Escáner QR > Permisos.'
                : (error.errorDetails?.message ?? error.errorCode.name),
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onReintentar,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
