{-# LANGUAGE
    GeneralizedNewtypeDeriving,
    OverloadedStrings,
    RankNTypes
#-}

module Interpreters.SocketContextInterpreter (
    asSocketContext
) where

import Data.Functor (void)

import Data.ByteString.Lazy.Char8 (unpack)
import qualified Data.ByteString.Lazy as B
import qualified Data.ByteString.Builder as B

import Effects.SocketContext
import Interpreters.RequestInterpreter
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
    get key = SocketContextInterpreter $ do
        writeCommunicator $ asRequest (get key)
        void $ readCommunicator 1
        byteCount <- readUntil (== "\r")
        void $ readCommunicator 1
        let bytesToParse = read (unpack byteCount)
        if bytesToParse == -1
            then pure Nothing
            else fmap Just (readCommunicator bytesToParse) <* readCommunicator 2
        
    set key value = SocketContextInterpreter $ writeCommunicator $ asRequest (set key value)

asSocketContext :: SocketContext n => (forall m. Redis m => m a) -> n a
asSocketContext (SocketContextInterpreter action) = action