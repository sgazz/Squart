# 📋 Squart App - Мастер План Развоја

Ево свеобухватног плана развоја који ћемо пратити:

---

## 🎯 ФАЗА 0: Припрема пројекта (1 дан)

### 0.1 Setup пројекта
- [ ] Креирање Flutter пројекта са multi-platform подршком
- [ ] Конфигурација за iOS, Android, macOS, Windows, Linux, Web
- [ ] Setup provider state management
- [ ] Дефинисање структуре директоријума

### 0.2 Dependences
- [ ] Додавање свих потребних пакета у `pubspec.yaml`
- [ ] Конфигурација assets (звуци, иконе)
- [ ] Setup фонтова

### 0.3 Core Constants
- [ ] `app_colors.dart` - дефинисање палете боја
- [ ] `app_sizes.dart` - величине и spacing
- [ ] `game_constants.dart` - правила игре

---

## 🏗️ ФАЗА 1: MVP - Core Gameplay (3-4 дана)

**Циљ**: Функционална Player vs Player игра без AI

### 1.1 Models (Dan 1)
- [ ] `Cell` model - представља једно поље на табли
- [ ] `Token` model - хоризонтални/вертикални жетон
- [ ] `GameState` model - стање игре (табла, играчи, потези)
- [ ] `GameSettings` model - подешавања (величина, тајмер)

### 1.2 Game Logic Service (Dan 1-2)
- [ ] Генерисање табле са црним пољима (17-19% random)
- [ ] Валидација потеза (хоризонтални/вертикални)
- [ ] Провера победничких услова (нема више валидних потеза)
- [ ] Детекција краја игре
- [ ] Unit tests за game logic

### 1.3 Basic UI - Home Screen (Dan 2)
- [ ] Home screen са једноставним дизајном
- [ ] "New Game" button
- [ ] Избор величине табле (5x5 до 20x20, default 7x7)
- [ ] Навигација ка Game Screen

### 1.4 Game Screen - Basic (Dan 2-3)
- [ ] `GameProvider` - state management
- [ ] `GameBoard` widget - рендеровање табле
- [ ] `BoardCell` widget - појединачно поље
- [ ] Touch detection за постављање жетона
- [ ] Визуелни приказ тренутног играча (Blue/Red)
- [ ] Смењивање играча
- [ ] End game екран (победник)

### 1.5 Testiranje (Dan 4)
- [ ] Тестирање свих величина табли
- [ ] Провера валидације потеза
- [ ] Провера победничких услова
- [ ] Bug fixing

**Milestone 1**: ✅ Функционална P vs P игра на једном уређају

---

## 🎨 ФАЗА 2: UI/UX Polish & Design (2-3 дана)

**Циљ**: Glassmorph дизајн, анимације, звук

### 2.1 Glassmorph Design System (Dan 5)
- [ ] `GlassContainer` widget са blur ефектом
- [ ] Gradient позадине (dark/light theme)
- [ ] `app_theme.dart` - комплетна тема
- [ ] Редизајн Home Screen са glassmorph
- [ ] Редизајн Game Screen са glassmorph

### 2.2 Token Design (Dan 5)
- [ ] `TokenWidget` - zaobljeni pravougaonici
- [ ] Plavi жетони (хоризонтални)
- [ ] Црвени жетони (вертикални)
- [ ] Црна поља (шаховски pattern)
- [ ] Hover/Preview ефекат пре постављања

### 2.3 Animations (Dan 6)
- [ ] Token placement анимација (scale + fade in)
- [ ] Board появљивање (staggered animation)
- [ ] Прелаз између екрана (smooth transitions)
- [ ] Победнички екран анимација

### 2.4 Audio & Haptics (Dan 6)
- [ ] `AudioManager` service
- [ ] `HapticManager` service
- [ ] Звук за постављање жетона
- [ ] Звук за крај игре (победа/пораз)
- [ ] Вибрација при постављању жетона
- [ ] Вибрација за invalid потез

