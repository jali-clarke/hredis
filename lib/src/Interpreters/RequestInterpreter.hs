{-# LANGUAGE
    RankNTypes,
    OverloadedStrings
#-}

module Interpreters.RequestInterpreter (
    asRequest
) where

import qualified Data.ByteString.Lazy as B

import Redis

asRequest :: (forall m. Redis m => m a) -> B.ByteString
asRequest _ = "*2\r\n$3\r\nGET\r\n$3\r\nkey\r\n"