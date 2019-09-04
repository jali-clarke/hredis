{-# LANGUAGE OverloadedStrings #-}

import Test.Hspec
import System.Environment (getEnv)

import Redis
import RedisClient

withClient :: String -> String -> (Socket IO -> IO ()) -> IO ()
withClient redisHost redisPort action = do
    client <- redisClient redisHost redisPort
    action client
    closeClient client

testRedisClient :: String -> String -> Spec
testRedisClient redisHost redisPort = around (withClient redisHost redisPort) $ do
    describe "redis client acceptance tests" $ do
        it "can 'get' a value that was 'set'" $ runWithClient $ do
            set "cool-key" "bep"
            get "cool-key" `shouldReturn` "bep"

main :: IO ()
main = do
    redisHost <- getEnv "REDIS_HOST"
    redisPort <- getEnv "REDIS_PORT"
    hspec $ testRedisClient redisHost redisPort