### 2.5 Theme Switching (Dan 7)
- [ ] Dark theme (primary)
- [ ] Light theme
- [ ] Theme toggle у settings
- [ ] Чување preference

**Milestone 2**: ✅ Визуелно завршена игра са одличним UX

---

## ⚙️ ФАЗА 3: Features - Timer & Settings (2 дана)

**Циљ**: Шаховски тајмер и подешавања

### 3.1 Timer System (Dan 8)
- [ ] `TimerWidget` - countdown приказ
- [ ] Логика за смењивање тајмера
- [ ] Пауза/Resume функционалност
- [ ] Време истекло = крај игре
- [ ] Опције: 1, 3, 5, 10 min, неограничено
- [ ] Визуелни warning (последњих 10 секунди)

### 3.2 Settings Screen (Dan 8-9)
- [ ] Settings screen UI (glassmorph)
- [ ] Hints toggle (on/off)
- [ ] Звук on/off
- [ ] Вибрација on/off
- [ ] Theme selection
- [ ] Чување settings у shared_preferences

### 3.3 Hints System (Dan 9)
- [ ] Приказ валидних потеза (ако је hints укључен)
- [ ] Highlight могућих поља
- [ ] Број доступних потеза
- [ ] Може се искључити у settings

**Milestone 3**: ✅ Комплетна P vs P игра са свим features

---

## 🤖 ФАЗА 4: AI Opponent (3-4 дана)

**Циљ**: Player vs AI са 3 нивоа тежине

### 4.1 AI Service Structure (Dan 10)
- [ ] `AIService` класа
- [ ] Интерфејс за различите тежине
- [ ] Асинхроно извршавање (не блокира UI)

### 4.2 Easy AI (Dan 10)
- [ ] 60% greedy (смањи противникове опције)
- [ ] 30% центар табле
- [ ] 10% random
- [ ] Delay 500-1000ms (да изгледа да "размишља")

### 4.3 Medium AI (Dan 11)
- [ ] Minimax алгоритам depth 2-3
- [ ] Хеуристика евалуација:
  - Број моји потези - број противникови потези
  - Бонус за центар
  - Бонус за блокирање
- [ ] Delay 1000-1500ms

### 4.4 Hard AI (Dan 11-12)
- [ ] Minimax depth 4-5
- [ ] Alpha-beta pruning
- [ ] Софистициране хеуристике
- [ ] Move ordering
- [ ] Delay 1500-2000ms

### 4.5 UI Updates (Dan 12-13)
- [ ] Избор "Play vs AI" на Home Screen
- [ ] Избор тежине (Easy/Medium/Hard)
- [ ] AI thinking indicator
- [ ] "AI is thinking..." animacija
- [ ] Балансирање и тестирање

**Milestone 4**: ✅ Функционалан AI противник

---

## 📚 ФАЗА 5: Tutorial & Onboarding (2 дана)

**Циљ**: Едукација нових играча

### 5.1 Tutorial Screen (Dan 14)
- [ ] Tutorial screen UI (glassmorph)
- [ ] 4 слајда са објашњењем:
  - Слајд 1: Основна правила
  - Слајд 2: Plavi играч (хоризонтално)
  - Слајд 3: Црвени играч (вертикално)
  - Слајд 4: Победа и тајмер
- [ ] Интерактивни пример на 5x5 табли
- [ ] "Skip" и "Next" buttons
- [ ] Page indicator

### 5.2 First Launch Experience (Dan 15)
- [ ] Провера да ли је прва игра
- [ ] Аутоматски приказ tutorial-а
- [ ] "Don't show again" option
- [ ] Help button на Home Screen

**Milestone 5**: ✅ Нови корисници лако уче игру

---

## 💾 ФАЗА 6: Save/Load Game (1-2 дана)

**Циљ**: Чување и настављање партија

### 6.1 Storage Service (Dan 16)
- [ ] `StorageService` класа
- [ ] Serialization/Deserialization GameState
- [ ] Чување у shared_preferences или hive
- [ ] Load/Save методе

