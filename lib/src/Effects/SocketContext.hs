{-# LANGUAGE FlexibleContexts #-}

module Effects.SocketContext (
    SocketContext(..),
    SocketContextError(..)
) where

import qualified Control.Monad.Except as MTL
import qualified Data.ByteString as B

data SocketContextError = SocketClosed deriving (Eq, Show)

class MTL.MonadError SocketContextError m => SocketContext m where
    readCommunicator :: Int -> m B.ByteString
    writeCommunicator :: B.ByteString -> m ()
