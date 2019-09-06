module Redis (
    Redis(..)
) where

import qualified Data.ByteString as B

class Monad m => Redis m where
    get :: B.ByteString -> m (Maybe B.ByteString)
    set :: B.ByteString -> B.ByteString -> m ()