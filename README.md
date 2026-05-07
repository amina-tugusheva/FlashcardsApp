# Flashcards Learning App

Мобильное приложение для обучения по карточкам, созданное на Flutter.  
Приложение помогает запоминать термины и определения с помощью карточек, режима тестирования и системы интервального повторения по Лейтнеру.

## О проекте

Приложение предназначено для удобного обучения и повторения учебного материала.  
Пользователь может создавать карточки вручную и сохранять существующие, проходить обучение, повторять карточки и отслеживать прогресс.

## Основные возможности

- Создание карточек вручную.
- Экран обучения с карточками и свайп-навигацией.
- Режим тестирования с выбором ответов.
- Режим проверки с записыванием ответа по памяти.
- Система Лейтнера для интервального повторения.
- Повтор неправильных карточек в течение одного сеанса до правильного ответа.
- Хранение данных пользователя и карточек в Firebase / Firestore.
- Статистика прохождения и прогресса обучения.

## Технологии

- Flutter
- Dart
- Firebase Authentication
- Cloud Firestore
- File picker / document picker

## Система Лейтнера

В приложении используется система интервального повторения, которая помогает переносить хорошо выученные карточки на более высокий уровень.  
Карточки с более высоким `box` повторяются реже, а карточки с ошибками могут возвращаться в повторение в течение того же сеанса.

## Пример использования

- Создай модуль по теме.
- Добавь карточки.
- Пройди обучение.
- Запусти тест.
- Повторяй карточки, пока не достигнешь полного прогресса.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
