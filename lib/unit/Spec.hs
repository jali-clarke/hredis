{-# LANGUAGE OverloadedStrings #-}

import Test.Hspec
import MockSocketContext

import SocketContextInterpreter
import Redis

main :: IO ()
main = hspec $ do
    describe "withSocketContext" $ do
        it "should write bytes according to redis protocol to socket when doing a get" $ do
            let result = runMockSocketContext (withSocketContext (get "this_thing")) (SocketBuffers mempty mempty)
                tx = fmap (\(_, (SocketBuffers _ tx')) -> tx') result
            tx `shouldBe` Right "*2\r\n$3\r\nGET\r\n$10\r\nthis_thing\r\n"