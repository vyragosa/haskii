# hascii

**hascii** — консольный генератор ASCII-арта из растровых изображений, написанный на Haskell.

Поддерживаемые форматы: PNG, JPG, BMP, GIF.

## Сборка

```bash
stack build
```

## Использование

```
stack exec hascii -- IMAGE [--width INT] [--invert] [--color] [--output FILE]
```

### Параметры

| Параметр        | Описание                                     | По умолчанию |
|-----------------|----------------------------------------------|--------------|
| `IMAGE`         | Путь к изображению                           | (обязателен) |
| `--width, -w`   | Ширина вывода в символах                     | `80`         |
| `--invert, -i`  | Инвертировать яркость (светлое ↔ тёмное)     | выключено    |
| `--color, -c`   | Вывод с ANSI-цветами                         | выключено    |
| `--output, -o`  | Сохранить результат в файл                   | stdout       |

### Примеры

```bash
# Стандартный вывод
stack exec hascii -- photo.png

# Широкий вывод с инвертированием
stack exec hascii -- photo.png --width 120 --invert

# Сохранить в файл
stack exec hascii -- photo.png --output result.txt

# Цветной вывод в терминале
stack exec hascii -- photo.png --color
```

## Лицензия

BSD-3-Clause