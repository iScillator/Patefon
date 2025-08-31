# 🔮 Руководство по сборке Quantum Resonance Device

## 📋 Подготовка к сборке

### ✅ Проверка комплектности (по BOM списку):

#### Вычислительные модули:
- [ ] Raspberry Pi 4 Model B 8GB + корпус + радиаторы
- [ ] ESP32-S3-DevKitC-1 + макетная плата
- [ ] microSD 128GB + программное обеспечение

#### Аудиосистема:
- [ ] Focusrite Scarlett 18i8
- [ ] Микрофоны Audio-Technica ATR3350iS × 8
- [ ] PreSonus Eris E5 × 4 + Temblor T8 × 1
- [ ] Все кабели и стойки

#### Датчики:
- [ ] HC-SR04 × 4, ADXL345 × 6, TCA9548A × 2
- [ ] BMP280, DHT22
- [ ] Соединительные провода

#### Электроника:
- [ ] Mean Well LRS-150-12, DC-DC преобразователи
- [ ] TPA3116D2 × 2, радиаторы
- [ ] Все разъемы, резисторы, конденсаторы

#### Корпус:
- [ ] Алюминиевый профиль 80×40мм × 4
- [ ] Акриловые панели, крепеж
- [ ] Вентиляторы 120мм × 2

### 🛠️ Необходимые инструменты:
- Паяльная станция (температура 300-350°C)
- Мультиметр для проверки соединений
- Отвертки: Phillips, плоские разных размеров
- Шестигранные ключи: 2, 2.5, 3, 4, 5 мм
- Дрель + сверла: 2, 3, 4, 5, 6 мм
- Штангенциркуль для точных измерений
- Кусачки, стрипперы для проводов
- Тиски или струбцины для фиксации

---

## ⚡ Этап 1: Сборка блока питания

### 1.1 Основной БП и DC-DC преобразователи:

#### Подготовка Mean Well LRS-150-12:
```
Проверка перед подключением:
1. Входное напряжение: 220V AC ±10%
2. Выходное напряжение: 12V DC (регулировка потенциометром)
3. Максимальный ток: 12.5A
4. Защиты: перенапряжение, перегрузка, перегрев

Настройка выходного напряжения:
1. Включаем БП без нагрузки
2. Измеряем напряжение мультиметром
3. Регулируем потенциометром до 12.0V ±0.1V
4. Отключаем и переходим к DC-DC преобразователям
```

#### Настройка XL4015 (12V → 5V):
```
Подключение:
├── Вход: +12V, GND с основного БП
├── Выход: +5V, GND для Raspberry Pi
└── Ток: до 3A

Настройка:
1. Подключаем вход 12V
2. Регулируем выходное напряжение потенциометром
3. Устанавливаем 5.1V ±0.05V (компенсация падения)
4. Тестируем под нагрузкой 1A
5. Проверяем пульсации (<50mV)
```

#### Установка AMS1117-3.3V:
```
Подключение:
├── Вход: +5V с предыдущего преобразователя
├── Выход: +3.3V для ESP32 и датчиков
└── Ток: до 1A

Проверка:
1. Входное напряжение: 5.0V
2. Выходное напряжение: 3.3V ±0.1V
3. Нагрев корпуса: должен быть минимальным
4. Стабильность при изменении нагрузки
```

### 1.2 Монтаж системы питания:

#### Размещение в корпусе:
```
Схема расположения:
┌─────────────────────────────────────┐
│ [Вентилятор]     [AC Разъем]        │
│                                     │
│ [Mean Well БП]   [DC-DC 5V]        │
│                                     │
│ [AMS1117]        [Клеммы 12V]      │
│                                     │
│ [Предохранители] [Индикация]        │
└─────────────────────────────────────┘
```

#### Проводка питания:
```
Сечение проводов:
├── 220V AC: 1.5 мм² (с изоляцией)
├── 12V DC: 1.0 мм² (основные линии)
├── 5V DC: 0.75 мм² (до 3A)
└── 3.3V DC: 0.5 мм² (до 1A)

Цветовая маркировка:
├── +12V: Красный
├── +5V: Оранжевый  
├── +3.3V: Желтый
└── GND: Черный (общая земля)
```

