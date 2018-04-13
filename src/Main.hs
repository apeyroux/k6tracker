{-# LANGUAGE OverloadedStrings #-}
module Main where

import Network.Wreq
import Control.Lens
import Data.Aeson.Lens
import qualified Data.Text as T
import Data.Aeson


main :: IO ()
main = do
  r <- get ovhws
  print $ r ^. responseBody . key "hardware" . _String
  where
    ovhws = "https://www.ovh.com/engine/api/dedicated/server/availabilities?country=fr"
