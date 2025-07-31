import 'dart:math';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  // Биометрические данные пользователя
  Map<String, dynamic> _userData = {
    'height': 180.0,
    'weight': 75.0,
    'age': 25,
    'gender': 'male',
    'activityLevel': 'moderate',
    'measurements': {
      'chest': 95.0,
      'waist': 80.0,
      'hips': 95.0,
      'arms': 30.0,
      'thighs': 55.0,
      'calves': 35.0,
    },
    'bodyComposition': {
      'muscleMass': 65.0,
      'bodyFat': 15.0,
      'boneMass': 3.5,
      'water': 55.0,
    },
    'fitnessMetrics': {
      'gripStrength': 45.0,
      'flexibility': 70.0,
      'endurance': 65.0,
      'balance': 75.0,
    }
  };

  // Получить данные пользователя
  Map<String, dynamic> getUserData() {
    return _userData;
  }

  // Обновить данные пользователя
  void updateUserData(Map<String, dynamic> newData) {
    _userData.addAll(newData);
  }

  // Рассчитать индекс массы тела (BMI)
  double calculateBMI() {
    final height = _userData['height'] / 100; // переводим в метры
    final weight = _userData['weight'];
    return weight / (height * height);
  }

  // Получить категорию BMI
  String getBMICategory() {
    final bmi = calculateBMI();
    if (bmi < 18.5) return 'Недостаточный вес';
    if (bmi < 25) return 'Нормальный вес';
    if (bmi < 30) return 'Избыточный вес';
    return 'Ожирение';
  }

  // Рассчитать идеальный вес
  double calculateIdealWeight() {
    final height = _userData['height'];
    final gender = _userData['gender'];
    
    if (gender == 'male') {
      return (height - 100) * 0.9;
    } else {
      return (height - 100) * 0.85;
    }
  }

  // Рассчитать процент жира в организме
  double calculateBodyFatPercentage() {
    final bmi = calculateBMI();
    final age = _userData['age'];
    final gender = _userData['gender'];
    
    if (gender == 'male') {
      return (1.2 * bmi) + (0.23 * age) - 16.2;
    } else {
      return (1.2 * bmi) + (0.23 * age) - 5.4;
    }
  }

  // Получить рекомендации по одежде на основе биометрии
  Map<String, dynamic> getClothingRecommendations() {
    final bmi = calculateBMI();
    final bodyFat = calculateBodyFatPercentage();
    final measurements = _userData['measurements'];
    
    final recommendations = <String, List<String>>{};
    
    // Рекомендации для торса
    if (measurements['chest'] > 100) {
      recommendations['torso'] = [
        'Свободная футболка',
        'Рубашка свободного кроя',
        'Свитер оверсайз'
      ];
    } else {
      recommendations['torso'] = [
        'Футболка классического кроя',
        'Рубашка приталенная',
        'Свитер обычного размера'
      ];
    }
    
    // Рекомендации для ног
    if (measurements['thighs'] > 60) {
      recommendations['legs'] = [
        'Джинсы свободного кроя',
        'Брюки прямого кроя',
        'Спортивные штаны'
      ];
    } else {
      recommendations['legs'] = [
        'Джинсы классического кроя',
        'Брюки приталенные',
        'Спортивные леггинсы'
      ];
    }
    
    // Корректирующие рекомендации
    if (bodyFat > 20) {
      recommendations['correction'] = [
        'Утягивающая майка',
        'Компрессионные леггинсы',
        'Корсет для осанки'
      ];
    }
    
    return recommendations;
  }

  // Рассчитать влияние одежды на биометрию
  Map<String, double> calculateClothingImpact(String clothingType) {
    final impact = <String, double>{};
    final random = Random();
    
    switch (clothingType) {
      case 'compression':
        impact['muscleStimulation'] = 0.7 + random.nextDouble() * 0.2;
        impact['postureImprovement'] = 0.8 + random.nextDouble() * 0.15;
        impact['bloodCirculation'] = 0.6 + random.nextDouble() * 0.3;
        impact['comfort'] = 0.4 + random.nextDouble() * 0.3;
        break;
      case 'loose':
        impact['muscleStimulation'] = 0.1 + random.nextDouble() * 0.2;
        impact['postureImprovement'] = 0.2 + random.nextDouble() * 0.2;
        impact['bloodCirculation'] = 0.8 + random.nextDouble() * 0.15;
        impact['comfort'] = 0.9 + random.nextDouble() * 0.1;
        break;
      case 'tight':
        impact['muscleStimulation'] = 0.5 + random.nextDouble() * 0.3;
        impact['postureImprovement'] = 0.6 + random.nextDouble() * 0.25;
        impact['bloodCirculation'] = 0.5 + random.nextDouble() * 0.3;
        impact['comfort'] = 0.6 + random.nextDouble() * 0.3;
        break;
      default:
        impact['muscleStimulation'] = 0.3 + random.nextDouble() * 0.4;
        impact['postureImprovement'] = 0.4 + random.nextDouble() * 0.4;
        impact['bloodCirculation'] = 0.6 + random.nextDouble() * 0.3;
        impact['comfort'] = 0.7 + random.nextDouble() * 0.2;
    }
    
    return impact;
  }

  // Симулировать изменения биометрии после ношения одежды
  Map<String, double> simulateBiometricChanges(String clothingType, int days) {
    final changes = <String, double>{};
    final impact = calculateClothingImpact(clothingType);
    final factor = days / 30.0; // Нормализуем по 30 дням
    
    // Изменения в мышечной массе
    final muscleStimulation = impact['muscleStimulation'] ?? 0.0;
    if (muscleStimulation > 0.5) {
      changes['muscleMass'] = muscleStimulation * factor * 2.0; // до 2 кг
    }
    
    // Изменения в жировой массе
    final bloodCirculation = impact['bloodCirculation'] ?? 0.0;
    if (bloodCirculation > 0.6) {
      changes['bodyFat'] = -bloodCirculation * factor * 1.5; // до -1.5%
    }
    
    // Изменения в силе хвата
    if (muscleStimulation > 0.4) {
      changes['gripStrength'] = muscleStimulation * factor * 10.0; // до 10 кг
    }
    
    // Изменения в гибкости
    final comfort = impact['comfort'] ?? 0.0;
    if (comfort > 0.7) {
      changes['flexibility'] = comfort * factor * 15.0; // до 15%
    }
    
    return changes;
  }

  // Получить прогноз результатов эксперимента
  Map<String, dynamic> getExperimentForecast(int days) {
    final forecast = <String, dynamic>{};
    final currentData = Map<String, dynamic>.from(_userData);
    
    // Симулируем изменения для компрессионной одежды
    final changes = simulateBiometricChanges('compression', days);
    
    forecast['projectedData'] = {
      'muscleMass': currentData['bodyComposition']['muscleMass'] + (changes['muscleMass'] ?? 0),
      'bodyFat': currentData['bodyComposition']['bodyFat'] + (changes['bodyFat'] ?? 0),
      'gripStrength': currentData['fitnessMetrics']['gripStrength'] + (changes['gripStrength'] ?? 0),
      'flexibility': currentData['fitnessMetrics']['flexibility'] + (changes['flexibility'] ?? 0),
    };
    
    forecast['confidence'] = 0.75 + (days / 30.0) * 0.2; // Уверенность растет со временем
    forecast['recommendations'] = _getForecastRecommendations(changes);
    
    return forecast;
  }

  List<String> _getForecastRecommendations(Map<String, double> changes) {
    final recommendations = <String>[];
    
    if ((changes['muscleMass'] ?? 0) > 1.0) {
      recommendations.add('Ожидается значительный рост мышечной массы');
    }
    
    if ((changes['bodyFat'] ?? 0) < -0.5) {
      recommendations.add('Ожидается снижение жировой массы');
    }
    
    if ((changes['gripStrength'] ?? 0) > 5.0) {
      recommendations.add('Ожидается улучшение силы хвата');
    }
    
    if (recommendations.isEmpty) {
      recommendations.add('Ожидаются умеренные изменения в течение месяца');
    }
    
    return recommendations;
  }

  // Сохранить биометрические данные
  Future<void> saveBiometricData(Map<String, dynamic> data) async {
    _userData = data;
    // В реальном приложении здесь была бы запись в базу данных
    print('Сохранение биометрических данных: $data');
  }

  // Загрузить биометрические данные
  Future<Map<String, dynamic>> loadBiometricData() async {
    // В реальном приложении здесь была бы загрузка из базы данных
    return _userData;
  }
} 