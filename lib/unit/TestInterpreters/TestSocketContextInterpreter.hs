{-# LANGUAGE
    OverloadedStrings,
    RankNTypes
#-}

module TestInterpreters.TestSocketContextInterpreter (
    testSocketContextInterpreter
) where

import Test.Hspec
import MockSocketContext

import qualified Data.ByteString.Lazy as B

import Effects.SocketContext
import Redis
import Interpreters.SocketContextInterpreter

dataFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError (a, SocketBuffers)
dataFromSocketContext action = runMockSocketContext (asSocketContext action)

viewFromSocketContext :: (forall m. Redis m => m a) -> ((a, SocketBuffers) -> b) -> SocketBuffers -> Either SocketContextError b
viewFromSocketContext action viewFunc = fmap viewFunc . dataFromSocketContext action

valueFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError a
valueFromSocketContext action = viewFromSocketContext action fst

txBufferFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError B.ByteString
txBufferFromSocketContext action = viewFromSocketContext action (_tx . snd)

rxBufferFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError B.ByteString
rxBufferFromSocketContext action = viewFromSocketContext action (_rx . snd)

testSocketContextInterpreter :: Spec
testSocketContextInterpreter = do
    describe "asSocketContext" $ do
        describe "get" $ do
            it "should write bytes according to redis protocol to socket when doing a get" $ do
                let result = txBufferFromSocketContext (get "this_thing") (SocketBuffers "$-1\r\n" mempty)
                result `shouldBe` Right "*2\r\n$3\r\nGET\r\n$10\r\nthis_thing\r\n"
            it "should write bytes according to redis protocol to socket when doing a get different key" $ do
                let result = txBufferFromSocketContext (get "that_boi") (SocketBuffers "$-1\r\n" mempty)
                result `shouldBe` Right "*2\r\n$3\r\nGET\r\n$8\r\nthat_boi\r\n"
            it "should receive bytes according to redis protocol from socket when doing a get" $ do
                let result = valueFromSocketContext (get "key") (SocketBuffers "$5\r\nvalue\r\n" mempty)
                result `shouldBe` Right (Just "value")
            it "should receive bytes according to redis protocol from socket when doing a get different response" $ do
                let result = valueFromSocketContext (get "key") (SocketBuffers "$3\r\nbep\r\n" mempty)
                result `shouldBe` Right (Just "bep")
            it "should receive bytes according to redis protocol from socket when doing a get different response including carriage return" $ do
                let result = valueFromSocketContext (get "key") (SocketBuffers "$6\r\nbep\ris\r\n" mempty)
                result `shouldBe` Right (Just "bep\ris")
            it "should consume the whole message sent if valid" $ do
                let result = rxBufferFromSocketContext (get "key_boi") (SocketBuffers "$10\r\n0123456789\r\n" mempty)
                result `shouldBe` Right ""
        describe "set" $ do
            it "should write bytes according to redis protocol to socket when doing a set" $ do
                let result = txBufferFromSocketContext (set "key" "value") (SocketBuffers "+OK\r\n" mempty)
                result `shouldBe` Right "*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$5\r\nvalue\r\n"
            it "should write bytes according to redis protocol to socket when doing a set different key" $ do
                let result = txBufferFromSocketContext (set "catbox" "value") (SocketBuffers "+OK\r\n" mempty)
                result `shouldBe` Right "*3\r\n$3\r\nSET\r\n$6\r\ncatbox\r\n$5\r\nvalue\r\n"
            it "should write bytes according to redis protocol to socket when doing a set different key and value" $ do
                let result = txBufferFromSocketContext (set "catbox" "") (SocketBuffers "+OK\r\n" mempty)
                result `shouldBe` Right "*3\r\n$3\r\nSET\r\n$6\r\ncatbox\r\n$0\r\n\r\n"
            it "should consume response completely" $ do
                let result = rxBufferFromSocketContext (set "catbox" "") (SocketBuffers "+OK\r\n" mempty)
                result `shouldBe` Right ""