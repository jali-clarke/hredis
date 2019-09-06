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

buffersFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError (a, SocketBuffers)
buffersFromSocketContext action = runMockSocketContext (asSocketContext action)

valueFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError a
valueFromSocketContext action = fmap (\(a, _) -> a) . buffersFromSocketContext action

txBufferFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError B.ByteString
txBufferFromSocketContext action = fmap (\(_, (SocketBuffers _ tx)) -> tx) . buffersFromSocketContext action

rxBufferFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError B.ByteString
rxBufferFromSocketContext action = fmap (\(_, (SocketBuffers rx _)) -> rx) . buffersFromSocketContext action

testSocketContextInterpreter :: Spec
testSocketContextInterpreter = do
    describe "asSocketContext" $ do
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
        it "should consume the whole message sent if valid" $ do
            let result = rxBufferFromSocketContext (get "key_boi") (SocketBuffers "$10\r\n0123456789\r\n" mempty)
            result `shouldBe` Right ""