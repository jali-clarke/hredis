{-# LANGUAGE
    GeneralizedNewtypeDeriving,
    OverloadedStrings,
    RankNTypes
#-}

module SocketContextInterpreter (
    withSocketContext
) where

import qualified Data.ByteString.Char8 as B

import Effects.SocketContext
import Redis

newtype SocketContextInterpreter m a = SocketContextInterpreter (m a)
    deriving (Functor, Applicative, Monad)

instance SocketContext m => Redis (SocketContextInterpreter m) where
    get key =
        let keyLength = B.length key
            stringToSend = "*2\r\n$3\r\nGET\r\n$" <> B.pack (show keyLength) <> "\r\n" <> key <> "\r\n"
        in SocketContextInterpreter $ mempty <$ writeCommunicator stringToSend
        
    set = undefined

withSocketContext :: SocketContext n => (forall m. Redis m => m a) -> n a
withSocketContext (SocketContextInterpreter action) = action