---

## 🖥️ Этап 2: Настройка вычислительных модулей

### 2.1 Подготовка Raspberry Pi 4:

#### Установка ОС:
```bash
# Запись образа на microSD (с компьютера)
# Используем Raspberry Pi Imager
1. Скачиваем Raspberry Pi OS 64-bit Desktop
2. Записываем на microSD 128GB
3. Включаем SSH, WiFi (если нужно)
4. Первый запуск и настройка

# Основные настройки системы
sudo raspi-config
├── Advanced Options → Expand Filesystem
├── Interface Options → Enable SSH, I2C, SPI
├── Audio → Force 3.5mm jack (временно)
└── Reboot
```

#### Установка необходимого ПО:
```bash
# Обновление системы
sudo apt update && sudo apt upgrade -y

# Установка Python библиотек
sudo apt install python3-pip python3-venv python3-dev -y
sudo apt install portaudio19-dev python3-pyaudio -y
sudo apt install libatlas-base-dev -y

# Создание виртуального окружения
python3 -m venv ~/quantum_env
source ~/quantum_env/bin/activate

# Установка основных библиотек
pip install numpy scipy pandas
pip install librosa sounddevice soundfile
pip install RPi.GPIO adafruit-circuitpython-core
pip install tensorflow-lite-runtime
pip install scikit-learn matplotlib
```

### 2.2 Настройка ESP32-S3:

#### Установка Arduino IDE и библиотек:
```cpp
// Необходимые библиотеки для ESP32-S3
#include <WiFi.h>
#include <Wire.h>
#include <ArduinoJson.h>
#include <Adafruit_ADXL345_U.h>
#include <Adafruit_BMP280.h>
#include <FastLED.h>

// Конфигурация I2C
#define SDA_PIN 21
#define SCL_PIN 22
#define I2C_FREQ 100000

// Ультразвуковые датчики
#define NUM_ULTRASONIC 4
const int trigPins[NUM_ULTRASONIC] = {2, 16, 18, 25};
const int echoPins[NUM_ULTRASONIC] = {4, 17, 19, 26};

// Инфразвуковой микрофон
#define INFRA_MIC_PIN 36
#define ADC_RESOLUTION 12

// RGB индикация
#define LED_PIN 27
#define NUM_LEDS 60
CRGB leds[NUM_LEDS];
```

#### Программирование ESP32-S3:
```cpp
void setup() {
    Serial.begin(115200);
    
    // Инициализация I2C
    Wire.begin(SDA_PIN, SCL_PIN, I2C_FREQ);
    
    // Настройка ультразвуковых датчиков
    for (int i = 0; i < NUM_ULTRASONIC; i++) {
        pinMode(trigPins[i], OUTPUT);
        pinMode(echoPins[i], INPUT);
    }
    
    // Инициализация RGB ленты
    FastLED.addLeds<WS2812B, LED_PIN, GRB>(leds, NUM_LEDS);
    FastLED.setBrightness(50);
    
    // Настройка ADC для инфразвука
    analogReadResolution(ADC_RESOLUTION);
    analogSetAttenuation(ADC_11db);
    
    Serial.println("Quantum Resonance Device - Sensor Hub Initialized");
}

void loop() {
    // Основной цикл сбора данных
    readUltrasonicSensors();
    readAccelerometers();
    readInfrasonicMic();
    readEnvironmentalSensors();
    
    sendDataToRaspberryPi();
    updateLEDIndication();
    
    delay(50); // 20 Hz основной цикл
}
```

---

## 🎤 Этап 3: Сборка аудиосистемы

### 3.1 Подключение Focusrite Scarlett 18i8:

#### Физическое подключение:
```
К Raspberry Pi:
├── USB-C to USB-A кабель (USB 3.0)
├── Питание: от USB (bus-powered)
└── Индикация: зеленый LED = готов к работе

Проверка в системе:
lsusb | grep Focusrite
# Должно показать: Bus 002 Device 003: ID 1235:8016 Focusrite Scarlett 18i8 3rd Gen
```