### 6.2 UI Integration (Dan 16-17)
- [ ] "Continue Game" button (ако постоји)
- [ ] Аутоматско чување при затварању апликације
- [ ] Аутоматско чување при пауза
- [ ] "New Game" overwrite warning
- [ ] Resume функционалност

**Milestone 6**: ✅ Корисници могу да паузирају и настављају

---

## 🌐 ФАЗА 7: Platform Optimization (2-3 дана)

**Циљ**: Оптимизација за све платформе

### 7.1 iOS Optimization (Dan 18)
- [ ] Тестирање на различитим iPhone величинама
- [ ] Safe area handling
- [ ] App icon и splash screen
- [ ] iOS specific permissions (audio, haptics)
- [ ] TestFlight build

### 7.2 Android Optimization (Dan 18-19)
- [ ] Тестирање на различитим Android уређајима
- [ ] Material Design adjustments
- [ ] App icon и splash screen
- [ ] Android specific permissions
- [ ] Internal testing build

### 7.3 Web Optimization (Dan 19-20)
- [ ] Responsive design (desktop/tablet/mobile)
- [ ] Keyboard shortcuts (optional)
- [ ] Touch и mouse controls
- [ ] PWA configuration
- [ ] Performance optimization
- [ ] Deploy на hosting (Firebase/Netlify)

### 7.4 Desktop (macOS, Windows, Linux) (Dan 20)
- [ ] Window sizing и resizing
- [ ] Native menus (ако је потребно)
- [ ] Keyboard shortcuts
- [ ] Builds за све платформе

**Milestone 7**: ✅ Игра ради савршено на свим платформама

---

## 🧪 ФАЗА 8: Testing & Bug Fixing (2-3 дана)

**Циљ**: Стабилна и поуздана апликација

### 8.1 Unit Tests (Dan 21)
- [ ] Game logic tests
- [ ] AI tests
- [ ] Validation tests

### 8.2 Widget Tests (Dan 21)
- [ ] Board rendering tests
- [ ] Timer tests
- [ ] Navigation tests

### 8.3 Integration Tests (Dan 22)
- [ ] Complete game flow
- [ ] Save/Load flow
- [ ] Settings persistence

### 8.4 Manual Testing (Dan 22-23)
- [ ] Све комбинације величина табли
- [ ] Све AI тежине
- [ ] Све timer опције
- [ ] Све теме
- [ ] Bug tracking и fixing

**Milestone 8**: ✅ Стабилна верзија 1.0

---

## 🚀 ФАЗА 9: Deployment (1 дан)

**Циљ**: Објављивање на store-ове

### 9.1 iOS Release (Dan 24)
- [ ] App Store Connect setup
- [ ] Screenshots и description
- [ ] Privacy policy
- [ ] App Store submission

### 9.2 Android Release (Dan 24)
- [ ] Google Play Console setup
- [ ] Screenshots и description
- [ ] Privacy policy
- [ ] Play Store submission

### 9.3 Web Release (Dan 24)
- [ ] Production deploy
- [ ] Domain setup (optional)
- [ ] Analytics (optional)

**Milestone 9**: ✅ Squart Live на свим платформама! 🎉

---

## 🔮 ФАЗА 10: Future (Post-Launch)

**Опционо - накнадно**

### 10.1 Online Multiplayer
- [ ] Backend server (Node.js/Python)
- [ ] WebSocket комуникација
- [ ] Matchmaking
- [ ] User accounts
- [ ] Leaderboard

### 10.2 Advanced Features
- [ ] Replay система
- [ ] Партија sharing
- [ ] Daily challenges
- [ ] Achievements
- [ ] Custom board patterns

---

## 📊 Укупна процена времена:

