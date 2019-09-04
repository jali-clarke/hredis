{-# LANGUAGE FlexibleContexts, TypeFamilies #-}

module Effects.SocketContext (
    SocketContext(..),
    SocketContextError(..)
) where

import qualified Control.Monad.Except as MTL
import qualified Data.ByteString as B

data SocketContextError = SocketClosed

class MTL.MonadError SocketContextError m => SocketContext m where
    type Socket m :: *

    readCommunicator :: Socket m -> Int -> m B.ByteString
    writeCommunicator :: Socket m -> B.ByteString -> m ()