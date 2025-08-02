#!/bin/bash

# LiveSkin IPA Build Script
# Скрипт для сборки IPA файла Flutter iOS приложения

echo "🚀 Начинаем сборку IPA для LiveSkin..."

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

# Проверяем, что Xcode установлен
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Ошибка: Xcode не найден. Установите Xcode для сборки iOS приложений."
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

# Переходим в iOS директорию
cd ios

# Очищаем iOS проект
echo "🧹 Очищаем iOS проект..."
xcodebuild clean -workspace Runner.xcworkspace -scheme Runner

# Возвращаемся в корневую директорию
cd ..

# Собираем iOS приложение
echo "🔨 Собираем iOS приложение..."
flutter build ios --release --no-codesign

# Проверяем, что сборка прошла успешно
if [ $? -eq 0 ]; then
    echo "✅ iOS приложение успешно собрано!"
    echo "📱 Приложение находится в: build/ios/iphoneos/Runner.app"
    
    # Создаем архив
    echo "📦 Создаем архив..."
    cd ios
    xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -archivePath build/Runner.xcarchive archive
    
    if [ $? -eq 0 ]; then
        echo "✅ Архив успешно создан!"
        
        # Создаем папку для IPA
        mkdir -p build/ipa/Payload
        
        # Копируем приложение в папку Payload
        cp -r build/Runner.xcarchive/Products/Applications/Runner.app build/ipa/Payload/
        
        # Создаем IPA файл
        echo "📦 Создаем IPA файл..."
        cd build/ipa
        zip -r "${BUILD_NAME}.ipa" Payload/
        
        if [ $? -eq 0 ]; then
            echo "✅ IPA файл успешно создан!"
            
            # Копируем в папку builds
            cp "${BUILD_NAME}.ipa" ../../../builds/
            
            # Показываем информацию о файле
            echo "📱 Файл: builds/${BUILD_NAME}.ipa"
            echo "📏 Размер: $(du -h "${BUILD_NAME}.ipa" | cut -f1)"
            echo "📍 Расположение: $(pwd)/../../../builds/${BUILD_NAME}.ipa"
            
            echo "🎉 Сборка завершена успешно!"
        else
            echo "❌ Ошибка при создании IPA файла"
            exit 1
        fi
        
        cd ../..
    else
        echo "❌ Ошибка при создании архива"
        exit 1
    fi
    
    cd ..
else
    echo "❌ Ошибка при сборке iOS приложения"
    exit 1
fi 