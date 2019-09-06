{-# LANGUAGE
    RankNTypes,
    OverloadedStrings
#-}

module Interpreters.RequestInterpreter (
    asRequest
) where

import Data.ByteString.Lazy.Char8 (pack)
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Builder as B

import Redis

newtype Serializing a = Serializing B.ByteString

instance Redis Serializing where
    get key = Serializing . B.toLazyByteString $
        B.lazyByteString "*2\r\n$3\r\nGET\r\n$"
        <> B.lazyByteString (pack . show $ B.length key)
        <> B.lazyByteString "\r\n"
        <> B.lazyByteString key
        <> B.lazyByteString "\r\n"

    set _ _ = Serializing $ "*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$5\r\nvalue\r\n"

asRequest :: (forall m. Redis m => m a) -> B.ByteString
asRequest (Serializing bytes) = bytes 