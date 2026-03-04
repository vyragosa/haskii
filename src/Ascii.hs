-- | Module Ascii — базовые типы, палитра символов и настройки приложения.
module Ascii
  ( Options (..)
  , defaultPalette
  , densePalette
  ) where

-- | Настройки командной строки.
data Options = Options
  { optInput  :: FilePath   -- ^ Путь к входному изображению
  , optWidth  :: Int        -- ^ Ширина вывода в символах
  , optInvert :: Bool       -- ^ Инвертировать яркость
  } deriving (Show)

-- | Стандартная палитра символов от самого светлого к самому тёмному.
-- Индекс символа выбирается пропорционально яркости пикселя.
defaultPalette :: String
defaultPalette = " .,:;+*?%S#@"

-- | Расширенная плотная палитра — больше деталей.
densePalette :: String
densePalette = " .'`^\",:;Il!i><~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"