#### Настройка ALSA/PulseAudio:
```bash
# Проверка доступных аудиоустройств
aplay -l
arecord -l

# Настройка по умолчанию в ~/.asoundrc
cat > ~/.asoundrc << EOF
pcm.!default {
    type pulse
}
ctl.!default {
    type pulse
}
EOF

# Перезапуск PulseAudio
pulseaudio --kill
pulseaudio --start
```

### 3.2 Установка микрофонов:

#### Размещение петличных микрофонов:
```
Схема расположения (вид сверху):
      [Mic 1]
[Mic 8]     [Mic 2]
      
[Mic 7] (C) [Mic 3]
      
[Mic 6]     [Mic 4]
      [Mic 5]

Где (C) = центр помещения (Quantum Device)
Расстояние от центра: 2-3 метра
Высота установки: 1.5-2 метра
```

#### Подключение к аудиоинтерфейсу:
```
Focusrite Scarlett 18i8 входы:
├── CH 1-4: Mic/Line combo (XLR/TRS)
├── CH 5-8: Line inputs (TRS)
└── Phantom Power: +48V для конденсаторных микрофонов

Настройка усиления:
├── Микрофоны в тихом помещении: Gain 30-40 дБ
├── Инфразвуковой микрофон: Gain 50-56 дБ
├── Индикация уровня: зеленый = норма, красный = перегрузка
└── Тестовый сигнал: разговор на расстоянии 2м
```

### 3.3 Настройка акустической системы:

#### Размещение мониторов PreSonus Eris E5:
```
Конфигурация 4.1:
├── Front L/R: перед зоной прослушивания
├── Rear L/R: за зоной прослушивания  
├── Subwoofer: в углу или центре помещения
└── Угол наклона: направлены в центр зоны

Расстояние между мониторами: 2-4 метра
Высота: на уровне ушей сидящих слушателей
Изоляция: резиновые подставки Auralex MoPad
```

#### Подключение усилителей TPA3116:
```
Схема подключения:
Focusrite Line Out → TPA3116 Input → Speaker Output

Усилитель 1: Front L/R каналы
Усилитель 2: Rear L/R каналы

Настройка:
├── Входная чувствительность: 1V RMS
├── Выходная мощность: 50W на канал (4Ω)
├── Контроль усиления: начать с минимума
└── Фазировка: проверить полярность всех каналов
```

---

## 📡 Этап 4: Установка датчиков

### 4.1 Подключение ультразвуковых датчиков HC-SR04:

#### Схема подключения:
```
ESP32-S3 GPIO → HC-SR04
├── GPIO 2  → TRIG_1, GPIO 4  → ECHO_1
├── GPIO 16 → TRIG_2, GPIO 17 → ECHO_2
├── GPIO 18 → TRIG_3, GPIO 19 → ECHO_3
└── GPIO 25 → TRIG_4, GPIO 26 → ECHO_4

Питание: +5V, GND (от преобразователя)
```

#### Размещение датчиков:
```
Позиции (вид сверху):
        [US_1]
[US_4]    🔮    [US_2]
        [US_3]

Где 🔮 = Quantum Device в центре
Расстояние: 1.5-2м от центра
Высота: 1.2м от пола
Угол охвата: 60° каждый датчик
```

#### Калибровка:
```cpp
// Функция измерения расстояния
float measureDistance(int trigPin, int echoPin) {
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);
    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);
    
    long duration = pulseIn(echoPin, HIGH, 30000); // 30ms timeout
    if (duration == 0) return -1; // Ошибка измерения
    
    float distance = (duration * 0.034) / 2; // см
    return distance;
}
```

### 4.2 Установка акселерометров ADXL345:

