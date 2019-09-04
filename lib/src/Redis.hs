{-# LANGUAGE FlexibleContexts #-}

module Redis (
    Redis(..),
    RedisException
) where

import qualified Control.Monad.Except as MTL
import qualified Data.ByteString as B

data RedisException

class MTL.MonadError RedisException m => Redis m where
    get :: B.ByteString -> m B.ByteString
    set :: B.ByteString -> B.ByteString -> m ()