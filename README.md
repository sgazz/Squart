# Squart ML

Машинско учење за игру Squart. Овај пројекат имплементира ML модел који учи да игра Squart кроз самоиграње и тренирање.

## Структура пројекта

- `src/game.py` - Имплементација логике игре
- `src/data_generator.py` - Генератор података за тренирање
- `src/model.py` - ML модел за игру
- `src/train.py` - Скрипта за тренирање модела

## Инсталација

1. Креирајте виртуелно окружење:
```bash
python3 -m venv venv
source venv/bin/activate  # За Unix
# или
.\venv\Scripts\activate  # За Windows
```

2. Инсталирајте зависности:
```bash
pip install numpy pandas scikit-learn
```

## Употреба

За тренирање модела:
```bash
cd src
python train.py
```

Модел ће бити сачуван у `models/squart_model.joblib`.

## Лиценца

MIT 