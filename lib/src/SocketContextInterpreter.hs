{-# LANGUAGE
    GeneralizedNewtypeDeriving,
    OverloadedStrings,
    RankNTypes
#-}

module SocketContextInterpreter (
    withSocketContext
) where

import Effects.SocketContext
import Redis

newtype SocketContextInterpreter m a = SocketContextInterpreter (m a)
    deriving (Functor, Applicative, Monad)

instance SocketContext m => Redis (SocketContextInterpreter m) where
    get = const $ SocketContextInterpreter $ mempty <$ writeCommunicator "*2\r\n$3\r\nGET\r\n$10\r\nthis_thing\r\n"
        
    set = undefined

withSocketContext :: SocketContext n => (forall m. Redis m => m a) -> n a
withSocketContext (SocketContextInterpreter action) = action