#### Схема I2C шины с мультиплексорами:
```
ESP32-S3 I2C Bus (GPIO 21,22)
├── ADXL345 #1 (Address: 0x53, SDO=GND)
├── ADXL345 #2 (Address: 0x1D, SDO=VCC)
├── TCA9548A #1 (Address: 0x70)
│   ├── Channel 0: ADXL345 #3 (0x53)
│   └── Channel 1: ADXL345 #4 (0x1D)
└── TCA9548A #2 (Address: 0x71)
    ├── Channel 0: ADXL345 #5 (0x53)
    └── Channel 1: ADXL345 #6 (0x1D)
```

#### Размещение вибродатчиков:
```
Локации для максимального покрытия:
├── Пол: 4 датчика по углам помещения
├── Стены: 2 датчика на противоположных стенах
└── Фиксация: двусторонний скотч или винты

Калибровка нулевых значений:
1. Установить все датчики
2. Записать фоновые вибрации (2 минуты)
3. Вычислить средние значения по осям X,Y,Z
4. Сохранить как базовую линию
```

#### Инициализация ADXL345:
```cpp
#include <Adafruit_ADXL345_U.h>

Adafruit_ADXL345_Unified accel[6];

void initAccelerometers() {
    for (int i = 0; i < 6; i++) {
        if (i < 2) {
            // Прямое подключение
            accel[i] = Adafruit_ADXL345_Unified(12345 + i);
        } else {
            // Через мультиплексор
            selectMuxChannel((i-2)/2, (i-2)%2);
            accel[i] = Adafruit_ADXL345_Unified(12345 + i);
        }
        
        if (!accel[i].begin()) {
            Serial.printf("ADXL345 #%d not found!\n", i);
        } else {
            accel[i].setRange(ADXL345_RANGE_4_G);
            accel[i].setDataRate(ADXL345_DATARATE_100_HZ);
        }
    }
}
```

### 4.3 Инфразвуковой микрофон:

#### Схема аналогового входа:
```
Инфразвуковой микрофон (custom MEMS):
├── Частотный диапазон: 0.1-20 Гц
├── Чувствительность: -40 дБВ/Па
├── Предусилитель: x100 (40 дБ)
└── Выход: 0-3.3V в ESP32 ADC

Подключение:
Mic Output → Предусилитель → GPIO 36 (ADC1_CH0)
```

#### Обработка сигнала:
```cpp
#define INFRA_SAMPLES 1000
#define SAMPLE_RATE 100 // Hz
float infraBuffer[INFRA_SAMPLES];
int bufferIndex = 0;

void readInfrasonicMic() {
    float sample = analogRead(INFRA_MIC_PIN) * (3.3 / 4095.0);
    infraBuffer[bufferIndex] = sample;
    bufferIndex = (bufferIndex + 1) % INFRA_SAMPLES;
    
    // FFT анализ каждые 10 секунд
    if (bufferIndex == 0) {
        analyzeInfrasonicSpectrum();
    }
}
```

---

## 🔧 Этап 5: Механическая сборка корпуса

### 5.1 Сборка рамы из алюминиевого профиля:

#### Подготовка профилей:
```
Размеры каркаса:
├── Длина: 600 мм (2 профиля)
├── Ширина: 400 мм (2 профиля)  
├── Высота: 300 мм (4 профиля)
└── Общий объем: 72 литра

Резка профилей:
1. Используем торцовочную пилу или болгарку
2. Зачищаем торцы напильником
3. Снимаем фаски для лучшего прилегания
4. Проверяем перпендикулярность угольником
```

#### Сборка каркаса:
```
Порядок сборки:
1. Собираем нижнюю раму (400×600 мм)
2. Устанавливаем вертикальные стойки (4 шт)
3. Собираем верхнюю раму
4. Проверяем геометрию рулеткой и угольником
5. Затягиваем все соединения

Крепеж:
├── Т-образные гайки M5 в пазы профиля
├── Винты M5×12 мм с цилиндрической головкой
├── Момент затяжки: 3-4 Нм (не перетягивать!)
└── Фиксатор резьбы на ответственных соединениях
```

### 5.2 Установка панелей и вентиляции:

