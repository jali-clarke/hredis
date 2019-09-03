{-# LANGUAGE TypeFamilies #-}

module MonadRedisClient (
    MonadRedisClient(..)
) where

import qualified Data.ByteString as B

class Monad m => MonadRedisClient m where
    type RedisClient m :: *

    readCommunicator :: RedisClient m -> Int -> m B.ByteString
    writeCommunicator :: RedisClient m -> B.ByteString -> m ()