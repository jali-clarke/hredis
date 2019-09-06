{-# LANGUAGE FlexibleContexts #-}

module Effects.SocketContext (
    SocketContext(..),
    SocketContextError(..)
) where

import qualified Control.Monad.Except as MTL
import qualified Data.ByteString.Lazy as B
import Data.Int

data SocketContextError = SocketClosed deriving (Eq, Show)

class MTL.MonadError SocketContextError m => SocketContext m where
    readCommunicator :: Int64 -> m B.ByteString
    writeCommunicator :: B.ByteString -> m ()
