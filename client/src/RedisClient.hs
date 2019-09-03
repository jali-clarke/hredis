module RedisClient (
    RedisClient,

    redisClient,
    closeClient
) where

import qualified Network.Socket as N

newtype RedisClient = RedisClient N.Socket

redisClient :: String -> String -> IO RedisClient
redisClient host port =
    let hints = N.defaultHints {N.addrSocketType = N.Stream}
    in do
        addr : _ <- N.getAddrInfo (Just hints) (Just host) (Just port)
        socket <- N.socket (N.addrFamily addr) (N.addrSocketType addr) (N.addrProtocol addr)
        N.connect socket $ N.addrAddress addr
        pure $ RedisClient socket

closeClient :: RedisClient -> IO ()
closeClient (RedisClient socket) = N.close socket