module FakeRedis (

) where

import qualified Control.Monad.State as MTL
import qualified Control.Monad.Writer as MTL

import qualified Data.ByteString as B
import qualified Data.Map as M

newtype FakeRedis a = FakeRedis (MTL.State (M.Map B.ByteString B.ByteString) (MTL.Writer [B.ByteString]) a)
    deriving (Functor, Applicative, Monad, MonadState (M.Map B.ByteString B.ByteString), MonadWriter [B.ByteString])

runFakeRedis