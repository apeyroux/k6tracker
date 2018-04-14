{-# LANGUAGE OverloadedStrings #-}

--
-- todo: https://hackage.haskell.org/package/hailgun
--

module Main where

import           Control.Concurrent
import           Control.Exception as E
import           Control.Lens
import           Data.Aeson
import           Data.Aeson.Lens
import qualified Data.Text as T
import           Network.Wreq

data K6Status = K6Status {
  k6Av :: T.Text
  , k6Ds :: T.Text
  } deriving Show

type Hardware = String
type WSURL = String

ovhws :: Hardware -> WSURL
ovhws hardware = "https://www.ovh.com/engine/api/dedicated/server/availabilities?country=fr&&hardware=" ++ hardware

hardstatus :: Hardware -> IO [K6Status]
hardstatus h = do
  r <- getWith opts (ovhws h)
  return $ r ^.. responseBody
    . values
    . key "datacenters"
    . values
    . to (\e -> K6Status (e ^. key "availability" . _String) (e ^. key "datacenter" . _String))
    . filtered (("unavailable" /=) . k6Av)
  where
    opts = set checkResponse (Just $ \_ _ -> return ()) defaults

main :: IO ()
main = putStrLn ("checking " ++ ovhws h ++ "...")
       >> hardstatus h
       >>= mapM_ (\ds -> putStrLn $ (T.unpack (k6Av ds)) ++ " at " ++ (T.unpack (k6Ds ds)))
       >> threadDelay delay
       >> main
  where
    h = "1801sk06"
    delay = 1000000 * 10 -- 10 sec
