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

lengthAsBytes :: B.ByteString -> B.ByteString
lengthAsBytes = pack . show . B.length

builderWithReturn :: B.ByteString -> B.Builder
builderWithReturn bytes = B.lazyByteString bytes <> B.lazyByteString "\r\n"

instance Redis Serializing where
    get key = Serializing . B.toLazyByteString $
        B.lazyByteString "*2\r\n$3\r\nGET\r\n$"
        <> builderWithReturn (lengthAsBytes key)
        <> builderWithReturn key

    set key value = Serializing . B.toLazyByteString $
        B.lazyByteString "*3\r\n$3\r\nSET\r\n$"
        <> builderWithReturn (lengthAsBytes key)
        <> builderWithReturn key
        <> B.lazyByteString "$"
        <> builderWithReturn (lengthAsBytes value)
        <> builderWithReturn value

asRequest :: (forall m. Redis m => m a) -> B.ByteString
asRequest (Serializing bytes) = bytes 