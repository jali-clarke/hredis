module RedisClient (
    redisClient,
    closeClient,

    runWithClient
) where

import Redis
import Effects.SocketContext

redisClient :: String -> String -> IO (Socket IO)
redisClient = undefined

closeClient :: Socket IO -> IO ()
closeClient = undefined

runWithClient :: (Redis m, SocketContext n) => m a -> Socket n -> n a
runWithClient = undefined