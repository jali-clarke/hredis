{-# LANGUAGE
    GeneralizedNewtypeDeriving,
    OverloadedStrings,
    RankNTypes
#-}

module Interpreters.SocketContextInterpreter (
    asSocketContext
) where

import Data.Functor (void)

import Data.ByteString.Lazy.Char8 (pack, unpack)
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Builder as B

import Effects.SocketContext
import Redis

newtype SocketContextInterpreter m a = SocketContextInterpreter (m a)
    deriving (Functor, Applicative, Monad)

readUntil' :: SocketContext m => (B.ByteString -> Bool) -> B.Builder -> m B.Builder
readUntil' predicate buffer = do
    byte <- readCommunicator 1
    if predicate byte
        then pure buffer
        else readUntil' predicate (buffer <> B.lazyByteString byte)

readUntil :: SocketContext m => (B.ByteString -> Bool) -> m B.ByteString
readUntil predicate = fmap B.toLazyByteString (readUntil' predicate mempty)

instance SocketContext m => Redis (SocketContextInterpreter m) where
    get key =
        let keyLength = B.length key
            stringToSend =
                B.lazyByteString "*2\r\n$3\r\nGET\r\n$"
                <> B.lazyByteString (pack $ show keyLength)
                <> B.lazyByteString "\r\n"
                <> B.lazyByteString key
                <> B.lazyByteString "\r\n"
        in SocketContextInterpreter $ do
            writeCommunicator (B.toLazyByteString stringToSend)
            void $ readCommunicator 1
            byteCount <- readUntil (== "\r")
            void $ readCommunicator 1
            let bytesToParse = read (unpack byteCount)
            if bytesToParse == -1
                then pure Nothing
                else fmap Just (readCommunicator bytesToParse) <* readCommunicator 2
        
    set = undefined

asSocketContext :: SocketContext n => (forall m. Redis m => m a) -> n a
asSocketContext (SocketContextInterpreter action) = action