#### Монтаж акриловых панелей:
```
Подготовка панелей:
├── Размер: 400×300×3 мм (боковые)
├── Отверстия: сверлим в соответствии с профилем
├── Сверло: 5.2 мм для винтов M5
└── Зенковка: под головки винтов

Установка:
1. Снимаем защитную пленку (после всех работ!)
2. Устанавливаем уплотнительные прокладки
3. Крепим винтами M5×16 с шайбами
4. Не перетягиваем - акрил может треснуть!
```

#### Система охлаждения:
```
Вентиляторы 120×120×25 мм:
├── Вход: нижняя панель, 2 вентилятора
├── Выход: верхняя панель, 1 вентилятор
├── Скорость: 800-1200 об/мин (тихие)
└── Питание: 12V, 0.15A каждый

Воздушный поток:
Вход (снизу) → Компоненты → Выход (сверху)
Избыточное давление предотвращает попадание пыли
```

### 5.3 Внутренняя компоновка:

#### Размещение компонентов:
```
Схема расположения (вид сбоку):
┌─────────────────────────────────────┐ ← Верхняя панель + вентилятор
│  [RGB контроллер]  [Клеммы]         │
├─────────────────────────────────────┤
│  [Raspberry Pi]    [ESP32-S3]       │
│                                     │
│  [Focusrite]       [Усилители]      │ ← Средний уровень
│                                     │
│  [БП 12V]          [DC-DC 5V,3.3V]  │
├─────────────────────────────────────┤
│  [Вентиляторы]     [Предохранители] │ ← Нижняя панель
└─────────────────────────────────────┘
```

#### DIN-рейки и крепление:
```
Установка DIN-реек:
├── 3 рейки по 300 мм горизонтально
├── Крепление к профилю T-гайками M5
├── Все модули на DIN-крепления или адаптеры
└── Легкий доступ для обслуживания

Модули на DIN-рейках:
├── Raspberry Pi: специальный DIN-корпус
├── ESP32-S3: макетная плата + DIN-адаптер
├── DC-DC преобразователи: готовые DIN-модули
└── Клеммные колодки: стандартные Wago
```

---

## 🎛️ Этап 6: Программная настройка

### 6.1 Основное ПО для Raspberry Pi:

