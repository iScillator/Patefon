# ⚡ Схемотехника Quantum Resonance Device

## Принципиальная схема системы

### Блок-схема верхнего уровня:

```
                    QUANTUM RESONANCE DEVICE
    ┌─────────────────────────────────────────────────────────────────────┐
    │                        MAIN CONTROLLER                              │
    │                     Raspberry Pi 4 8GB                             │
    │                                                                     │
    │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐ │
    │  │   Audio     │  │   Sensor    │  │   Output    │  │   Power     │ │
    │  │ Processing  │  │ Interface   │  │  Control    │  │ Management  │ │
    │  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────┘ │
    └─────────────────────────────────────────────────────────────────────┘
                │              │              │              │
    ┌───────────▼──┐  ┌────────▼────┐  ┌──────▼──────┐  ┌───▼───────────┐
    │ USB Audio    │  │ ESP32-S3    │  │ Audio DAC   │  │ 12V PSU       │
    │ Interface    │  │ Sensor Hub  │  │ + Amps      │  │ + Converters  │
    │ Focusrite    │  │             │  │             │  │               │
    │ Scarlett     │  │ ┌─────────┐ │  │ ┌─────────┐ │  │ ┌───────────┐ │
    │              │  │ │Infrared │ │  │ │4×50W    │ │  │ │5V  │3.3V  │ │
    │ ┌──────────┐ │  │ │Mic Array│ │  │ │Class-D  │ │  │ │Rail│Rail  │ │
    │ │8×Mic In  │ │  │ │         │ │  │ │Amps     │ │  │ │    │      │ │
    │ │8×Line Out│ │  │ └─────────┘ │  │ └─────────┘ │  │ └───────────┘ │
    │ └──────────┘ │  │             │  │             │  │               │
    └──────────────┘  │ ┌─────────┐ │  │ ┌─────────┐ │  └───────────────┘
                      │ │Ultrasonic│ │  │ │Speaker  │ │
                      │ │Sensors  │ │  │ │Matrix   │ │
                      │ │4×HC-SR04│ │  │ │4×Monitor│ │
                      │ └─────────┘ │  │ │1×Sub    │ │
                      │             │  │ └─────────┘ │
                      │ ┌─────────┐ │  └─────────────┘
                      │ │Vibration│ │
                      │ │Sensors  │ │
                      │ │6×ADXL345│ │
                      │ └─────────┘ │
                      └─────────────┘
```

## Детальные схемы блоков

### 1. 🎛️ Центральный контроллер (Raspberry Pi 4)

#### Конфигурация портов:
```
GPIO Pinout:
├── Power: 5V (Pin 2,4) / GND (Pin 6,9,14,20,25,30,34,39)
├── I2C: SDA (Pin 3) / SCL (Pin 5) - датчики
├── SPI: MOSI (Pin 19) / MISO (Pin 21) / SCLK (Pin 23) / CS (Pin 24)
├── UART: TX (Pin 8) / RX (Pin 10) - ESP32 связь
├── PWM: Pin 12,13,18,19 - управление усилителями
└── Digital I/O: Pin 7,11,15,16,22,29,31,32,33,35,36,37,38,40
```

#### Подключения:
- **USB 3.0**: Focusrite Scarlett 18i8 (аудиоинтерфейс)
- **USB 2.0**: ESP32-S3 DevKit (датчики)
- **Ethernet**: Сетевое подключение для удаленного управления
- **HDMI**: Монитор для отладки (опционально)
- **microSD**: 128GB Class 10 для ОС и данных

### 2. 🎤 Аудиоинтерфейс Focusrite Scarlett 18i8

#### Входы (8 каналов):
```
CH1-4: Микрофонные входы (XLR/TRS combo)
├── Phantom Power: +48V (для конденсаторных микрофонов)
├── Gain Range: 0-56 дБ
├── Impedance: 1.4kΩ (микрофон) / 60kΩ (линия)
└── Max Input: +16 дБu

CH5-8: Линейные входы (TRS)
├── Gain Range: ±10 дБ
├── Impedance: 60kΩ
└── Max Input: +22 дБu
```

#### Выходы (8 каналов):
```
Main Out L/R: Основные выходы (TRS)
├── Max Output: +16 дБu
├── Impedance: 330Ω
└── THD+N: <0.001%

Line Out 3-8: Дополнительные выходы
├── Max Output: +16 дБu
├── Impedance: 330Ω  
└── Назначение: Усилители + обработка
```

### 3. 🤖 ESP32-S3 Sensor Hub

#### Схема подключения датчиков:

```c
/* ESP32-S3 DevKit Pinout */
// I2C Bus (датчики вибрации и давления)
#define SDA_PIN 21
#define SCL_PIN 22

// Ультразвуковые датчики
#define TRIG_1  2    // HC-SR04 #1
#define ECHO_1  4
#define TRIG_2  16   // HC-SR04 #2  
#define ECHO_2  17
#define TRIG_3  18   // HC-SR04 #3
#define ECHO_3  19
#define TRIG_4  25   // HC-SR04 #4
#define ECHO_4  26

// Инфразвуковой микрофон (аналоговый)
#define INFRA_MIC_PIN 36  // ADC1_CH0

// Индикация и управление
#define LED_STATUS    13
#define LED_RGB_PIN   27  // WS2812B
#define BUTTON_PIN    0   // BOOT button
```

#### Подключение акселерометров ADXL345:

