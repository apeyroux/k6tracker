{-# LANGUAGE OverloadedStrings #-}

--
-- todo: https://hackage.haskell.org/package/hailgun
--

module Main where

import           Control.Concurrent
import           Control.Exception.Safe
import           Control.Lens
import           Data.Aeson
import           Data.Aeson.Lens
import           Data.Monoid
import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import           Network.Mail.Mime
import           Network.Wreq
import           System.IO

data K6Status = K6Status {
  k6Av :: T.Text
  , k6Ds :: T.Text
  } deriving Show

type Hardware = String
type WSURL = String

writeLog :: String -> IO ()
writeLog = writeFile "/tmp/k6tracker.log"

sendStatusMail :: T.Text -> T.Text -> T.Text -> T.Text -> IO ()
sendStatusMail from to subject msg = do
  writeLog msg
  TIO.putStrLn msg

ovhws :: Hardware -> WSURL
ovhws hardware = "https://www.ovh.com/engine/api/dedicated/server/availabilities?country=fr&hardware=" ++ hardware

hardstatus :: Hardware -> IO [K6Status]
hardstatus h = do
  tryr <- tryAny (getWith opts (ovhws h))
  case tryr of
    Right r -> do
      return $ r ^.. responseBody
        . values
        . key "datacenters"
        . values
        . to (\e -> K6Status (e ^. key "availability" . _String) (e ^. key "datacenter" . _String))
        . filtered (("unavailable" /=) . k6Av)
    Left e -> print e
      >> writeLog (show e)
      >> return []
  where
    opts = set checkResponse (Just $ \_ _ -> return ()) defaults

main :: IO ()
main = putStrLn ("checking " ++ ovhws h ++ "...")
       >> hardstatus h
       >>= mapM_ (\ds -> do
                     sendStatusMail "test@lambda.email" "test@lambda.email"
                       ((k6Av ds) <> " at " <> (k6Ds ds))
                       ((k6Av ds) <> " at " <> (k6Ds ds))
                 )
       >> threadDelay delay
       >> main
  where
    h = "1801sk06"
    delay = 1000000 * 10 -- 10 sec