#### Главный модуль управления:
```python
#!/usr/bin/env python3
"""
Quantum Resonance Device - Main Controller
"""

import asyncio
import numpy as np
import sounddevice as sd
import librosa
from datetime import datetime
import json

class QuantumResonanceDevice:
    def __init__(self):
        self.sample_rate = 48000
        self.block_size = 1024
        self.channels = 8
        
        # Инициализация аудиосистемы
        self.init_audio_system()
        
        # Инициализация связи с ESP32
        self.init_esp32_communication()
        
        # Загрузка ML моделей
        self.load_ml_models()
        
    def init_audio_system(self):
        """Инициализация Focusrite Scarlett"""
        devices = sd.query_devices()
        
        # Поиск Focusrite в списке устройств
        focusrite_input = None
        focusrite_output = None
        
        for i, device in enumerate(devices):
            if 'Scarlett' in device['name']:
                if device['max_input_channels'] > 0:
                    focusrite_input = i
                if device['max_output_channels'] > 0:
                    focusrite_output = i
        
        if focusrite_input is None:
            raise Exception("Focusrite Scarlett не найден!")
            
        self.input_device = focusrite_input
        self.output_device = focusrite_output
        
        print(f"Аудиосистема инициализирована: вход={focusrite_input}, выход={focusrite_output}")
        
    async def audio_callback(self, indata, outdata, frames, time, status):
        """Основной аудио коллбэк"""
        if status:
            print(f"Audio callback status: {status}")
            
        # Анализ входного сигнала
        audio_features = self.analyze_audio(indata)
        
        # Получение данных датчиков
        sensor_data = await self.get_sensor_data()
        
        # Анализ эмоционального состояния
        emotional_state = self.analyze_emotional_state(audio_features, sensor_data)
        
        # Генерация ответного воздействия
        response_audio = self.generate_response(emotional_state, indata)
        
        # Вывод обработанного сигнала
        outdata[:] = response_audio
        
    def analyze_audio(self, audio_data):
        """Анализ аудиосигнала"""
        features = {}
        
        # Спектральный анализ для каждого канала
        for ch in range(self.channels):
            channel_data = audio_data[:, ch]
            
            # Основные характеристики
            features[f'rms_ch{ch}'] = np.sqrt(np.mean(channel_data**2))
            features[f'zcr_ch{ch}'] = librosa.feature.zero_crossing_rate(channel_data)[0]
            
            # Спектральные характеристики
            stft = librosa.stft(channel_data, n_fft=512)
            magnitude = np.abs(stft)
            
            features[f'spectral_centroid_ch{ch}'] = librosa.feature.spectral_centroid(S=magnitude)[0]
            features[f'spectral_bandwidth_ch{ch}'] = librosa.feature.spectral_bandwidth(S=magnitude)[0]
            
        return features
        
    async def get_sensor_data(self):
        """Получение данных с ESP32"""
        # Реализация чтения через Serial/WiFi
        try:
            # Здесь будет код чтения с ESP32
            sensor_data = {
                'ultrasonic': [0, 0, 0, 0],  # 4 датчика
                'accelerometer': [[0,0,0] for _ in range(6)],  # 6 датчиков
                'infrasonic': 0.0,
                'environmental': {'temperature': 20, 'humidity': 50, 'pressure': 1013}
            }
            return sensor_data
        except Exception as e:
            print(f"Ошибка чтения датчиков: {e}")
            return None
            
    def analyze_emotional_state(self, audio_features, sensor_data):
        """Анализ эмоционального состояния аудитории"""
        # Здесь будет ML модель для анализа эмоций
        emotional_state = {
            'valence': 0.5,  # Позитивность (-1 до +1)
            'arousal': 0.3,  # Возбуждение (0 до 1)
            'attention': 0.7,  # Внимание (0 до 1)
            'synchrony': 0.4   # Синхронность аудитории (0 до 1)
        }
        
        return emotional_state
        
    def generate_response(self, emotional_state, input_audio):
        """Генерация ответного воздействия"""
        # Копируем входной сигнал как основу
        output_audio = input_audio.copy()
        
        # Применяем эффекты на основе эмоционального состояния
        
        # Пространственные эффекты
        if emotional_state['synchrony'] < 0.3:
            # Низкая синхронность - усиливаем центральные каналы
            output_audio[:, 0] *= 1.2  # Front L
            output_audio[:, 1] *= 1.2  # Front R
            
        # Частотная обработка
        if emotional_state['arousal'] > 0.7:
            # Высокое возбуждение - подчеркиваем высокие частоты
            # Здесь будет фильтрация
            pass
            
        return output_audio
        
    async def main_loop(self):
        """Основной цикл работы"""
        print("Запуск Quantum Resonance Device...")
        
        # Запуск аудиопотока
        with sd.Stream(
            device=(self.input_device, self.output_device),
            samplerate=self.sample_rate,
            blocksize=self.block_size,
            channels=(self.channels, self.channels),
            callback=self.audio_callback,
            dtype='float32'
        ):
            print("Система готова к работе. Нажмите Ctrl+C для остановки.")
            try:
                while True:
                    await asyncio.sleep(1)
            except KeyboardInterrupt:
                print("Остановка системы...")

if __name__ == "__main__":
    device = QuantumResonanceDevice()
    asyncio.run(device.main_loop())
```

### 6.2 Автозапуск системы:

#### Создание systemd сервиса:
```bash
# Создаем сервисный файл
sudo nano /etc/systemd/system/quantum-resonance.service

[Unit]
Description=Quantum Resonance Device
After=network.target sound.target
Wants=network.target

[Service]
Type=simple
User=pi
Group=audio
WorkingDirectory=/home/pi/quantum-resonance
Environment=PATH=/home/pi/quantum_env/bin
ExecStart=/home/pi/quantum_env/bin/python main.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target

# Активируем сервис
sudo systemctl daemon-reload
sudo systemctl enable quantum-resonance.service
sudo systemctl start quantum-resonance.service

# Проверяем статус
sudo systemctl status quantum-resonance.service
```

