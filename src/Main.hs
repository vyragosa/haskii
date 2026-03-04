-- | Точка входа приложения hascii.
module Main (main) where

import Ascii (Options (..), imageToAscii)
import Options.Applicative
import System.Exit (exitFailure)

-- | Парсер аргументов командной строки.
optionsParser :: Parser Options
optionsParser = Options
  <$> argument str
        ( metavar "IMAGE"
       <> help "Путь к входному изображению (PNG, JPG, BMP)" )
  <*> option auto
        ( long "width"
       <> short 'w'
       <> metavar "INT"
       <> value 80
       <> showDefault
       <> help "Ширина ASCII-арта в символах" )
  <*> switch
        ( long "invert"
       <> short 'i'
       <> help "Инвертировать яркость (светлое ↔ тёмное)" )
  <*> switch
        ( long "dense"
       <> short 'd'
       <> help "Использовать плотную (расширенную) палитру" )

-- | Информация о программе для --help.
programInfo :: ParserInfo Options
programInfo = info (optionsParser <**> helper)
  ( fullDesc
 <> progDesc "Преобразует изображение IMAGE в ASCII-арт"
 <> header   "hascii — генератор ASCII-арта из изображений" )

main :: IO ()
main = do
  opts   <- execParser programInfo
  result <- imageToAscii opts
  case result of
    Left  err -> putStrLn err >> exitFailure
    Right art -> putStr art