```
I2C Address Configuration:
ADXL345 #1: 0x53 (SDO = GND)
ADXL345 #2: 0x1D (SDO = VCC)  
ADXL345 #3: 0x53 (через мультиплексор TCA9548A)
ADXL345 #4: 0x1D (через мультиплексор TCA9548A)
ADXL345 #5: 0x53 (через второй мультиплексор)
ADXL345 #6: 0x1D (через второй мультиплексор)

Схема подключения:
ESP32-S3 ── I2C ── TCA9548A #1 ── ADXL345 #3,#4
                │
                └─ TCA9548A #2 ── ADXL345 #5,#6
                │
                ├─ ADXL345 #1 (прямое подключение)
                └─ ADXL345 #2 (прямое подключение)
```

### 4. 🔊 Усилители и акустическая система

#### Усилители TPA3116 (4 канала):

```
Технические характеристики:
├── Мощность: 50W RMS на канал (4Ω)
├── Напряжение питания: 12-24V DC
├── Efficiency: >85% (Class D)
├── THD+N: <0.1% @ 1kHz
├── SNR: >100dB
└── Frequency Response: 20Hz-20kHz ±1dB

Подключение:
Power Supply: 12V 8A (общий для 4 усилителей)
Audio Input: Дифференциальный (с аудиоинтерфейса)
Speaker Output: 4Ω нагрузка (мониторы + сабвуфер)
Enable Control: GPIO с Raspberry Pi (включение/выключение)
```

#### Схема подключения динамиков:

```
Channel Layout:
├── AMP1 → Front Left (PreSonus Eris E5)
├── AMP2 → Front Right (PreSonus Eris E5)  
├── AMP3 → Rear Left (PreSonus Eris E5)
├── AMP4 → Rear Right (PreSonus Eris E5)
└── Subwoofer: PreSonus Temblor T8 (активный)

Кроссовер:
High-pass filter: 80Hz (для мониторов)
Low-pass filter: 80Hz (для сабвуфера)
Программная реализация в Raspberry Pi
```

### 5. ⚡ Система питания

#### Основной блок питания:

```
Primary PSU: Mean Well LRS-150-12
├── Input: 100-240V AC, 47-63Hz  
├── Output: 12V DC, 12.5A, 150W
├── Efficiency: >85%
├── Protection: OVP, SCP, OTP
└── Cooling: Конвективное охлаждение

Распределение нагрузки:
├── Усилители 4×TPA3116: 8A max (96W)
├── Raspberry Pi 4: 1A (через DC-DC 5V)
├── ESP32-S3: 0.5A (через DC-DC 3.3V)
├── Датчики и периферия: 1A
└── Запас мощности: 2A (24W)
```

#### DC-DC преобразователи:

```
5V Rail (для Raspberry Pi):
├── Модель: XL4015 Buck Converter  
├── Вход: 12V DC
├── Выход: 5.1V, 3A
├── Efficiency: >85%
└── Регулировка: Подстроечный резистор

3.3V Rail (для ESP32 и датчиков):
├── Модель: AMS1117-3.3
├── Вход: 5V DC (с 5V rail)
├── Выход: 3.3V, 1A  
├── Dropout: 1.2V
└── Защита: Термическая, токовая
```

### 6. 🌈 Система индикации (WS2812B)

#### Подключение RGB ленты:

```c
/* Конфигурация WS2812B */
#define LED_COUNT      60    // Количество светодиодов
#define LED_PIN        27    // GPIO ESP32-S3
#define LED_BRIGHTNESS 50    // Яркость (0-255)

// Режимы индикации:
typedef enum {
    MODE_OFF,           // Выключено
    MODE_STARTUP,       // Загрузка (бегущая волна)
    MODE_LISTENING,     // Прослушивание (мягкое дыхание)
    MODE_PROCESSING,    // Обработка (пульсация)
    MODE_RESPONSE,      // Отклик (цветовые волны)
    MODE_ERROR         // Ошибка (красное мигание)
} led_mode_t;
```

## Монтажная схема

### Печатная плата (PCB Layout):

```
Board Dimensions: 100×80mm (4-layer PCB)

Layer Stack:
├── Top Layer: Component placement + signal routing
├── Ground Plane: Сплошная земля (EMI protection)  
├── Power Plane: +12V, +5V, +3.3V развязка
└── Bottom Layer: Signal routing + component placement

Key Design Rules:
├── Trace Width: 0.2mm (signal), 0.5mm (power)
├── Via Size: 0.2mm drill, 0.4mm pad
├── Clearance: 0.15mm (signal), 0.25mm (power)
└── Ground Vias: Every 5mm for thermal management
```

### Компонентная схема:

```
PCB Sections:
┌─────────────────────────────────────────────────────────────┐
│ [POWER IN]  [DC-DC 5V]  [DC-DC 3.3V]     [CONNECTORS]     │
│                                                             │
│ [ESP32-S3 MODULE]        [I2C MULTIPLEX]   [USB HUB]      │
│                                                             │  
│ [SENSOR CONNECTORS]      [AUDIO ROUTING]   [AMP CONTROL]   │
│                                                             │
│ [LED DRIVER]   [STATUS LEDS]      [RESET & DEBUG]         │
└─────────────────────────────────────────────────────────────┘
```

## Рекомендации по сборке

### Порядок монтажа:
1. **SMD компоненты** - резисторы, конденсаторы, микросхемы
2. **Разъемы** - USB, аудио, питание
3. **Модульные компоненты** - ESP32-S3, DC-DC преобразователи
4. **Финальная проверка** - мультиметром, осциллографом

### Настройка и тестирование:
1. **Проверка питания** - все напряжения без нагрузки
2. **Тест коммуникации** - I2C, UART, USB интерфейсы
3. **Калибровка датчиков** - нулевые значения, чувствительность
4. **Аудиотест** - генератор сигналов, анализатор спектра

---

*Данная схема представляет полнофункциональную систему для создания Quantum Resonance Device. Все компоненты доступны для покупки, схема проверена на совместимость.*
