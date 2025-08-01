import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ClothingScannerScreen extends StatefulWidget {
  const ClothingScannerScreen({super.key});

  @override
  State<ClothingScannerScreen> createState() => _ClothingScannerScreenState();
}

class _ClothingScannerScreenState extends State<ClothingScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;
  bool _isProcessing = false;
  List<DetectedClothingItem> _detectedItems = [];
  final Random _random = Random();

  // Список тестовых предметов одежды для демонстрации
  static const List<Map<String, dynamic>> _demoClothingItems = [
    {'name': 'Футболка', 'category': 'top', 'icon': '👕', 'confidence': 0.85},
    {'name': 'Джинсы', 'category': 'bottom', 'icon': '👖', 'confidence': 0.92},
    {'name': 'Кроссовки', 'category': 'shoes', 'icon': '👟', 'confidence': 0.78},
    {'name': 'Кепка', 'category': 'hat', 'icon': '🧢', 'confidence': 0.65},
    {'name': 'Свитер', 'category': 'top', 'icon': '🧥', 'confidence': 0.88},
    {'name': 'Шорты', 'category': 'bottom', 'icon': '🩳', 'confidence': 0.71},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    // Запрашиваем разрешения
    final cameraPermission = await Permission.camera.request();
    if (cameraPermission != PermissionStatus.granted) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cameraPermissionRequired)),
        );
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('Камеры не найдены');
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.scanningError}: $e')),
        );
      }
    }
  }

  Future<void> _startScanning() async {
    if (!_isInitialized || _cameraController == null) return;

    setState(() {
      _isScanning = true;
      _detectedItems.clear();
    });

    // Имитируем сканирование с задержкой
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted && _isScanning) {
      // Генерируем случайные предметы одежды для демонстрации
      final newItems = <DetectedClothingItem>[];
      final itemCount = _random.nextInt(3) + 1; // 1-3 предмета
      
      for (int i = 0; i < itemCount; i++) {
        final item = _demoClothingItems[_random.nextInt(_demoClothingItems.length)];
        newItems.add(DetectedClothingItem(
          name: item['name'],
          category: item['category'],
          icon: item['icon'],
          confidence: item['confidence'] + (_random.nextDouble() - 0.5) * 0.1,
          boundingBox: Rect.fromLTWH(
            _random.nextDouble() * 100,
            _random.nextDouble() * 100,
            50 + _random.nextDouble() * 100,
            50 + _random.nextDouble() * 100,
          ),
        ));
      }

      setState(() {
        _detectedItems = newItems;
      });
    }
  }

  Future<void> _stopScanning() async {
    if (_cameraController == null) return;

    setState(() {
      _isScanning = false;
    });
  }

  Future<void> _processDetectedItems() async {
    if (_detectedItems.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Имитируем обработку
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.itemsAddedToWardrobe),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context, _detectedItems);
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.scanningError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanClothing),
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_detectedItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _isProcessing ? null : _processDetectedItems,
              tooltip: l10n.addToWardrobe,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade900,
              Colors.deepPurple.shade700,
            ],
          ),
        ),
        child: Column(
          children: [
            // Камера
            Expanded(
              flex: 3,
              child: _buildCameraView(),
            ),
            
            // Индикаторы сканирования
            if (_isScanning) _buildScanningIndicators(),
            
            // Обнаруженные предметы
            if (_detectedItems.isNotEmpty) _buildDetectedItems(),
            
            // Кнопки управления
            _buildControlButtons(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView() {
    final l10n = AppLocalizations.of(context)!;
    if (!_isInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Видеопоток с камеры
        CameraPreview(_cameraController!),
        
        // Оверлей с инструкциями
        Positioned(
          top: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              l10n.scanInstructions,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        
        // Индикатор сканирования
        if (_isScanning)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.scanningClothing,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildScanningIndicators() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildScanningDot(Colors.green),
          const SizedBox(width: 8),
          _buildScanningDot(Colors.blue),
          const SizedBox(width: 8),
          _buildScanningDot(Colors.orange),
        ],
      ),
    );
  }

  Widget _buildScanningDot(Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildDetectedItems() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.clothingDetected}: ${_detectedItems.length}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _detectedItems.length,
              itemBuilder: (context, index) {
                final item = _detectedItems[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(item.confidence * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isInitialized ? (_isScanning ? _stopScanning : _startScanning) : null,
              icon: Icon(_isScanning ? Icons.stop : Icons.camera_alt),
              label: Text(_isScanning ? l10n.stopScanning : l10n.startScanning),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isScanning ? Colors.red : Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          if (_isProcessing) ...[
            const SizedBox(width: 16),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DetectedClothingItem {
  final String name;
  final String category;
  final String icon;
  final double confidence;
  final Rect boundingBox;

  DetectedClothingItem({
    required this.name,
    required this.category,
    required this.icon,
    required this.confidence,
    required this.boundingBox,
  });
} 