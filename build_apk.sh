#!/bin/bash

# LiveSkin APK Build Script
# Скрипт для сборки APK файла Flutter Android приложения

echo "🚀 Начинаем сборку APK для LiveSkin..."

# Проверяем, что мы в правильной директории
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Ошибка: pubspec.yaml не найден. Убедитесь, что вы находитесь в корневой папке Flutter проекта."
    exit 1
fi

# Получаем версию из pubspec.yaml
VERSION=$(grep 'version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
PROJECT_NAME="LiveSkin"
BUILD_NAME="${PROJECT_NAME}-${VERSION}"

echo "📦 Версия: $VERSION"
echo "🏗️  Имя сборки: $BUILD_NAME"

# Проверяем, что Android SDK установлен
if ! command -v flutter &> /dev/null; then
    echo "❌ Ошибка: Flutter не найден. Установите Flutter для сборки Android приложений."
    exit 1
fi

# Создаем папку builds если её нет
mkdir -p builds

# Очищаем предыдущие сборки
echo "🧹 Очищаем предыдущие сборки..."
flutter clean

# Получаем зависимости
echo "📦 Получаем зависимости..."
flutter pub get

# Проверяем Flutter
echo "🔍 Проверяем Flutter..."
flutter doctor

# Собираем Android приложение
echo "🔨 Собираем Android приложение..."
flutter build apk --release

# Проверяем, что сборка прошла успешно
if [ $? -eq 0 ]; then
    echo "✅ Android приложение успешно собрано!"
    
    # Проверяем наличие APK файла
    if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
        echo "📱 APK файл найден!"
        
        # Копируем в папку builds с новым именем
        cp "build/app/outputs/flutter-apk/app-release.apk" "builds/${BUILD_NAME}.apk"
        
        # Показываем информацию о файле
        echo "📱 Файл: builds/${BUILD_NAME}.apk"
        echo "📏 Размер: $(du -h "builds/${BUILD_NAME}.apk" | cut -f1)"
        echo "📍 Расположение: $(pwd)/builds/${BUILD_NAME}.apk"
        
        echo "🎉 Сборка завершена успешно!"
    else
        echo "❌ APK файл не найден в build/app/outputs/flutter-apk/app-release.apk"
        exit 1
    fi
else
    echo "❌ Ошибка при сборке Android приложения"
    exit 1
fi 