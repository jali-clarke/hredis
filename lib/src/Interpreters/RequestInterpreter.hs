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

showableAsBytes :: Show a => a -> B.ByteString
showableAsBytes = pack . show

lengthAsBytes :: B.ByteString -> B.ByteString
lengthAsBytes = showableAsBytes . B.length

builderWithReturn :: B.ByteString -> B.Builder
builderWithReturn bytes = B.lazyByteString bytes <> B.lazyByteString "\r\n"

requestString' :: B.ByteString -> (Int, B.Builder) -> (Int, B.Builder)
requestString' bytes (numEntries, builder) =
    let serializedEntry = B.lazyByteString "$"
            <> builderWithReturn (lengthAsBytes bytes)
            <> builderWithReturn bytes
    in (numEntries + 1, serializedEntry <> builder)

requestString :: [B.ByteString] -> Serializing a
requestString bytesList =
    let (numEntries, builder) = foldr requestString' (0, mempty) bytesList
    in Serializing . B.toLazyByteString $ B.lazyByteString "*"
        <> builderWithReturn (showableAsBytes numEntries)
        <> builder

instance Redis Serializing where
    get key = requestString ["GET", key]

    set key value = Serializing . B.toLazyByteString $
        B.lazyByteString "*3\r\n$3\r\nSET\r\n$"
        <> builderWithReturn (lengthAsBytes key)
        <> builderWithReturn key
        <> B.lazyByteString "$"
        <> builderWithReturn (lengthAsBytes value)
        <> builderWithReturn value

asRequest :: (forall m. Redis m => m a) -> B.ByteString
asRequest (Serializing bytes) = bytes 