---

## ✅ Этап 7: Тестирование и калибровка

### 7.1 Проверка всех систем:

#### Чек-лист финального тестирования:
```
Питание:
[ ] 220V AC → 12V DC (напряжение, стабильность)
[ ] 12V → 5V (для Raspberry Pi)  
[ ] 5V → 3.3V (для ESP32 и датчиков)
[ ] Нагрев компонентов (должен быть умеренным)

Связь и коммуникации:
[ ] Raspberry Pi загружается и подключается к сети
[ ] ESP32 программируется и общается с датчиками
[ ] UART связь ESP32 ↔ Raspberry Pi
[ ] I2C шина со всеми датчиками

Аудиосистема:
[ ] Focusrite распознается системой
[ ] Все 8 входов принимают сигнал
[ ] Все 8 выходов передают сигнал
[ ] Усилители TPA3116 работают без искажений
[ ] Мониторы воспроизводят звук

Датчики:
[ ] 4 ультразвуковых датчика измеряют расстояние
[ ] 6 акселерометров регистрируют вибрации
[ ] Инфразвуковой микрофон улавливает низкие частоты
[ ] Датчики окружающей среды работают

Индикация:
[ ] RGB лента отображает статус системы
[ ] Статусные светодиоды показывают режимы работы
[ ] Элементы управления функционируют
```

### 7.2 Акустическая калибровка:

#### Измерение импульсной характеристики помещения:
```python
import numpy as np
import sounddevice as sd
from scipy import signal

def measure_room_response():
    """Измерение акустической характеристики помещения"""
    
    # Генерация тестового сигнала (sweep)
    duration = 5.0  # секунд
    sample_rate = 48000
    
    # Логарифмический свип 20 Гц - 20 кГц
    t = np.linspace(0, duration, int(sample_rate * duration))
    f1, f2 = 20, 20000
    sweep = signal.chirp(t, f1, duration, f2, method='logarithmic')
    
    # Воспроизведение и запись
    recording = sd.playrec(sweep, samplerate=sample_rate, channels=8)
    sd.wait()
    
    # Вычисление импульсной характеристики
    impulse_responses = []
    for ch in range(8):
        ir = signal.correlate(recording[:, ch], sweep, mode='full')
        impulse_responses.append(ir)
    
    return impulse_responses

# Запуск калибровки
print("Начинаем акустическую калибровку...")
room_ir = measure_room_response()
print("Калибровка завершена. Сохраняем результаты...")

# Сохранение для последующего использования
np.save('room_impulse_response.npy', room_ir)
```

### 7.3 Калибровка датчиков:

#### Базовая линия для акселерометров:
```python
import time
import numpy as np

def calibrate_accelerometers():
    """Калибровка нулевых значений акселерометров"""
    
    print("Калибровка акселерометров (60 секунд)...")
    print("Обеспечьте полную тишину в помещении!")
    
    baseline_data = {f'accel_{i}': {'x': [], 'y': [], 'z': []} for i in range(6)}
    
    for second in range(60):
        print(f"Калибровка: {second+1}/60", end='\r')
        
        # Здесь читаем данные с ESP32
        for i in range(6):
            # Заглушка - в реальности читаем с датчиков
            x, y, z = np.random.normal(0, 0.01, 3)  # Имитация шума
            baseline_data[f'accel_{i}']['x'].append(x)
            baseline_data[f'accel_{i}']['y'].append(y)
            baseline_data[f'accel_{i}']['z'].append(z)
            
        time.sleep(1)
    
    # Вычисление средних значений и стандартных отклонений
    baseline_stats = {}
    for i in range(6):
        baseline_stats[f'accel_{i}'] = {
            'offset_x': np.mean(baseline_data[f'accel_{i}']['x']),
            'offset_y': np.mean(baseline_data[f'accel_{i}']['y']),
            'offset_z': np.mean(baseline_data[f'accel_{i}']['z']),
            'noise_x': np.std(baseline_data[f'accel_{i}']['x']),
            'noise_y': np.std(baseline_data[f'accel_{i}']['y']),
            'noise_z': np.std(baseline_data[f'accel_{i}']['z'])
        }
    
    print("\nКалибровка завершена!")
    return baseline_stats

# Запуск калибровки
calibration_data = calibrate_accelerometers()

# Сохранение калибровочных данных
import json
with open('sensor_calibration.json', 'w') as f:
    json.dump(calibration_data, f, indent=2)
```

