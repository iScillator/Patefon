import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;

class ClothingRecognitionService {
  final ObjectDetector _objectDetector = GoogleMlKit.vision.objectDetector();
  final ImageLabeler _imageLabeler = GoogleMlKit.vision.imageLabeler();
  
  // Список категорий одежды для распознавания
  static const List<String> _clothingCategories = [
    'shirt', 't-shirt', 'blouse', 'sweater', 'jacket', 'coat',
    'pants', 'jeans', 'shorts', 'skirt', 'dress',
    'shoes', 'boots', 'sneakers', 'sandals',
    'hat', 'cap', 'scarf', 'gloves',
    'socks', 'underwear', 'bra', 'tank top'
  ];

  // Маппинг категорий на иконки
  static const Map<String, String> _categoryIcons = {
    'shirt': '👔',
    't-shirt': '👕',
    'blouse': '👚',
    'sweater': '🧥',
    'jacket': '🧥',
    'coat': '🧥',
    'pants': '👖',
    'jeans': '👖',
    'shorts': '🩳',
    'skirt': '👗',
    'dress': '👗',
    'shoes': '👟',
    'boots': '👢',
    'sneakers': '👟',
    'sandals': '🩴',
    'hat': '🎩',
    'cap': '🧢',
    'scarf': '🧣',
    'gloves': '🧤',
    'socks': '🧦',
    'underwear': '🩲',
    'bra': '👙',
    'tank top': '🎽',
  };

  // Маппинг категорий на русские названия
  static const Map<String, String> _categoryNames = {
    'shirt': 'Рубашка',
    't-shirt': 'Футболка',
    'blouse': 'Блузка',
    'sweater': 'Свитер',
    'jacket': 'Куртка',
    'coat': 'Пальто',
    'pants': 'Брюки',
    'jeans': 'Джинсы',
    'shorts': 'Шорты',
    'skirt': 'Юбка',
    'dress': 'Платье',
    'shoes': 'Обувь',
    'boots': 'Сапоги',
    'sneakers': 'Кроссовки',
    'sandals': 'Сандалии',
    'hat': 'Шляпа',
    'cap': 'Кепка',
    'scarf': 'Шарф',
    'gloves': 'Перчатки',
    'socks': 'Носки',
    'underwear': 'Нижнее белье',
    'bra': 'Бюстгальтер',
    'tank top': 'Майка',
  };

  Future<List<DetectedClothingItem>> detectClothing(CameraImage image) async {
    try {
      // Конвертируем CameraImage в InputImage
      final inputImage = InputImage.fromBytes(
        bytes: _convertCameraImageToBytes(image),
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      // Получаем результаты распознавания объектов
      final objects = await _objectDetector.processImage(inputImage);
      
      // Получаем результаты классификации изображения
      final labels = await _imageLabeler.processImage(inputImage);

      final List<DetectedClothingItem> detectedItems = [];

      // Обрабатываем обнаруженные объекты
      for (final object in objects) {
        final category = object.labels.firstOrNull?.text.toLowerCase();
        if (category != null && _clothingCategories.contains(category)) {
          detectedItems.add(DetectedClothingItem(
            name: _categoryNames[category] ?? category,
            category: category,
            icon: _categoryIcons[category] ?? '👕',
            confidence: object.labels.first.confidence,
            boundingBox: object.boundingBox,
          ));
        }
      }

      // Обрабатываем результаты классификации
      for (final label in labels) {
        final category = label.label.toLowerCase();
        if (_clothingCategories.contains(category)) {
          // Проверяем, не добавлен ли уже этот предмет
          final existingItem = detectedItems.where((item) => item.category == category).firstOrNull;
          if (existingItem == null) {
            detectedItems.add(DetectedClothingItem(
              name: _categoryNames[category] ?? category,
              category: category,
              icon: _categoryIcons[category] ?? '👕',
              confidence: label.confidence,
              boundingBox: Rect.zero, // Для классификации нет bounding box
            ));
          }
        }
      }

      // Фильтруем предметы с низкой уверенностью
      return detectedItems.where((item) => item.confidence > 0.3).toList();
    } catch (e) {
      // В случае ошибки возвращаем пустой список
      return [];
    }
  }

  Uint8List _convertCameraImageToBytes(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  void dispose() {
    _objectDetector.close();
    _imageLabeler.close();
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