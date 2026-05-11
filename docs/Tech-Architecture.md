# Tech Architecture (iPhone)

## Stack
- Swift + SwiftUI
- SwiftData для локального persistence
- MVVM
- Weather API abstraction layer
- Позже: WidgetKit + App Intents + iCloud

## Layers
1. `Models` - доменные сущности и enum.
2. `Services` - рекомендации образов, weather provider, классификация.
3. `ViewModels` - бизнес-логика экранов.
4. `Views` - UI-компоненты и экраны.
5. `Persistence` - SwiftData integration.

## Offline Strategy
- Источник истины: локальная БД.
- Сеть опциональна, нужна только для погоды и будущих sync-фич.
- При отсутствии сети экран "Сегодня" работает на последнем сохраненном weather snapshot или ручном диапазоне температур.

## Privacy
- Фото и метаданные хранятся локально.
- Ясный consent для камеры/галереи.
- Биометрическая блокировка на вход.

## Telemetry
- Добавление вещи.
- Сохранение образа.
- Назначение образа на день.
- Подтверждение "Надето".