---

## 🎯 Этап 8: Финальная настройка и тестирование

### 8.1 Интеграционное тестирование:

#### Тест полной системы:
```
Сценарий тестирования:
1. Включение системы (автозапуск)
2. Прослушивание музыки с винилового патефона
3. Имитация движений аудитории
4. Изменение эмоциональных реакций
5. Фиксация ответных воздействий системы

Ожидаемые результаты:
├── Система стабильно работает минимум 2 часа
├── Нет перегрева компонентов
├── Аудиотракт без искажений и помех
├── Датчики корректно реагируют на движения
└── RGB индикация отражает состояние системы
```

### 8.2 Документирование настроек:

#### Создание конфигурационного файла:
```json
{
  "system_config": {
    "version": "1.0",
    "installation_date": "2024-XX-XX",
    "location": "Test Room",
    "room_dimensions": {
      "length": 6.0,
      "width": 4.0, 
      "height": 3.0
    }
  },
  "audio_settings": {
    "sample_rate": 48000,
    "block_size": 1024,
    "input_channels": 8,
    "output_channels": 8,
    "microphone_gain": [30, 30, 30, 30, 35, 35, 35, 50],
    "speaker_levels": [0.8, 0.8, 0.8, 0.8, 0.6]
  },
  "sensor_positions": {
    "ultrasonics": [
      {"id": 0, "x": 0, "y": 2, "angle": 180},
      {"id": 1, "x": 2, "y": 0, "angle": 270},
      {"id": 2, "x": 0, "y": -2, "angle": 0},
      {"id": 3, "x": -2, "y": 0, "angle": 90}
    ],
    "accelerometers": [
      {"id": 0, "x": -2, "y": -2, "surface": "floor"},
      {"id": 1, "x": 2, "y": -2, "surface": "floor"},
      {"id": 2, "x": 2, "y": 2, "surface": "floor"},
      {"id": 3, "x": -2, "y": 2, "surface": "floor"},
      {"id": 4, "x": 0, "y": -2, "surface": "wall"},
      {"id": 5, "x": 0, "y": 2, "surface": "wall"}
    ]
  },
  "calibration_data": {
    "room_ir_file": "room_impulse_response.npy",
    "sensor_baseline_file": "sensor_calibration.json",
    "last_calibration": "2024-XX-XX"
  }
}
```

---

## 📚 Завершение сборки

### ✅ Финальный чек-лист:

#### Техническая проверка:
- [ ] Все компоненты правильно подключены и функционируют
- [ ] Система стабильно работает без перезагрузок
- [ ] Температура компонентов в норме (< 70°C)
- [ ] Аудиотракт без помех и искажений
- [ ] Датчики корректно реагируют на стимулы
- [ ] Программное обеспечение запускается автоматически

#### Документация:
- [ ] Все настройки записаны в конфигурационные файлы
- [ ] Созданы резервные копии ПО и настроек
- [ ] Ведется журнал калибровок и изменений
- [ ] Подготовлена инструкция для пользователя

#### Безопасность:
- [ ] Электробезопасность: заземление, УЗО
- [ ] Механическая безопасность: отсутствие острых краев
- [ ] Пожарная безопасность: удаленность от источников тепла
- [ ] Защита от влаги: IP20 минимум

### 🎉 Поздравляем!

Quantum Resonance Device успешно собран и настроен! 

Устройство готово к интеграции с механическим патефоном для создания уникального иммерсивного музыкального опыта.

---

*Помните: каждая система уникальна и требует индивидуальной настройки под конкретное помещение и аудиторию. Ведите подробные записи всех изменений и настроек для будущего обслуживания.*
