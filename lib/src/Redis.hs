module Redis (
    Redis(..)
) where

import qualified Data.ByteString.Lazy as B

class Redis m where
    get :: B.ByteString -> m (Maybe B.ByteString)
    set :: B.ByteString -> B.ByteString -> m ()