| Фаза | Опис | Дана |
|------|------|------|
| 0 | Припрема | 1 |
| 1 | MVP Core | 3-4 |
| 2 | UI/UX Polish | 2-3 |
| 3 | Timer & Settings | 2 |
| 4 | AI Opponent | 3-4 |
| 5 | Tutorial | 2 |
| 6 | Save/Load | 1-2 |
| 7 | Platforms | 2-3 |
| 8 | Testing | 2-3 |
| 9 | Deployment | 1 |
| **УКУПНО** | | **19-25 дана** |

---

## 🎯 Приоритети за MVP:

**Must Have** (Фазе 1-3):
- ✅ Player vs Player
- ✅ Glassmorph дизајн
- ✅ Тајмер систем
- ✅ Звук & вибрација
- ✅ Settings

**Should Have** (Фазе 4-6):
- ✅ AI противник
- ✅ Tutorial
- ✅ Save/Load

**Nice to Have** (Фазе 7-9):
- ✅ Platform optimization
- ✅ Testing
- ✅ Deployment

---

## 📝 Напомене:

1. **Флексибилност**: Фазе се могу прилагодити у зависности од препрека
2. **Паралелни рад**: Неке фазе се могу радити упоредо (нпр. UI и Audio)
3. **Iterative**: Свака фаза производи функционалан production build
4. **Testing**: Континуирано тестирање током развоја, не само у Фази 8

---

## 🎮 Design Specifications

### Glassmorph Style (iOS 26 inspired)
- Semi-transparent позадине са blur ефектом
- Суптилни border-и
- Мека сенка
- Smooth анимације
- SF Pro фонт за iOS / Poppins за друге платформе

### Color Palette

**Dark Theme (Primary)**:
- Background: Gradient (dark blue → purple)
- Glass containers: white.withOpacity(0.1) + blur
- Blue tokens: #4A90E2 (iOS system blue)
- Red tokens: #E94B4B (iOS system red)
- Black cells: Шаховски pattern (dark gray/light gray)

**Light Theme**:
- Background: Gradient (light blue → lavender)
- Glass containers: white.withOpacity(0.7) + blur
- Tokens: Исте боје али са border-има

### Token Design
- Једноставни правоугаоници са заобљеним ћошковима
- Хоризонтални жетони (2 поља): Плави
- Вертикални жетони (2 поља): Црвени

---

## 🔧 Technical Stack

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0           # State management
  shared_preferences: ^2.2.0 # Persistence
  audioplayers: ^5.2.0       # Sound effects
  vibration: ^1.8.0          # Haptic feedback
  flutter_animate: ^4.5.0    # Animations
  blur: ^3.1.0               # Glassmorph effect
```

### Project Structure
```
lib/
├── main.dart
├── core/
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   └── game_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       ├── audio_manager.dart
│       └── haptic_manager.dart
├── models/
│   ├── game_state.dart
│   ├── cell.dart
│   ├── token.dart
│   └── game_settings.dart
├── services/
│   ├── game_logic_service.dart
│   ├── ai_service.dart
│   └── storage_service.dart
├── providers/
│   └── game_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── settings_screen.dart
│   └── tutorial_screen.dart
└── widgets/
    ├── game_board.dart
    ├── board_cell.dart
    ├── token_widget.dart
    ├── timer_widget.dart
    └── glass_container.dart
```

---

## 🎯 AI Strategy (Heuristic-Based)

### Easy (Почетник)
- 60% greedy: Потез који максимално смањује противникове опције
- 30% центар: Игра у центру табле
- 10% random: Случајан потез (за "људскост")
- Delay: 500-1000ms

### Medium (Средњи)
- Minimax алгоритам (depth 2-3)
- Хеуристике:
  - Број доступних потеза (моји - противникови)
  - Бонус за централне позиције
  - Бонус за блокирање противника
- Delay: 1000-1500ms

### Hard (Напредни)
- Minimax (depth 4-5) + Alpha-beta pruning
- Напредне хеуристике
- Move ordering оптимизација
- Delay: 1500-2000ms

---

**Последњи пут ажурирано**: 9. октобар 2025.

