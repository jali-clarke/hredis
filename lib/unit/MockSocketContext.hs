{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module MockSocketContext (
    MockSocketContext(..),
    SocketBuffers(..),

    runMockSocketContext
) where

import qualified Control.Monad.Except as MTL
import qualified Control.Monad.State as MTL
import qualified Data.ByteString.Lazy as B

import Effects.SocketContext

data SocketBuffers = SocketBuffers B.ByteString B.ByteString
newtype MockSocketContext a = MockSocketContext (MTL.StateT SocketBuffers (Either SocketContextError) a)
    deriving (Functor, Applicative, Monad, MTL.MonadState SocketBuffers, MTL.MonadError SocketContextError)

instance SocketContext MockSocketContext where
    readCommunicator numBytes = do
        SocketBuffers rx tx <- MTL.get
        let bytes = B.take numBytes rx
        MTL.put (SocketBuffers (B.drop numBytes rx) tx)
        if B.length bytes /= numBytes
            then MTL.throwError SocketClosed
            else pure bytes

    writeCommunicator bytes = MTL.modify (\(SocketBuffers rx tx) -> SocketBuffers rx (tx <> bytes))

runMockSocketContext :: MockSocketContext a -> SocketBuffers -> Either SocketContextError (a, SocketBuffers)
runMockSocketContext (MockSocketContext action) = MTL.runStateT action