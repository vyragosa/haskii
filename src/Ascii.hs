-- | Модуль Ascii — преобразование растровых изображений в ASCII-арт.
module Ascii
  ( Options (..)
  , defaultPalette
  , densePalette
  , imageToAscii
  ) where

import Codec.Picture
import Codec.Picture.Types (convertImage, promoteImage)
import Data.Word (Word8)

-- ---------------------------------------------------------------------------
-- Типы
-- ---------------------------------------------------------------------------

-- | Настройки командной строки.
data Options = Options
  { optInput  :: FilePath   -- ^ Путь к входному изображению
  , optWidth  :: Int        -- ^ Ширина вывода в символах
  , optInvert :: Bool       -- ^ Инвертировать яркость
  , optDense  :: Bool       -- ^ Использовать плотную (расширенную) палитру
  } deriving (Show)

-- ---------------------------------------------------------------------------
-- Палитры символов
-- ---------------------------------------------------------------------------

-- | Стандартная палитра символов: от самого светлого к самому тёмному.
defaultPalette :: String
defaultPalette = " .,:;+*?%S#@"

-- | Расширенная плотная палитра — больше деталей.
densePalette :: String
densePalette = " .'`^\",:;Il!i><~+_-?][}{1)(|\\/tfjrxnuvczXYUJCLQ0OZmwqpdbkhao*#MW&8%B@$"

-- ---------------------------------------------------------------------------
-- Основная логика
-- ---------------------------------------------------------------------------

-- | Преобразует яркость пикселя [0..255] в символ из палитры.
pixelToChar :: String  -- ^ Палитра
            -> Bool    -- ^ Инвертировать?
            -> Word8   -- ^ Яркость пикселя
            -> Char
pixelToChar palette invert brightness =
  let len   = length palette
      -- нормализуем яркость в диапазон [0, len-1]
      idx0  = fromIntegral brightness * (len - 1) `div` 255
      idx   = if invert then len - 1 - idx0 else idx0
  in  palette !! idx

-- | Вычисляет яркость пикселя RGB по формуле BT.601.
luminance :: PixelRGB8 -> Word8
luminance (PixelRGB8 r g b) =
  let r' = fromIntegral r :: Double
      g' = fromIntegral g :: Double
      b' = fromIntegral b :: Double
  in  round (0.299 * r' + 0.587 * g' + 0.114 * b')

-- | Масштабирует изображение до нужной ширины; высота вычисляется автоматически
--   с коррекцией соотношения сторон символа (2:1).
scaleImage :: Image PixelRGB8 -> Int -> Image PixelRGB8
scaleImage img targetW =
  let w      = imageWidth  img
      h      = imageHeight img
      -- символы в терминале примерно в 2 раза выше, чем шире
      targetH = max 1 (targetW * h `div` (w * 2))
      scaleX  = fromIntegral w / fromIntegral targetW  :: Double
      scaleY  = fromIntegral h / fromIntegral targetH  :: Double
      sample xi yi =
        let sx = min (w - 1) (round (fromIntegral xi * scaleX))
            sy = min (h - 1) (round (fromIntegral yi * scaleY))
        in  pixelAt img sx sy
  in generateImage sample targetW targetH

-- | Конвертирует динамическое изображение (любой формат JuicyPixels) в RGB8.
toRGB8 :: DynamicImage -> Image PixelRGB8
toRGB8 (ImageRGB8   img) = img
toRGB8 (ImageRGBA8  img) = pixelMap dropAlpha img
  where dropAlpha (PixelRGBA8 r g b _) = PixelRGB8 r g b
toRGB8 (ImageY8    img) = promoteImage img
toRGB8 (ImageYA8   img) = promoteImage (pixelMap dropAlphaYA img)
  where dropAlphaYA (PixelYA8 y _) = y
toRGB8 (ImageYCbCr8 img) = convertImage img
toRGB8 _ = error "Unsupported image format"

-- | Главная функция: загружает изображение и возвращает ASCII-строку.
imageToAscii :: Options -> IO (Either String String)
imageToAscii opts = do
  result <- readImage (optInput opts)
  case result of
    Left  err -> return (Left $ "Ошибка загрузки изображения: " ++ err)
    Right dyn -> do
      let rgb     = toRGB8 dyn
          scaled  = scaleImage rgb (optWidth opts)
          palette = if optDense opts then densePalette else defaultPalette
          rows    = [ [ pixelToChar palette (optInvert opts)
                          (luminance (pixelAt scaled x y))
                      | x <- [0 .. imageWidth scaled - 1] ]
                    | y <- [0 .. imageHeight scaled - 1] ]
          art     = unlines rows
      return (Right art)
