-- | Точка входа приложения hascii — CLI-заготовка.
module Main (main) where

import Ascii (Options (..), defaultPalette)
import Options.Applicative

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

-- | Информация о программе для --help.
programInfo :: ParserInfo Options
programInfo = info (optionsParser <**> helper)
  ( fullDesc
 <> progDesc "Преобразует изображение IMAGE в ASCII-арт"
 <> header   "hascii — генератор ASCII-арта из изображений" )

main :: IO ()
main = do
  opts <- execParser programInfo
  putStrLn $ "hascii: входной файл = " ++ optInput opts
  putStrLn $ "        ширина       = " ++ show (optWidth opts)
  putStrLn $ "        инверт       = " ++ show (optInvert opts)
  putStrLn $ "        палитра      = " ++ defaultPalette
  putStrLn "(логика преобразования будет добавлена в следующем коммите)"
