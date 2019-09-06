{-# LANGUAGE
    OverloadedStrings,
    RankNTypes
#-}

import Test.Hspec
import MockSocketContext

import qualified Data.ByteString as B

import Effects.SocketContext
import Redis
import SocketContextInterpreter

buffersFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError (a, SocketBuffers)
buffersFromSocketContext action = runMockSocketContext (withSocketContext action)

valueFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError a
valueFromSocketContext action = fmap (\(a, _) -> a) . buffersFromSocketContext action

txBufferFromSocketContext :: (forall m. Redis m => m a) -> SocketBuffers -> Either SocketContextError B.ByteString
txBufferFromSocketContext action = fmap (\(_, (SocketBuffers _ tx)) -> tx) . buffersFromSocketContext action

main :: IO ()
main = hspec $ do
    describe "withSocketContext" $ do
        it "should write bytes according to redis protocol to socket when doing a get" $ do
            let result = txBufferFromSocketContext (get "this_thing") (SocketBuffers mempty mempty)
            result `shouldBe` Right "*2\r\n$3\r\nGET\r\n$10\r\nthis_thing\r\n"
        it "should write bytes according to redis protocol to socket when doing a get different key" $ do
            let result = txBufferFromSocketContext (get "that_boi") (SocketBuffers mempty mempty)
            result `shouldBe` Right "*2\r\n$3\r\nGET\r\n$8\r\nthat_boi\r\n"
        it "should receive bytes according to redis protocol from socket when doing a get" $ do
            let result = valueFromSocketContext (get "key") (SocketBuffers "$5\r\nvalue\r\n" mempty)
            result `shouldBe` Right (Just "$5\r\nvalue\r\n")