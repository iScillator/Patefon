import 'dart:convert';

class SkinService {
  static final SkinService _instance = SkinService._internal();
  factory SkinService() => _instance;
  SkinService._internal();

  // Данные о нервных окончаниях и волосках
  final Map<String, dynamic> _anatomyData = {
    'hairFollicles': {
      'total': 5000000, // 5 миллионов волосков на теле
      'density': {
        'head': 150000,
        'face': 25000,
        'arms': 800000,
        'legs': 1200000,
        'torso': 2000000,
        'other': 725000,
      },
      'structure': {
        'bulb': 'Луковица волоска',
        'root': 'Корень волоска',
        'shaft': 'Стержень волоска',
        'nerveEnding': 'Нервное окончание',
      }
    },
    'nerveEndings': {
      'total': 100000000, // 100 миллионов нервных окончаний
      'types': {
        'touch': 'Тактильные рецепторы',
        'pressure': 'Рецепторы давления',
        'temperature': 'Терморецепторы',
        'pain': 'Болевые рецепторы',
      },
      'connection': 'Соединены с корнями волосков'
    },
    'brainProcessing': {
      'hologram': '3D модель окружения',
      'adaptation': 'Адаптация анатомии',
      'response': 'Реакция на одежду'
    }
  };

  // Получить данные анатомии
  Map<String, dynamic> getAnatomyData() {
    return _anatomyData;
  }

  // Получить информацию о волосках
  Map<String, dynamic> getHairFolliclesInfo() {
    return _anatomyData['hairFollicles'];
  }

  // Получить информацию о нервных окончаниях
  Map<String, dynamic> getNerveEndingsInfo() {
    return _anatomyData['nerveEndings'];
  }

  // Получить информацию о обработке мозгом
  Map<String, dynamic> getBrainProcessingInfo() {
    return _anatomyData['brainProcessing'];
  }

  // Рассчитать плотность волосков на определенной части тела
  double calculateHairDensity(String bodyPart) {
    final density = _anatomyData['hairFollicles']['density'];
    if (density.containsKey(bodyPart)) {
      return density[bodyPart].toDouble();
    }
    return 0.0;
  }

  // Получить рекомендации по одежде на основе анатомии
  List<String> getClothingRecommendations(String bodyPart, String mode) {
    final recommendations = <String>[];
    
    switch (bodyPart) {
      case 'torso':
        if (mode == 'comfort') {
          recommendations.addAll([
            'Свободная хлопковая футболка',
            'Дышащая рубашка',
            'Мягкий свитер',
          ]);
        } else {
          recommendations.addAll([
            'Утягивающая майка',
            'Корсет для осанки',
            'Компрессионная футболка',
          ]);
        }
        break;
      case 'legs':
        if (mode == 'comfort') {
          recommendations.addAll([
            'Свободные джинсы',
            'Спортивные шорты',
            'Мягкие брюки',
          ]);
        } else {
          recommendations.addAll([
            'Компрессионные леггинсы',
            'Утягивающие брюки',
            'Спортивные штаны',
          ]);
        }
        break;
      case 'arms':
        if (mode == 'comfort') {
          recommendations.addAll([
            'Свободная рубашка',
            'Футболка с коротким рукавом',
          ]);
        } else {
          recommendations.addAll([
            'Компрессионные рукава',
            'Утягивающая майка',
          ]);
        }
        break;
    }
    
    return recommendations;
  }

  // Рассчитать влияние одежды на нервные окончания
  Map<String, double> calculateClothingImpact(String clothingType, String bodyPart) {
    final impact = <String, double>{};
    
    switch (clothingType) {
      case 'compression':
        impact['nerveStimulation'] = 0.8;
        impact['muscleActivation'] = 0.7;
        impact['comfort'] = 0.4;
        break;
      case 'loose':
        impact['nerveStimulation'] = 0.2;
        impact['muscleActivation'] = 0.1;
        impact['comfort'] = 0.9;
        break;
      case 'tight':
        impact['nerveStimulation'] = 0.6;
        impact['muscleActivation'] = 0.5;
        impact['comfort'] = 0.6;
        break;
      default:
        impact['nerveStimulation'] = 0.3;
        impact['muscleActivation'] = 0.3;
        impact['comfort'] = 0.7;
    }
    
    return impact;
  }

  // Получить статистику эксперимента
  Map<String, dynamic> getExperimentStats() {
    return {
      'totalParticipants': 1,
      'averageProgress': 0.65,
      'successRate': 0.85,
      'duration': 30,
      'measurements': [
        'Мышечная масса',
        'Жировая масса',
        'Сила хвата',
        'Гибкость',
        'Осанка'
      ]
    };
  }

  // Сохранить данные эксперимента
  Future<void> saveExperimentData(Map<String, dynamic> data) async {
    // В реальном приложении здесь была бы запись в базу данных
    print('Сохранение данных эксперимента: ${jsonEncode(data)}');
  }

  // Загрузить данные эксперимента
  Future<Map<String, dynamic>> loadExperimentData() async {
    // В реальном приложении здесь была бы загрузка из базы данных
    return {
      'startDate': DateTime.now().subtract(const Duration(days: 7)),
      'currentDay': 7,
      'progress': 0.23,
      'measurements': {
        'muscleMass': 65.5,
        'bodyFat': 14.8,
        'gripStrength': 47.2,
      },
      'notes': 'Начал эксперимент с компрессионной одеждой'
    };
  }
} 